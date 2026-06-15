/// Custody for the protocol-controlled SuiNS parent `variance.sui`.
///
/// Why this exists: leaf-subname registration runs as a *sponsored* transaction whose **sender is the
/// end user**. In a sponsored tx the sponsor supplies only the gas coins; every other owned-object
/// input must belong to the sender. The parent `SuinsRegistration` NFT is owned by the protocol — not
/// the user — so it cannot appear as an input in a user-sender tx. The fix (the Enoki "Identity
/// Subnames" custody pattern) is to hold the parent inside a **shared** object: a user's sponsored tx
/// can reference the shared `Custody`, and this module borrows the parent internally to mint the leaf,
/// enforcing that the leaf resolves to the caller.
///
/// Capabilities:
/// - `AdminCap` (parent lifecycle: deposit / withdraw / future renew) and the publish-time `UpgradeCap`
///   are minted to the publisher; transfer both to the **sponsor multisig** after setup.
/// - `register_initial` is user-callable and carries no cap — policy is "the leaf targets `ctx.sender()`".
module variance::custody;

use std::string::String;
use sui::clock::Clock;
use sui::dynamic_field as df;
use suins::controller;
use suins::domain;
use suins::registry::Registry;
use suins::suins::SuiNS;
use suins::suins_registration::SuinsRegistration;
use suins_subdomains::subdomains;

const EParentMissing: u64 = 0;
const EParentAlreadyDeposited: u64 = 1;

/// Dynamic-field key for the custody's own `address -> leaf name` index (see `subname_of`).
public struct OwnerKey has copy, drop, store { addr: address }

/// Parent-lifecycle authority. Minted once at publish; hand to the sponsor multisig.
public struct AdminCap has key, store {
    id: UID,
}

/// Shared custodian of the parent `variance.sui` registration. Shared so a user's sponsored tx can
/// reference it; the held parent NFT is never exposed to callers.
public struct Custody has key {
    id: UID,
    parent: Option<SuinsRegistration>,
}

/// Publish: mint the `AdminCap` to the publisher and share an (empty) `Custody`. Deposit the parent in
/// a follow-up admin tx once `variance.sui` is registered (see REGISTER_PARENT.txt).
fun init(ctx: &mut TxContext) {
    transfer::public_transfer(AdminCap { id: object::new(ctx) }, ctx.sender());
    transfer::share_object(Custody { id: object::new(ctx), parent: option::none() });
}

/// Admin: move the registered parent NFT into custody. Run once, after registering `variance.sui`.
public fun deposit_parent(_: &AdminCap, custody: &mut Custody, parent: SuinsRegistration) {
    assert!(custody.parent.is_none(), EParentAlreadyDeposited);
    custody.parent.fill(parent);
}

/// Admin: take the parent back out (recovery / migration). Mirrors the `parent_name.admin_recover`
/// AVS action. The returned NFT is handled by the calling PTB (e.g. transferred to a new custodian).
public fun withdraw_parent(_: &AdminCap, custody: &mut Custody): SuinsRegistration {
    assert!(custody.parent.is_some(), EParentMissing);
    custody.parent.extract()
}

/// User-callable, sponsored: register the leaf `<label>.variance.sui` resolving to the caller's address.
/// Leaf subnames carry no NFT — they are controlled through the parent held here, so post-registration
/// mutation/revocation also flows through this module (future `update_target` / `revoke`, gated on the
/// current target == `ctx.sender()`).
public fun register_initial(
    custody: &mut Custody,
    suins: &mut SuiNS,
    clock: &Clock,
    label: String,
    ctx: &mut TxContext,
) {
    assert!(custody.parent.is_some(), EParentMissing);
    let target = ctx.sender();
    // SuiNS `new_leaf` validates the FULL child name (`config::assert_is_valid_subdomain`), so we pass
    // "<label>.<parent>" (e.g. "alice.variance.sui"), not the bare label (which aborts with code 4).
    let full_name = full_leaf_name(custody, label);

    // Only adopt the new leaf as the caller's SuiNS default if they don't already have one — never
    // clobber a default the user picked themselves. They can opt in later via `set_as_default`.
    let has_default = suins.registry<Registry>().reverse_lookup(target).is_some();

    let parent = custody.parent.borrow();
    subdomains::new_leaf(suins, parent, clock, full_name, target, ctx);

    if (!has_default) {
        controller::set_reverse_lookup(suins, full_name, ctx);
    };

    // Always record in our own address -> leaf index (the app's reverse, verified against SuiNS).
    record_owner(custody, target, full_name);
}

/// User-callable: set the caller's existing leaf `<label>.<parent>` as their default (reverse) SuiNS
/// name. Use this if a user wants to make an already-registered leaf their default. SuiNS enforces
/// that the leaf's target address is the caller, so you can only default a name that resolves to you.
public fun set_as_default(custody: &Custody, suins: &mut SuiNS, label: String, ctx: &TxContext) {
    assert!(custody.parent.is_some(), EParentMissing);
    let full_name = full_leaf_name(custody, label);
    controller::set_reverse_lookup(suins, full_name, ctx);
}

/// Read-only (call via devInspect): the leaf `addr` registered THROUGH this custody — its
/// `<label>.<parent>` — or none. Two-way: the index gives the candidate name, but **SuiNS is the source
/// of truth** — we forward-resolve that name and only return it if it *still* targets `addr` (so a
/// retargeted/revoked leaf, or a stale index entry, yields none). This is the address -> *our* subname
/// reverse, independent of the user's mutable SuiNS default.
public fun subname_of(custody: &Custody, suins: &SuiNS, addr: address): Option<String> {
    let key = OwnerKey { addr };
    if (!df::exists_with_type<OwnerKey, String>(&custody.id, key)) {
        return option::none()
    };
    let name = *df::borrow<OwnerKey, String>(&custody.id, key);

    let record = suins.registry<Registry>().lookup(domain::new(name));
    if (record.is_some()) {
        let target = record.borrow().target_address();
        if (target.is_some() && *target.borrow() == addr) {
            return option::some(name)
        }
    };
    option::none()
}

/// Records / updates `addr -> name` in the custody's own dynamic-field index (latest leaf wins).
fun record_owner(custody: &mut Custody, addr: address, name: String) {
    let key = OwnerKey { addr };
    if (df::exists_with_type<OwnerKey, String>(&custody.id, key)) {
        *df::borrow_mut(&mut custody.id, key) = name;
    } else {
        df::add(&mut custody.id, key, name);
    };
}

/// Build the full child name `<label>.<parent>` (e.g. "alice.variance.sui"). Parent must be deposited.
fun full_leaf_name(custody: &Custody, label: String): String {
    let mut full = label;
    full.append_utf8(b".");
    full.append(custody.parent.borrow().domain_name());
    full
}

// ===== Tests =====
// `#[test]`/`#[test_only]` code is excluded from the published bytecode, so this has no effect on the
// upgrade. The full `register_initial` -> `new_leaf` path needs SuiNS app-authorization + parent
// subdomain config (heavy) and is exercised on-chain; here we cover the custody mechanics + the
// `subname_of` two-way logic directly.

#[test_only]
use sui::clock;
#[test_only]
use sui::test_scenario as ts;
#[test_only]
use std::unit_test::destroy;
#[test_only]
use suins::registry;
#[test_only]
use suins::suins;
#[test_only]
use suins::suins_registration;

#[test_only]
const ALICE: address = @0xA11CE;
#[test_only]
const BOB: address = @0xB0B;

#[test_only]
fun parent_domain(): domain::Domain { domain::new(b"variance.sui".to_string()) }

#[test_only]
fun fresh_custody(ctx: &mut TxContext): (Custody, AdminCap) {
    (Custody { id: object::new(ctx), parent: option::none() }, AdminCap { id: object::new(ctx) })
}

// --- custody mechanics ---

#[test]
fun deposit_then_withdraw() {
    let mut sc = ts::begin(ALICE);
    let ctx = sc.ctx();
    let clk = clock::create_for_testing(ctx);
    let (mut custody, admin) = fresh_custody(ctx);
    let parent = suins_registration::new_for_testing(parent_domain(), 1, &clk, ctx);

    deposit_parent(&admin, &mut custody, parent);
    assert!(custody.parent.is_some(), 0);
    let nft = withdraw_parent(&admin, &mut custody);
    assert!(custody.parent.is_none(), 1);

    destroy(nft);
    destroy(custody);
    destroy(admin);
    destroy(clk);
    sc.end();
}

#[test, expected_failure(abort_code = EParentAlreadyDeposited)]
fun deposit_twice_aborts() {
    let mut sc = ts::begin(ALICE);
    let ctx = sc.ctx();
    let clk = clock::create_for_testing(ctx);
    let (mut custody, admin) = fresh_custody(ctx);
    let p1 = suins_registration::new_for_testing(parent_domain(), 1, &clk, ctx);
    let p2 = suins_registration::new_for_testing(parent_domain(), 1, &clk, ctx);
    deposit_parent(&admin, &mut custody, p1);
    deposit_parent(&admin, &mut custody, p2); // aborts EParentAlreadyDeposited
    abort 0
}

#[test, expected_failure(abort_code = EParentMissing)]
fun withdraw_empty_aborts() {
    let mut sc = ts::begin(ALICE);
    let ctx = sc.ctx();
    let (mut custody, admin) = fresh_custody(ctx);
    let _nft = withdraw_parent(&admin, &mut custody); // aborts EParentMissing
    abort 0
}

// --- index + subname_of (two-way) ---

#[test_only]
fun suins_with_leaf(
    ctx: &mut TxContext,
    leaf: vector<u8>,
    target: address,
): (suins::SuiNS, clock::Clock) {
    let clk = clock::create_for_testing(ctx);
    let mut reg = registry::new_for_testing(ctx);
    let parent_nft = reg.add_record(parent_domain(), 1, &clk, ctx); // parent record
    reg.add_leaf_record(domain::new(leaf.to_string()), &clk, target, ctx); // leaf -> target
    let (mut s, cap) = suins::new_for_testing(ctx);
    cap.add_registry(&mut s, reg);
    destroy(parent_nft);
    destroy(cap);
    (s, clk)
}

#[test]
fun subname_of_hit() {
    let mut sc = ts::begin(ALICE);
    let (s, clk) = suins_with_leaf(sc.ctx(), b"alice.variance.sui", ALICE);
    let (mut custody, admin) = fresh_custody(sc.ctx());
    record_owner(&mut custody, ALICE, b"alice.variance.sui".to_string());

    assert!(subname_of(&custody, &s, ALICE) == option::some(b"alice.variance.sui".to_string()), 0);

    destroy(custody);
    destroy(admin);
    destroy(s);
    destroy(clk);
    sc.end();
}

#[test]
fun subname_of_target_mismatch_is_none() {
    // index claims ALICE -> alice.variance.sui, but the on-chain leaf targets BOB -> none (SuiNS wins).
    let mut sc = ts::begin(ALICE);
    let (s, clk) = suins_with_leaf(sc.ctx(), b"alice.variance.sui", BOB);
    let (mut custody, admin) = fresh_custody(sc.ctx());
    record_owner(&mut custody, ALICE, b"alice.variance.sui".to_string());

    assert!(subname_of(&custody, &s, ALICE).is_none(), 0);

    destroy(custody);
    destroy(admin);
    destroy(s);
    destroy(clk);
    sc.end();
}

#[test]
fun subname_of_no_index_is_none() {
    let mut sc = ts::begin(ALICE);
    let (s, clk) = suins_with_leaf(sc.ctx(), b"alice.variance.sui", ALICE);
    let (custody, admin) = fresh_custody(sc.ctx());

    assert!(subname_of(&custody, &s, BOB).is_none(), 0); // BOB has no index entry

    destroy(custody);
    destroy(admin);
    destroy(s);
    destroy(clk);
    sc.end();
}

#[test]
fun record_owner_latest_wins() {
    let mut sc = ts::begin(ALICE);
    let (mut custody, admin) = fresh_custody(sc.ctx());
    record_owner(&mut custody, ALICE, b"first.variance.sui".to_string());
    record_owner(&mut custody, ALICE, b"second.variance.sui".to_string());

    let stored = *df::borrow<OwnerKey, String>(&custody.id, OwnerKey { addr: ALICE });
    assert!(stored == b"second.variance.sui".to_string(), 0);

    destroy(custody);
    destroy(admin);
    sc.end();
}

#[test, expected_failure(abort_code = EParentMissing)]
fun register_without_parent_aborts() {
    let mut sc = ts::begin(ALICE);
    let ctx = sc.ctx();
    let (s, clk) = suins_with_leaf(ctx, b"x.variance.sui", ALICE);
    let (mut custody, admin) = fresh_custody(sc.ctx());
    let mut s = s;
    register_initial(&mut custody, &mut s, &clk, b"alice".to_string(), sc.ctx()); // aborts EParentMissing
    destroy(custody);
    destroy(admin);
    destroy(s);
    destroy(clk);
    sc.end();
}
