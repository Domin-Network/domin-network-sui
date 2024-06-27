
# Modules

## [domin.move](./domin./domin.move)
## [staking_pool.move](./nodes/staking_pool.move)
### Create a staking pool

The providers can create a staking pool by calling the `domin_network::staking_pool::new(ctx)` function.

### Unstake from a staking pool

The token holders can unstake their tokens from the staking pool by calling the `domin_network::staking_pool::unstake(&mut pool, staked_domin)` function.

### Stake to a staking pool

The token holders can stake their tokens into the staking pool by calling the `domin_network::staking_pool::stake(&mut pool, stake_balance, ctx)` function and get the `StakedDomin` object.

### Unstake staked domin

The token holders can unstake their staked domin by calling the `domin_network::staking_pool::unstake(&mut pool, staked_domin)` function.

## [authorizer.move](./nodes/authorizer.move)

### Create an authorizer

The providers can create an authorizer by calling the `domin_network::authorizer::create_authorizer(&pool, ctx)` function.
And the staking pool's balance of domin needs to be greater than 1,250,000 to create an authorizer.

## [operator.move](./nodes/operator.move)

### Create an operator

The providers can create an operator by calling the `domin_network::operator::create_operator(&pool, ctx)` function.
And the staking pool's balance of domin needs to be greater than 125,000 to create an operator.