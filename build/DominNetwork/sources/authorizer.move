module domin_network::authorizer {
    use sui::package;

    public struct AUTHORIZER has drop {}

    public struct Authorizer has key {
        id: UID,
    }

    fun init(otw: AUTHORIZER, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = AUTHORIZER {};
        init(otw, ctx);
    }
}
