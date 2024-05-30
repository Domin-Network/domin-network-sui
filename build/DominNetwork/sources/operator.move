module domin_network::operator {
    use sui::package;
    use domin_network::capability_manager::{Self, Capability};

    const VERSION: u64 = 1;
    const ROLE: u64 = 2;
    const EOperatorCapability: u64 = 0;

    public struct OPERATOR has drop {}

    public struct Operator has key, store {
        id: UID,
        version: u64,
    }

    fun init(otw: OPERATOR, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    public entry fun create_operator(
        capability: &Capability,
        ctx: &mut TxContext
    ) {
        assert!(
            capability_manager::get_role(capability) == ROLE,
            EOperatorCapability
        );
        transfer::public_transfer(
            Operator {
                id: object::new(ctx),
                version: VERSION,
            },
            ctx.sender()
        )
    }

    public fun get_version(operator: &Operator): u64 {
        operator.version
    }
}
