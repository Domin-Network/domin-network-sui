module domin_network::vault {
    use sui::package;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use domin_network::domin::{ DOMIN };

    const DOMIN_FEES: u64 = 1_000_000;
    const AUTHORIZER_REWARD_PERCENTAGE: u64 = 5;
    const OPERATOR_REWARD_PERCENTAGE: u64 = 10;
    const AUTHORIZER_REWARD_GATE: u64 = 1_250_000_000_000;
    const OPERATOR_REWARD_GATE: u64 = 125_000_000_000;
    const AUTHORIZER_REWARD_PERCENTAGE_LIMIT: u64 = 3;
    const OPERATOR_REWARD_PERCENTAGE_LIMIT: u64 = 5;

    public struct VAULT has drop {}

    public struct Vault has key, store {
        id: UID,
        balance: Balance<DOMIN>,
        domin_fees: u64,
        authorizer_reward_percentage: u64,
        operator_reward_percentage: u64,
        authorizer_reward_gate: u64,
        operator_reward_gate: u64,
        authorizer_reward_percentage_limit: u64,
        operator_reward_percentage_limit: u64,
    }

    public struct AdminCap has key, store {
        id: UID,
    }

    fun init(otw: VAULT, ctx: &mut TxContext) {
        let admin_cap = AdminCap {id: object::new(ctx)};
        let vault = Vault {
            id: object::new(ctx),
            balance: balance::zero(),
            domin_fees: DOMIN_FEES,
            authorizer_reward_percentage: AUTHORIZER_REWARD_PERCENTAGE,
            operator_reward_percentage: OPERATOR_REWARD_PERCENTAGE,
            authorizer_reward_gate: AUTHORIZER_REWARD_GATE,
            operator_reward_gate: OPERATOR_REWARD_GATE,
            authorizer_reward_percentage_limit: AUTHORIZER_REWARD_PERCENTAGE_LIMIT,
            operator_reward_percentage_limit: OPERATOR_REWARD_PERCENTAGE_LIMIT,
        };
        package::claim_and_keep(otw, ctx);
        transfer::public_transfer(admin_cap, ctx.sender());
        transfer::public_share_object(vault);
    }

    public fun vault_domin_fees(vault: &Vault): u64 {
        vault.domin_fees
    }

    public fun vault_authorizer_reward_percentage(vault: &Vault): u64 {
        vault.authorizer_reward_percentage
    }

    public fun vault_operator_reward_percentage(vault: &Vault): u64 {
        vault.operator_reward_percentage
    }

    public fun vault_authorizer_reward_gate(vault: &Vault): u64 {
        vault.authorizer_reward_gate
    }

    public fun vault_operator_reward_gate(vault: &Vault): u64 {
        vault.operator_reward_gate
    }

    public fun vault_authorizer_reward_percentage_limit(vault: &Vault): u64 {
        vault.authorizer_reward_percentage_limit
    }

    public fun vault_operator_reward_percentage_limit(vault: &Vault): u64 {
        vault.operator_reward_percentage_limit
    }

    public use fun vault_domin_fees as Vault.domin_fees;
    public use fun vault_authorizer_reward_percentage as Vault.authorizer_reward_percentage;
    public use fun vault_operator_reward_percentage as Vault.operator_reward_percentage;
    public use fun vault_authorizer_reward_gate as Vault.authorizer_reward_gate;
    public use fun vault_operator_reward_gate as Vault.operator_reward_gate;
    public use fun vault_authorizer_reward_percentage_limit as Vault.authorizer_reward_percentage_limit;
    public use fun vault_operator_reward_percentage_limit as Vault.operator_reward_percentage_limit;

    public entry fun deposit(
        vault: &mut Vault,
        domin: Coin<DOMIN>,
    ) {
        coin::put(&mut vault.balance, domin);
    }

    public fun withdraw(
        _: &AdminCap,
        vault: &mut Vault,
        value: u64,
        ctx: &mut TxContext,
    ): Coin<DOMIN> {
        coin::take(&mut vault.balance, value, ctx)
    }

    public entry fun update_vault(
        _: &AdminCap,
        vault: &mut Vault,
        domin_fees: u64,
        authorizer_reward_percentage: u64,
        operator_reward_percentage: u64,
        authorizer_reward_gate: u64,
        operator_reward_gate: u64,
        authorizer_reward_percentage_limit: u64,
        operator_reward_percentage_limit: u64,
    ) {
        vault.domin_fees = domin_fees;
        vault.authorizer_reward_percentage = authorizer_reward_percentage;
        vault.operator_reward_percentage = operator_reward_percentage;
        vault.authorizer_reward_gate = authorizer_reward_gate;
        vault.operator_reward_gate = operator_reward_gate;
        vault.authorizer_reward_percentage_limit = authorizer_reward_percentage_limit;
        vault.operator_reward_percentage_limit = operator_reward_percentage_limit;
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        let otw = VAULT {};
        init(otw, ctx);
    }
}
