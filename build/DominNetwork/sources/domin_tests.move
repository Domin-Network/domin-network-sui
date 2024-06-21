#[test_only]
module domin_network::domin_tests {
    use domin_network::domin::{ Self };
    use sui::test_scenario;

    #[test]
    public fun test_domin() {
        let foundation = @0xA;
        let mut scenario_values = test_scenario::begin(foundation);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            domin::test_init(ctx);
        };

        test_scenario::end(scenario_values);
    }
}
