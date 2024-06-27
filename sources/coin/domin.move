module domin_network::domin {
    use sui::coin::{Self, Coin, TreasuryCap};

    public struct DOMIN has drop {}

    fun init(otw: DOMIN, ctx: &mut TxContext) {
        let (treasury_cap, coin_metadata) = coin::create_currency<DOMIN>(
            otw,
            6,
            b"DOMIN",
            b"Domin",
            b"Domin Network currency",
            option::none(),
            ctx
        );
        transfer::public_freeze_object(coin_metadata);
        transfer::public_transfer(
            treasury_cap,
            tx_context::sender(ctx)
        );
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<DOMIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
    }

    public entry fun burn(
        treasury_cap: &mut TreasuryCap<DOMIN>,
        coin: Coin<DOMIN>
    ) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(DOMIN {}, ctx);
    }

    public fun mint_for_testing(
        treasury_cap: &mut TreasuryCap<DOMIN>,
        amount: u64,
        ctx: &mut TxContext
    ): Coin<DOMIN> {
        coin::mint(treasury_cap, amount, ctx)
    }
}
