module domin_network::operator {
    use sui::package;

    public struct OPERATOR has drop {}

    public struct Operator has key {
      id: UID,
    }

    fun init(otw: OPERATOR, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = OPERATOR {};
        init(otw, ctx);
    }
}
