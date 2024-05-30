#[test_only]
module domin_network::domin_network_tests {
    use domin_network::capability_manager::{Self, Capability};
    use sui::test_scenario;
    use std::debug;

    #[test]
    public fun test_create_capability() {
        let user = @0xA;

        let mut scenario_values = test_scenario::begin(user);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            capability_manager::test_init(ctx);
        };

        test_scenario::next_tx(scenario, user);
        {
            assert!(
                test_scenario::has_most_recent_for_sender<Capability>(scenario),
                0
            );
            let capability = test_scenario::take_from_sender<Capability>(scenario);
            debug::print(&object::id(&capability));
            assert!(
                capability_manager::get_role(&capability) == 0,
                1
            );
            let ctx = test_scenario::ctx(scenario);
            let new_capability = capability_manager::test_create_capability(
                &capability, 1, ctx
            );
            assert!(
                capability_manager::get_role(&new_capability) == 1,
                2
            );
            capability_manager::test_transfer_capability(new_capability, ctx.sender());
            test_scenario::return_to_sender(scenario, capability);
        };
        test_scenario::end(scenario_values);
    }
}
