module domin_network::consumer_record {
    use sui::package;
    use domin_network::capability_manager::{Self, Capability};
    // use domin_network::authorizer::Authorizer;
    use domin_network::operator::Operator;
    use std::ascii::{ String };

    const VERSION: u64 = 1;
    const EConsumerRecordAuthorized: u64 = 0;
    const ROLE: u64 = 3;

    public struct CONSUMER_RECORD has drop {}

    public struct ConsumerRecordPlatform has key, store {
        id: UID,
        version: u64,
        name: String,
        records: vector<ConsumerRecord>,
    }

    // public struct ConsumerRecordDetail has key, store {
    //     id: UID,
    //     metadata: vector<u8>,
    // }

    public struct ConsumerRecord has key, store {
        id: UID,
        // version: u64,
        operator_id: ID,
        // authorizer_id: ID,
        // consumer: vector<u8>,
        // asset_data: vector<u8>,
        // detail: ConsumerRecordDetail,
        // timestamp: u64,
        // owner: ID,
        status: u8,
    }

    fun init(
        otw: CONSUMER_RECORD,
        ctx: &mut TxContext
    ) {
        package::claim_and_keep(otw, ctx);
    }

    public entry fun create_platform(
        capability: &Capability,
        name: String,
        ctx: &mut TxContext
    ) {
        assert!(
            capability_manager::get_role(capability) == ROLE,
            EConsumerRecordAuthorized
        );
        transfer::public_share_object(
            ConsumerRecordPlatform {
                id: object::new(ctx),
                version: VERSION,
                name: name,
                records: vector<ConsumerRecord>[],
            }
        );
    }

    // public entry fun create_consumer_record(
    //     platform: &ConsumerRecordPlatform,
    //     authorizer: &Authorizer,
    //     operator_id: ID,
    //     consumer: vector<u8>,
    //     asset_data: vector<u8>,
    //     metadata: vector<u8>,
    //     timestamp: u64,
    //     owner: ID,
    //     ctx: &mut TxContext
    // ) {
    //     let detail = ConsumerRecordDetail {
    //         id: object::new(ctx),
    //         metadata: metadata,
    //     };
    // }

    public entry fun update_status(
        operator: &Operator,
        record: &mut ConsumerRecord,
        status: u8
    ) {
        assert!(
            object::id(operator) == record.operator_id,
            EConsumerRecordAuthorized
        );
        record.status = status;
    }
}
