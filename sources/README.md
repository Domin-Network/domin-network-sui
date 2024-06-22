
# Modules

## [domin.move](./domin./domin.move)
## [authorizer.move](./nodes/authorizer.move)
## [operator.move](./nodes/operator.move)
## [staking_pool.move](./nodes/staking_pool.move)
### Create a staking pool

The providers can create a staking pool by calling the `domin_network::staking_pool::new(ctx)` function.
The token holders can stake their tokens into the staking pool by calling the `domin_network::staking_pool::stake(&mut pool, stake_balance, ctx)` function and get the `StakedDomin` object.

### Unstake from a staking pool