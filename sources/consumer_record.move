module domin_network::consumer_record {
    use sui::package;
    use domin_network::capability_manager::{Self, Capability};
    use domin_network::authorizer::Authorizer;
    use domin_network::operator::Operator;
    use std::string::{ String };
    use sui::table::{Self, Table};
    use sui::vec_set::{Self, VecSet};

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

    public struct ConsumerRecord has key, store {
        id: UID,
        authorizer_id: ID,
        operator_id: ID,
        consumer: String,
        private_details: ConsumerRecordPrivateDetails,
        timestamp: u64,
        status: u8,
    }

    public struct ConsumerRecordPrivateDetails has copy, drop, store {
        asset_data: String,
        metadata: String,
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
        let source = ConsumerRecordSource {
            id: object::new(ctx),
            version: VERSION,
            name: name,
            image: image,
            records: vector::empty(),
        };
        transfer::public_share_object(source);
    }

    public entry fun create_record(
        source: &mut ConsumerRecordSource,
        authorizer: &Authorizer,
        operator_id: ID,
        consumer: String,
        asset_data: String,
        metadata: String,
        timestamp: u64,
        ctx: &mut TxContext
    ) {
        let record = ConsumerRecord {
            id: object::new(ctx),
            authorizer_id: object::id(authorizer),
            operator_id: operator_id,
            consumer: consumer,
            private_details: ConsumerRecordPrivateDetails {
                asset_data: asset_data,
                metadata: metadata,
            },
            timestamp: timestamp,
            status: 0,
        };
        source.records.push_back(record);
        transfer::public_transfer(record, ctx.sender());
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = CONSUMER_RECORD {};
        init(otw, ctx);
    }
}
