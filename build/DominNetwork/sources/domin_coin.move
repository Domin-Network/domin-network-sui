module domin_network::domin_coin {
    use sui::coin::{Self, Coin, TreasuryCap};

    public struct DOMIN_COIN has drop {}
    public struct AdminCap has key {
        id: UID,
    }

    fun init(witness: DOMIN_COIN, ctx: &mut TxContext) {
        let admin = AdminCap {
            id: object::new(ctx),
        };
        let (treasury_cap, metadata) = coin::create_currency<DOMIN_COIN>(
            witness, 2, b"DOMIN", b"DOMIN COIN", b"DOMIN", option::none(), ctx
            );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
        transfer::transfer(admin, tx_context::sender(ctx));
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<DOMIN_COIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
    }

    public entry fun burn(
        treasury_cap: &mut TreasuryCap<DOMIN_COIN>,
        coin: Coin<DOMIN_COIN>,
    ) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let witness = DOMIN_COIN {};
        init(witness, ctx);
    }
}