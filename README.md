# Miner Guild 
## an on chain mining pool for Provably Rare Gem

tl;dr - mine for the pool -> submit good salt to prove your work to the pool -> get hash provider token (HP-token) aka share of the pool.
at any point in time - you can claim your share of the pool to get wrapped gem. (limilar to how LP-token work)

---
## setting
to mine. your mining tool should mine for 
- pool address (instate of your own wallet)
- gem address - still the real gem address
- pool nonce (instatee of your own nonce) you can get this by calling nonce(pool address) for gem contract or call nonce(any address) on pool contract
- target gem is up to you. but all gem have it own pool. so mine what you want
- you can overwrite diff target. since the pool will credit you with HP-token even if it not match the gem diff. (I would recommend having it relatively high anyway to be gas efficient)

after you get the salt submit it to the pool with the function mine(kind,salt) same interface.

you can claim with withdraw(amount) to redeem your share of the pool

glhf

# no audit. use it your own risk.
