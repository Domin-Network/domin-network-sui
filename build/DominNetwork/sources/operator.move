module domin_network::operator {
    use sui::package;
    use domin_network::staking_pool::{ StakingPool };

    const MIN_STAKE: u64 = 125_000_000_000;

    const EOperatorrNotEnoughStake: u64 = 0;

    public struct OPERATOR has drop {}

    public struct Operator has key {
        id: UID,
        pool: StakingPool
    }

    fun init(otw: OPERATOR, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    public fun create_operator(
        pool: StakingPool,
        ctx: &mut TxContext
    ) {
        let operator = new(pool, ctx);
        transfer::transfer(operator, ctx.sender());
    }

    fun new(
        pool: StakingPool,
        ctx: &mut TxContext
    ): Operator {
        assert!(
            pool.domin_balance() > MIN_STAKE,
            EOperatorrNotEnoughStake
        );
        let operator = Operator {id: object::new(ctx), pool: pool};
        operator
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = OPERATOR {};
        init(otw, ctx);
    }

    #[test_only]
    public fun create_operator_for_testing(
        pool: StakingPool,
        ctx: &mut TxContext
    ): Operator {
        new(pool, ctx)
    }
}
