module domin_network::consumer_record {
    use sui::package;
    use domin_network::capability_manager::{Self, Capability};
    use domin_network::authorizer::Authorizer;
    use domin_network::operator::Operator;
    use std::string::{ String };

    const VERSION: u64 = 1;
    const EConsumerRecordAuthorized: u64 = 0;
    const ROLE: u64 = 3;

    public struct CONSUMER_RECORD has drop {}

    public struct ConsumerRecordSource has key, store {
        id: UID,
        version: u64,
        name: String,
        image: Option<String>,
        records: vector<ConsumerRecord>,
    }

    public struct ConsumerRecordDetail has key, store {
        id: UID,
        asset_data: String,
        metadata: String,
    }

    public struct ConsumerRecord has key, store {
        id: UID,
        version: u64,
        operator_id: ID,
        authorizer_id: ID,
        consumer: String,
        detail: ConsumerRecordDetail,
        timestamp: u64,
        status: u8,
    }

    fun init(
        otw: CONSUMER_RECORD,
        ctx: &mut TxContext
    ) {
        package::claim_and_keep(otw, ctx);
    }

    public entry fun create_source(
        capability: &Capability,
        name: String,
        image: Option<String>,
        ctx: &mut TxContext
    ) {
        assert!(
            capability_manager::get_role(capability) == ROLE,
            EConsumerRecordAuthorized
        );
        transfer::public_share_object(
            ConsumerRecordSource {
                id: object::new(ctx),
                version: VERSION,
                name: name,
                image: image,
                records: vector<ConsumerRecord>[],
            }
        );
    }

    public fun get_source_details(source: &ConsumerRecordSource): (String, Option<String>) {
        (source.name, source.image)
    }

    public entry fun create_consumer_record(
        authorizer: &Authorizer,
        operator_id: ID,
        source: &mut ConsumerRecordSource,
        consumer: String,
        asset_data: String,
        metadata: String,
        timestamp: u64,
        ctx: &mut TxContext
    ) {
        let detail = ConsumerRecordDetail {
            id: object::new(ctx),
            asset_data: asset_data,
            metadata: metadata,
        };
        let record = ConsumerRecord {
            id: object::new(ctx),
            version: VERSION,
            operator_id: operator_id,
            authorizer_id: object::id(authorizer),
            consumer: consumer,
            detail: detail,
            timestamp: timestamp,
            status: 0,
        };
        source.records.push_back(record);
    }

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

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = CONSUMER_RECORD {};
        init(otw, ctx);
    }
}
