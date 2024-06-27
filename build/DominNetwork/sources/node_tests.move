#[test_only]
module domin_network::node_tests {
    use sui::test_scenario::{Self, Scenario};
    use sui::coin::{Coin, TreasuryCap};
    use domin_network::authorizer::{Self, Authorizer};
    use domin_network::operator::{Self, Operator};
    use domin_network::staking_pool::{ Self };
    use domin_network::domin::{Self, DOMIN};
    use domin_network::vault::{Self, Vault};

    const FOUNDATION_ADDRESS: address = @0xA;
    const AUTHORIZER_PROVIDER_ADDRESS: address = @0xB;
    const OPERATOR_PROVIDER_ADDRESS: address = @0xC;
    const TOKEN_HOLDER_ADDRESS: address = @0xD;
    const NETWORK_USER_ADDRESS: address = @0xE;
    const TOKEN_HOLDER_TOKENS: u64 = 1_000;
    const NETWORK_USER_TOKENS: u64 = 1_000_000;

    fun foundation_init(scenario: &mut Scenario) {
        vault::test_init(test_scenario::ctx(scenario));
        test_scenario::next_tx(scenario, FOUNDATION_ADDRESS);
        domin_init(scenario);
        test_scenario::next_tx(scenario, FOUNDATION_ADDRESS);
        staking_pool::test_init(test_scenario::ctx(scenario));
    }

    fun domin_init(scenario: &mut Scenario) {
        domin::test_init(test_scenario::ctx(scenario));
        test_scenario::next_tx(scenario, FOUNDATION_ADDRESS);
        let vault = test_scenario::take_shared<Vault>(scenario);
        let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<DOMIN>>(scenario);
        let ctx = test_scenario::ctx(scenario);
        let coin_to_authorizer = domin::mint_for_testing(
            &mut treasury_cap,
            vault.authorizer_reward_gate() + 1,
            ctx
        );
        let coin_to_operator = domin::mint_for_testing(
            &mut treasury_cap,
            vault.operator_reward_gate() + 1,
            ctx
        );
        let coin_to_token_holder = domin::mint_for_testing(
            &mut treasury_cap,
            TOKEN_HOLDER_TOKENS,
            ctx
        );
        let coin_to_network_user = domin::mint_for_testing(
            &mut treasury_cap,
            NETWORK_USER_TOKENS,
            ctx
        );
        transfer::public_transfer(
            coin_to_authorizer,
            AUTHORIZER_PROVIDER_ADDRESS
        );
        transfer::public_transfer(
            coin_to_operator,
            OPERATOR_PROVIDER_ADDRESS
        );
        transfer::public_transfer(
            coin_to_token_holder,
            TOKEN_HOLDER_ADDRESS
        );
        transfer::public_transfer(
            coin_to_network_user,
            NETWORK_USER_ADDRESS
        );
        test_scenario::return_to_sender(scenario, treasury_cap);
        test_scenario::return_shared(vault);
    }

    fun authorizer_init(scenario: &mut Scenario) {
        authorizer::test_init(test_scenario::ctx(scenario));
        test_scenario::next_tx(
            scenario,
            AUTHORIZER_PROVIDER_ADDRESS
        );
        {
            let vault = test_scenario::take_shared<Vault>(scenario);
            let stake = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let mut pool = staking_pool::new(ctx);
            let staked_domin = staking_pool::stake(&mut pool, stake.into_balance(), ctx);
            assert!(
                staking_pool::staked_domin_amount(&staked_domin) > vault.authorizer_reward_gate()
            );
            transfer::public_transfer(staked_domin, ctx.sender());
            authorizer::create_authorizer(pool, ctx);
            test_scenario::return_shared(vault);
        };
    }

    fun operator_init(scenario: &mut Scenario) {
        operator::test_init(test_scenario::ctx(scenario));
        test_scenario::next_tx(scenario, OPERATOR_PROVIDER_ADDRESS);
        {
            let vault = test_scenario::take_shared<Vault>(scenario);
            let stake = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let mut pool = staking_pool::new(ctx);
            let staked_domin = staking_pool::stake(&mut pool, stake.into_balance(), ctx);
            assert!(
                staking_pool::staked_domin_amount(&staked_domin) > vault.operator_reward_gate()
            );
            transfer::public_transfer(staked_domin, ctx.sender());
            operator::create_operator(pool, ctx);
            test_scenario::return_shared(vault);
        };
    }

    // fun staking_pool_init(ctx: &mut TxContext) {©

    // }

    #[test]
    public fun test_authorizer() {
        let mut scenario_val = test_scenario::begin(FOUNDATION_ADDRESS);
        let scenario = &mut scenario_val;
        {
            foundation_init(scenario);
            authorizer_init(scenario);
            operator_init(scenario);
        };
        test_scenario::next_tx(scenario, NETWORK_USER_ADDRESS);
        {
            let mut vault = test_scenario::take_shared<Vault>(scenario);
            let mut authorizer = test_scenario::take_from_address<Authorizer>(
                scenario,
                AUTHORIZER_PROVIDER_ADDRESS
            );
            let operator = test_scenario::take_from_address<Operator>(
                scenario, OPERATOR_PROVIDER_ADDRESS
            );
            let fee = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            authorizer::submit(
                &mut vault,
                &mut authorizer,
                object::id(&operator),
                b"0x0",
                b"{}",
                b"{}",
                fee,
                ctx
            );
            test_scenario::return_to_address(
                AUTHORIZER_PROVIDER_ADDRESS,
                authorizer
            );
            test_scenario::return_to_address(OPERATOR_PROVIDER_ADDRESS, operator);
            test_scenario::return_shared(vault);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_operator() {
        let mut scenario_values = test_scenario::begin(FOUNDATION_ADDRESS);
        let scenario = &mut scenario_values;
        {
            foundation_init(scenario);
        };
        test_scenario::end(scenario_values);
    }

    // #[test]
    // public fun test_staking_pool() {
    //     let mut scenario_values = test_scenario::begin(FOUNDATION_ADDRESS);
    //     let scenario = &mut scenario_values;
    //     {
    //         foundation_init(scenario);
    //     };
    //     test_scenario::next_tx(scenario, TOKEN_HOLDER_ADDRESS);
    //     {
    //         let mut pool = test_scenario::take_from_address<StakingPool>(
    //             scenario,
    //             AUTHORIZER_PROVIDER_ADDRESS
    //         );
    //         let vault = test_scenario::take_shared<Vault>(scenario);
    //         let stake = test_scenario::take_from_sender<Coin<DOMIN>>(scenario);
    //         let ctx = test_scenario::ctx(scenario);
    //         let staked_domin = staking_pool::stake(&mut pool, stake.into_balance(), ctx);
    //         assert!(
    //             staking_pool::staked_domin_amount(&staked_domin) == TOKEN_HOLDER_TOKENS
    //         );
    //         let balance = staking_pool::unstake(&mut pool, staked_domin);
    //         assert!(
    //             balance.value() == TOKEN_HOLDER_TOKENS
    //         );
    //         transfer::public_transfer(
    //             coin::from_balance(balance, ctx),
    //             TOKEN_HOLDER_ADDRESS
    //         );
    //         test_scenario::return_to_address(AUTHORIZER_PROVIDER_ADDRESS, pool);
    //         test_scenario::return_shared(vault);
    //     };
    //     test_scenario::end(scenario_values);
    // }
}
