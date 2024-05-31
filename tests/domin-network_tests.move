#[test_only]
module domin_network::domin_network_tests {
    use domin_network::capability_manager::{Self, Capability};
    use domin_network::authorizer::{Self, Authorizer};
    use domin_network::operator::{ Self };
    use domin_network::consumer_record::{Self, ConsumerRecordSource};
    use sui::test_scenario;
    use std::debug;
    use std::option;

    #[test]
    public fun test_capability_manager() {
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
            assert!(
                capability_manager::get_version(&capability) == 1,
                3
            );
            capability_manager::test_transfer_capability(new_capability, ctx.sender());
            test_scenario::return_to_sender(scenario, capability);
        };
        test_scenario::end(scenario_values);
    }

    #[test]
    public fun test_create_consumer_record() {
        let domin_admin = @0xA;
        let authorizer_admin = @0xB;
        let operator_admin = @0xC;
        let authorizer_holder = @0xD;
        let operator_holder = @0xE;
        let consumer_record_admin = @0xF;
        let consumer_record_holder = @0x10;

        let mut scenario_values = test_scenario::begin(domin_admin);
        let scenario = &mut scenario_values;
        {
            let ctx = test_scenario::ctx(scenario);
            capability_manager::test_init(ctx);
        };

        test_scenario::next_tx(scenario, domin_admin);
        let admin_capability = test_scenario::take_from_sender<Capability>(scenario);
        let ctx = test_scenario::ctx(scenario);
        let authorizer_capability = capability_manager::test_create_capability(
            &admin_capability, 1, ctx
        );
        let operator_capability = capability_manager::test_create_capability(
            &admin_capability, 2, ctx
        );
        let consumer_record_capability = capability_manager::test_create_capability(
            &admin_capability, 3, ctx
        );
        {
            capability_manager::test_transfer_capability(
                authorizer_capability,
                authorizer_admin
            );
            capability_manager::test_transfer_capability(operator_capability, operator_admin);
            capability_manager::test_transfer_capability(
                consumer_record_capability,
                consumer_record_admin
            );
            test_scenario::return_to_sender(scenario, admin_capability);
        };

        test_scenario::next_tx(scenario, domin_admin);
        {
            let ctx = test_scenario::ctx(scenario);
            authorizer::test_init(ctx);
        };

        test_scenario::next_tx(scenario, authorizer_admin);
        let capability = test_scenario::take_from_sender<Capability>(scenario);
        let ctx = test_scenario::ctx(scenario);
        let new_authorizer = authorizer::test_create_authorizer(&capability, ctx);
        transfer::public_transfer(new_authorizer, authorizer_holder);
        test_scenario::return_to_sender(scenario, capability);

        test_scenario::next_tx(scenario, domin_admin);
        {
            let ctx = test_scenario::ctx(scenario);
            operator::test_init(ctx);
        };

        test_scenario::next_tx(scenario, operator_admin);

        let capability = test_scenario::take_from_sender<Capability>(scenario);
        let ctx = test_scenario::ctx(scenario);
        let new_operator = operator::test_create_operator(&capability, ctx);
        let operator_id = object::id(&new_operator);
        transfer::public_transfer(new_operator, operator_holder);
        test_scenario::return_to_sender(scenario, capability);

        test_scenario::next_tx(scenario, domin_admin);
        {
            let ctx = test_scenario::ctx(scenario);
            consumer_record::test_init(ctx);
        };

        test_scenario::next_tx(scenario, consumer_record_admin);
        {
            let capability = test_scenario::take_from_sender<Capability>(scenario);
            let ctx = test_scenario::ctx(scenario);
            consumer_record::create_source(
                &capability,
                b"Polygon".to_string(),
                option::some(b"".to_string()),
                ctx
            );
            test_scenario::return_to_sender(scenario, capability);
        };

        test_scenario::next_tx(scenario, authorizer_holder);
        {
            let authorizer = test_scenario::take_from_sender<Authorizer>(scenario);
            let mut source = test_scenario::take_shared<ConsumerRecordSource>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let (name, image) = consumer_record::get_source_details(&source);
            assert!(name == b"Polygon".to_string(), 0);
            assert!(
                image == option::some(b"".to_string()),
                1
            );
            consumer_record::create_consumer_record(
                &authorizer,
                operator_id,
                &mut source,
                b"".to_string(),
                b"".to_string(),
                b"".to_string(),
                1234,
                ctx
            );
            let records = source.records;
            assert!(
                consumer_record::get_record_details()
            )
            test_scenario::return_to_sender(scenario, authorizer);
            test_scenario::return_shared(source);
        };

        test_scenario::end(scenario_values);
    }
}
