// module domin_network::domin {
//     use sui::coin::{Self, Coin};
//     use domin_network::managed::MANAGED;
//     use sui::balance::{Self, Balance, Supply};
//     use sui::sui::SUI;

//     public struct DOMIN has drop { }    

//     public struct Reserve has key {
//         id: UID,
//         total_supply: Supply<DOMIN>,
//         sui: Balance<SUI>,
//         managed: Balance<MANAGED>,
//     }

//     const EBadDepositRatio: u64 = 0;

//     fun init(witness: DOMIN, ctx: &mut TxContext) {
//         let total_supply = balance::create_supply<DOMIN>(witness);

//         transfer::share_object(Reserve {
//             id: object::new(ctx),
//             total_supply,
//             sui: balance::zero<SUI>(),
//             managed: balance::zero<MANAGED>(),
//         })
//     }

//     public fun mint(reserve: &mut Reserve, sui: Coin<SUI>, managed: Coin<MANAGED>, ctx: &mut TxContext): Coin<DOMIN> {
//         let num_sui = coin::value(&sui);
//         assert!(num_sui == coin::value(&managed), EBadDepositRatio);

//         coin::put(&mut reserve.sui, sui);
//         coin::put(&mut reserve.managed, managed);

//         let minted_balance = balance::increase_supply(&mut reserve.total_supply, num_sui);

//         coin::from_balance(minted_balance, ctx)
//     }

//     public fun burn(reserve: &mut Reserve, domin: Coin<DOMIN>, ctx: &mut TxContext): (Coin<SUI>, Coin<MANAGED>) {
//         let num_domin = balance::decrease_supply(&mut reserve.total_supply, coin::into_balance(domin));
//         let sui = coin::take(&mut reserve.sui, num_domin, ctx);
//         let managed = coin::take(&mut reserve.managed, num_domin, ctx);

//         (sui, managed)
//     }

//     public fun total_supply(reserve: &Reserve): u64 {
//         balance::supply_value(&reserve.total_supply)
//     }

//      public fun sui_supply(reserve: &Reserve): u64 {
//         balance::value(&reserve.sui)
//     }

//     public fun managed_supply(reserve: &Reserve): u64 {
//         balance::value(&reserve.managed)
//     }

//     #[test_only]
//     public fun init_for_testing(ctx: &mut TxContext) {
//         init( DOMIN {}, ctx)
//     }
// }
