# Solidity-BigSmall-Casino
Welcome to the BigSmall Casino.

Players are able to enter the casino and choose either 'Big' or 'Small'. The contract will then use roll the dice to obtain a number.
- 0-4: Small
- 6-9: Big

If the player wins, player walks away with a 100% return on their initial bet. If the contract does not have enough eth to payout, the player receives everything the casino has.
*Only one player will be able to play at any given moment, and while the dice is rolled (~5 minutes), players will not be able to enter any new bets.
