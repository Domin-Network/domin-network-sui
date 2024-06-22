#[test_only]
module domin_network::domin_tests {
    use sui::test_scenario;
    use sui::coin::{Self, TreasuryCap};
    use domin_network::domin::{Self, DOMIN};

    #[test]
    public fun test_domin() {
        let foundation_manager = @0xA;
        let mut scenario_values = test_scenario::begin(foundation_manager);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            domin::test_init(ctx);
        };
        test_scenario::next_tx(scenario, foundation_manager);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<DOMIN>>(
                scenario
            );
            let ctx = test_scenario::ctx(scenario);
            let num_coins = 10;
            let coins = domin::mint_for_testing(&mut treasury_cap, num_coins, ctx);
            assert!(coin::value(&coins) == num_coins);
            test_scenario::return_to_sender(scenario, treasury_cap);
            transfer::public_transfer(coins, foundation_manager);
        };
        test_scenario::end(scenario_values);
    }
}
