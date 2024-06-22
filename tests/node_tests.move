#[test_only]
module domin_network::node_tests {
    use sui::test_scenario;
    use sui::coin::{Self, Coin, TreasuryCap};
    use domin_network::authorizer;
    use domin_network::operator;
    use domin_network::staking_pool::{Self, StakingPool, StakedDomin};
    use domin_network::domin::{Self, DOMIN};

    #[test]
    public fun test_authorizer() {
        let user = @0xA;
        let mut scenario_values = test_scenario::begin(user);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            authorizer::test_init(ctx);
        };
        test_scenario::end(scenario_values);
    }

    #[test]
    public fun test_operator() {
        let user = @0xA;
        let mut scenario_values = test_scenario::begin(user);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            operator::test_init(ctx);
        };
        test_scenario::end(scenario_values);
    }

    #[test]
    public fun test_staking_pool() {
        let admin = @0xA;
        let authorizer_provider = @0xB;
        let operator_provider = @0xC;
        let token_holder = @0xD;
        let mut scenario_values = test_scenario::begin(admin);
        let scenario = &mut scenario_values;
        let authorizer_min_stake = 1_250_000;
        let operator_min_stake = 125_000;
        let token_hodler_authorizer_stake = 50_000;
        let token_hodler_operator_stake = 5_000;
        {
            let ctx = test_scenario::ctx(scenario);
            staking_pool::test_init(ctx);
            domin::test_init(ctx);
        };
        test_scenario::next_tx(scenario, admin);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<DOMIN>>(
                scenario
            );
            let ctx = test_scenario::ctx(scenario);
            let coins_to_provider = domin::mint_for_testing(
                &mut treasury_cap,
                authorizer_min_stake,
                ctx
            );
            let coins_to_token_holder = domin::mint_for_testing(
                &mut treasury_cap,
                token_hodler_authorizer_stake + token_hodler_operator_stake,
                ctx
            );
            let coins_to_operator = domin::mint_for_testing(
                &mut treasury_cap,
                operator_min_stake,
                ctx
            );
            transfer::public_transfer(
                coins_to_provider,
                authorizer_provider
            );
            transfer::public_transfer(
                coins_to_operator,
                operator_provider
            );
            transfer::public_transfer(coins_to_token_holder, token_holder);
            test_scenario::return_to_sender(scenario, treasury_cap);
        };
        test_scenario::next_tx(scenario, authorizer_provider);
        {
            let coins = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let mut pool = staking_pool::new(ctx);
            let staked_domin = staking_pool::stake(&mut pool, coins.into_balance(), ctx);
            assert!(
                staking_pool::staked_domin_amount(&staked_domin) == authorizer_min_stake
            );
            transfer::public_transfer(staked_domin, authorizer_provider);
            transfer::public_transfer(pool, authorizer_provider);
        };
        test_scenario::next_tx(scenario, token_holder);
        {
            let coins = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let mut pool = test_scenario::take_from_address<StakingPool>(
                scenario, authorizer_provider
            );
            let mut balance = coins.into_balance();
            let ctx = test_scenario::ctx(scenario);
            let stake = coin::take<DOMIN>(
                &mut balance,
                token_hodler_authorizer_stake,
                ctx
            );
            let balance_coin = coin::from_balance(balance, ctx);
            let staked_domin = staking_pool::stake(&mut pool, stake.into_balance(), ctx);
            assert!(
                staking_pool::staking_pool_domin_balance(&pool) == authorizer_min_stake + token_hodler_authorizer_stake
            );
            test_scenario::return_to_address(authorizer_provider, pool);
            transfer::public_transfer(staked_domin, token_holder);
            transfer::public_transfer(balance_coin, token_holder);
        };
        test_scenario::next_tx(scenario, operator_provider);
        {
            let coins = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let mut pool = staking_pool::new(ctx);
            let staked_domin = staking_pool::stake(&mut pool, coins.into_balance(), ctx);
            assert!(
                staking_pool::staked_domin_amount(&staked_domin) == operator_min_stake
            );
            assert!(
                staking_pool::staking_pool_domin_balance(&pool) == operator_min_stake
            );
            assert!(
                staking_pool::staked_domin_pool_id(&staked_domin) == object::id(&pool)
            );
            transfer::public_transfer(staked_domin, operator_provider);
            transfer::public_transfer(pool, operator_provider);
        };
        test_scenario::next_tx(scenario, token_holder);
        {
            let coins = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let mut pool = test_scenario::take_from_address<StakingPool>(
                scenario, operator_provider
            );
            let ctx = test_scenario::ctx(scenario);
            let staked_domin = staking_pool::stake(&mut pool, coins.into_balance(), ctx);
            assert!(
                staking_pool::staking_pool_domin_balance(&pool) == operator_min_stake + token_hodler_operator_stake
            );
            assert!(
                staking_pool::staked_domin_amount(&staked_domin) == token_hodler_operator_stake
            );
            assert!(
                staking_pool::staked_domin_pool_id(&staked_domin) == object::id(&pool)
            );
            test_scenario::return_to_address(operator_provider, pool);
            transfer::public_transfer(staked_domin, token_holder);
        };
        test_scenario::next_tx(scenario, token_holder);
        {
            let mut pool = test_scenario::take_from_address<StakingPool>(
                scenario, operator_provider
            );
            let staked_domin = test_scenario::take_from_sender<StakedDomin>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let domin_balance = staking_pool::unstake(&mut pool, staked_domin);
            assert!(
                domin_balance.value() == token_hodler_operator_stake
            );
            test_scenario::return_to_address(operator_provider, pool);
            transfer::public_transfer(
                coin::from_balance(domin_balance, ctx),
                token_holder
            );
        };
        test_scenario::end(scenario_values);
    }
}
