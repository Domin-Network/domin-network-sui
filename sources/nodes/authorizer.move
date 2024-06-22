module domin_network::authorizer {
    use sui::package;
    use domin_network::staking_pool::{ StakingPool };

    const MIN_STAKE: u64 = 1_250_000;

    const EAuthorizerNotEnoughStake: u64 = 0;

    public struct AUTHORIZER has drop {}

    public struct Authorizer has key {
        id: UID,
        pool_id: ID
    }

    fun init(otw: AUTHORIZER, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    public fun create_authroizer(
        pool: &StakingPool,
        ctx: &mut TxContext
    ) {
        let authorizer = new(pool, ctx);
        transfer::transfer(authorizer, ctx.sender());
    }

    fun new(
        pool: &StakingPool,
        ctx: &mut TxContext
    ): Authorizer {
        assert!(
            pool.domin_balance() > MIN_STAKE,
            EAuthorizerNotEnoughStake
        );
        let authorizer = Authorizer {
            id: object::new(ctx),
            pool_id: object::id(pool)
        };
        authorizer
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = AUTHORIZER {};
        init(otw, ctx);
    }

    #[test_only]
    public fun create_authorizer_for_testing(
        pool: &StakingPool,
        ctx: &mut TxContext
    ): Authorizer {
        new(pool, ctx)
    }
}
