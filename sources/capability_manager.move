module domin_network::capability_manager {
    use sui::package;

    const VERSION: u64 = 1;
    const ECapabilityManagerAuthorized: u64 = 0;

    public struct CAPABILITY_MANAGER has drop {}

    public struct Capability has key {
        id: UID,
        role: u64,
        version: u64,
    }

    fun init(
        otw: CAPABILITY_MANAGER,
        ctx: &mut TxContext
    ) {
        package::claim_and_keep(otw, ctx);

        let capability = Capability {
            id: object::new(ctx),
            role: 0,
            version: VERSION,
        };

        transfer::transfer(capability, ctx.sender());
    }

    public fun get_role(capability: &Capability): u64 {
        capability.role
    }

    public fun get_version(capability: &Capability): u64 {
        capability.version
    }

    public entry fun create_capability(
        admin_capability: &Capability,
        role: u64,
        ctx: &mut TxContext
    ) {
        assert!(
            admin_capability.role == 0,
            ECapabilityManagerAuthorized
        );
        transfer::transfer(
            Capability {
                id: object::new(ctx),
                role: role,
                version: VERSION,
            },
            ctx.sender()
        );
    }

    public entry fun revoke_capability(
        admin_capability: &Capability,
        capability: Capability
    ) {
        assert!(
            admin_capability.role == 0,
            ECapabilityManagerAuthorized
        );
        let Capability {id,..} = capability;
        object::delete(id);
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = CAPABILITY_MANAGER {};
        init(otw, ctx);
    }

    #[test_only]
    public fun test_create_capability(
        admin_capability: &Capability,
        role: u64,
        ctx: &mut TxContext
    ): Capability {
        assert!(
            admin_capability.role == 0,
            ECapabilityManagerAuthorized
        );
        Capability {
            id: object::new(ctx),
            role: role,
            version: VERSION,
        }
    }

    #[test_only]
    public entry fun test_transfer_capability(capability: Capability, to: address) {
        transfer::transfer(capability, to);
    }
}
