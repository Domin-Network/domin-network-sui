module domin_network::authorizer {
    use sui::package;
    use sui::coin::{Self, Coin};
    // use sui::balance::{ Balance };
    // use sui::math::{ Self };
    use domin_network::domin::{ DOMIN };
    use domin_network::staking_pool::{ StakingPool };
    use domin_network::consumer_data::{ Self };
    use domin_network::vault::{Self, Vault};

    const MIN_STAKE: u64 = 1_250_000_000_000;

    const EAuthorizerNotEnoughStake: u64 = 0;
    const EAuthorizerNotEnoughFees: u64 = 1;

    public struct AUTHORIZER has drop {}

    public struct Authorizer has key {
        id: UID,
        pool: StakingPool
    }

    fun init(otw: AUTHORIZER, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    fun new(
        pool: StakingPool,
        ctx: &mut TxContext
    ): Authorizer {
        assert!(
            pool.domin_balance() > MIN_STAKE,
            EAuthorizerNotEnoughStake
        );
        let authorizer = Authorizer {id: object::new(ctx), pool: pool};
        authorizer
    }

    public fun create_authorizer(
        pool: StakingPool,
        ctx: &mut TxContext
    ) {
        let authorizer = new(pool, ctx);
        transfer::transfer(authorizer, ctx.sender());
    }

    public fun authorizer_staking_pool_id(authorizer: &Authorizer): ID {
        object::id(&authorizer.pool)
    }

    public use fun authorizer_staking_pool_id as Authorizer.pool_id;

    public entry fun submit(
        vault: &mut Vault,
        authorizer: &mut Authorizer,
        operator_id: ID,
        consumer: vector<u8>,
        asset_data: vector<u8>,
        metadata: vector<u8>,
        fee: Coin<DOMIN>,
        ctx: &mut TxContext
    ) {
        assert!(
            authorizer.pool.domin_balance() > MIN_STAKE,
            EAuthorizerNotEnoughStake
        );
        assert!(
            coin::value(&fee) >= vault.domin_fees(),
            EAuthorizerNotEnoughFees
        );
        let record = consumer_data::create_consumer_record(
            operator_id,
            consumer,
            asset_data,
            metadata,
            ctx
        );
        transfer::public_transfer(record, ctx.sender());
        let mut balance = fee.into_balance();
        let domin_fees = coin::take<DOMIN>(
            &mut balance,
            vault.domin_fees(),
            ctx
        );
        vault::deposit(vault, domin_fees);
        let balance_coin = coin::from_balance(balance, ctx);
        transfer::public_transfer(balance_coin, ctx.sender());
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = AUTHORIZER {};
        init(otw, ctx);
    }

    #[test_only]
    public fun create_authorizer_for_testing(
        pool: StakingPool,
        ctx: &mut TxContext
    ): Authorizer {
        new(pool, ctx)
    }
}
