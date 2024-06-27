module domin_network::consumer_data {
    use sui::package;

    public struct CONSUMER_DATA has drop {}

    public struct ConsumerPrivateData has copy, drop, store {
        asset_data: vector<u8>,
        metadata: vector<u8>
    }

    public struct ConsumerRecord has key, store {
        id: UID,
        authorizer_id: ID,
        consumer: vector<u8>,
        private_data: ConsumerPrivateData
    }

    fun init(
        otw: CONSUMER_DATA,
        ctx: &mut TxContext
    ) {
        package::claim_and_keep(otw, ctx);
    }

    public fun create_consumer_record(
        operator_id: ID,
        consumer: vector<u8>,
        asset_data: vector<u8>,
        metadata: vector<u8>,
        ctx: &mut TxContext
    ): ConsumerRecord {
        ConsumerRecord {
            id: object::new(ctx),
            authorizer_id: operator_id,
            consumer: consumer,
            private_data: ConsumerPrivateData {
                asset_data: asset_data,
                metadata: metadata
            }
        }
    }

    public fun asset_data(record: &ConsumerRecord): vector<u8> {
        record.private_data.asset_data
    }

    public fun metadata(record: &ConsumerRecord): vector<u8> {
        record.private_data.metadata
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = CONSUMER_DATA {};
        init(otw, ctx);
    }
}
