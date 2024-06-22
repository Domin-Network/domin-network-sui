module domin_network::staking_pool {
    use sui::package;
    use sui::balance::{ Balance };
    use domin_network::domin::{ DOMIN };

    const EStakingPoolOfZeroDomin: u64 = 0;
    const EStakingPoolIdMismatch: u64 = 1;

    public struct STAKING_POOL has drop {}

    public struct StakingPool has key, store {
        id: UID,
        domin_balance: u64,
        pool_token_balance: u64,
    }

    public struct StakedDomin has key, store {
        id: UID,
        pool_id: ID,
        principal: Balance<DOMIN>,
    }

    fun init(
        otw: STAKING_POOL,
        ctx: &mut TxContext
    ) {
        package::claim_and_keep(otw, ctx);
    }

    public fun new(ctx: &mut TxContext): StakingPool {
        StakingPool {
            id: object::new(ctx),
            domin_balance: 0,
            pool_token_balance: 0,
        }
    }

    public fun staked_domin_amount(staked_domin: &StakedDomin): u64 {
        staked_domin.principal.value()
    }

    public fun staked_domin_pool_id(staked_domin: &StakedDomin): ID {
        staked_domin.pool_id
    }

    public fun staking_pool_domin_balance(pool: &StakingPool): u64 {
        pool.domin_balance
    }

    public fun stake(
        pool: &mut StakingPool,
        stake: Balance<DOMIN>,
        ctx: &mut TxContext
    ): StakedDomin {
        let domin_amount = stake.value();
        assert!(
            domin_amount > 0,
            EStakingPoolOfZeroDomin
        );
        let staked_domin = StakedDomin {
            id: object::new(ctx),
            pool_id: object::id(pool),
            principal: stake,
        };
        pool.domin_balance = pool.domin_balance + domin_amount;
        staked_domin
    }

    public fun unstake(
        pool: &mut StakingPool,
        staked_domin: StakedDomin,
    ): Balance<DOMIN> {
        let StakedDomin {
            id: id,
            pool_id: pool_id,
            principal: domin_balance,
        } = staked_domin;
        assert!(
            domin_balance.value() > 0,
            EStakingPoolOfZeroDomin
        );
        assert!(
            pool_id == object::id(pool),
            EStakingPoolIdMismatch
        );
        pool.domin_balance = pool.domin_balance - domin_balance.value();
        object::delete(id);
        domin_balance
    }

    // fun unwrap_staked_domin(staked_domin: StakedDomin): Balance<DOMIN> {
    //     let StakedDomin {
    //         id,
    //         pool_id: _,
    //         principal,
    //     } = staked_domin;
    //     object::delete(id);
    //     principal
    // }

    // public use fun unwrap_staked_domin as StakedDomin.into_balance;

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = STAKING_POOL {};
        init(otw, ctx);
    }
}
