pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/HPtoken.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

// @dev extended Gem interface.
interface IGemExtended is IERC1155 {
    function gemCount() external view returns (uint256);

    function gems(uint256)
        external
        view
        returns (
            string memory,
            string memory,
            bytes32,
            uint256,
            uint256,
            uint256,
            address,
            address,
            address
        );

    function nonce(address) external view returns (uint256);

    function luck(uint256 kind, uint256 salt) external view returns (uint256);

    function mine(uint256 kind, uint256 salt) external;
}

// @dev mining pool contract design to be able to mine seems lessly.
contract MinerGuild is Ownable {
    struct gem {
        bool exist;
        uint256 kind;
        address wrapAddress;
        HPToken hptoken;
        uint256 bonus;
    }
    IGemExtended gemContract =
        IGemExtended(0x342EbF0A5ceC4404CcFF73a40f9c30288Fc72611);
    mapping(uint256 => gem) gemsMap;

    constructor() {}

    function addGem(
        uint256 kind,
        address wrapAddress,
        string memory HPName,
        string memory HPSymbol,
        uint256 bonus
    ) public onlyOwner {
        require(!gemsMap[kind].exist, "already exist");
        gemsMap[kind] = gem(
            true,
            kind,
            wrapAddress,
            new HPToken(HPName, HPSymbol),
            bonus
        );
    }

    function gems(uint256 kind)
        public
        view
        returns (
            string memory,
            string memory,
            bytes32,
            uint256,
            uint256,
            uint256,
            address,
            address,
            address
        )
    {
        return gemContract.gems(kind);
    }

    function nonce() public view returns (uint256) {
        return gemContract.nonce(address(this));
    }

    function mine(uint256 kind, uint256 salt) public {
        uint256 userNewShare = 0;
        uint256 l = gemContract.luck(kind, salt);
        (, , , uint256 diff, , , , , ) = gemContract.gems(kind);
        if (l < type(uint256).max / diff) {
            // success
            gemContract.mine(kind, salt);
            // wrap
            gemContract.safeTransferFrom(
                address(this),
                gemsMap[kind].wrapAddress,
                kind,
                gemContract.balanceOf(address(this), kind),
                "0x"
            );
            // give some bonus for the lucky miner
            userNewShare += gemsMap[kind].bonus;
        }
        userNewShare += type(uint256).max / l;
        gemsMap[kind].hptoken.mint(msg.sender, userNewShare);
    }

    function withdraw(uint256 kind, uint256 amount) public {
        // YOLO let's burn - no need for approval!!
        IERC20 wrappedGem = IERC20(gemsMap[kind].wrapAddress);
        uint256 totalShare = gemsMap[kind].hptoken.totalSupply();
        uint256 vaultValue = wrappedGem.balanceOf(address(this));
        uint256 toRedreem = (amount * vaultValue) / totalShare;
        wrappedGem.transfer(msg.sender, toRedreem);
        gemsMap[kind].hptoken.burn(msg.sender, amount);
    }
}
