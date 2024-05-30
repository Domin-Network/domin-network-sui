module domin_network::authorizer {
    use sui::package;
    use domin_network::capability_manager::{Self, Capability};

    const VERSION: u64 = 1;
    const ROLE: u64 = 1;
    const EAuthorizerCapability: u64 = 0;

    public struct AUTHORIZER has drop {}

    public struct Authorizer has key, store {
        id: UID,
        version: u64,
    }

    fun init(otw: AUTHORIZER, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    public entry fun create_authorizer(
        capability: &Capability,
        ctx: &mut TxContext
    ) {
        assert!(
            capability_manager::get_role(capability) == ROLE,
            EAuthorizerCapability
        );
        transfer::public_transfer(
            Authorizer {
                id: object::new(ctx),
                version: VERSION,
            },
            ctx.sender()
        )
    }

    public fun get_version(authorizer: &Authorizer): u64 {
        authorizer.version
    }
}
