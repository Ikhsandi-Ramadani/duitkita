import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers.dart';
import '../../../data/db/app_database.dart';

// ---------------------------------------------------------------------------
// Wallet grouped by section
// ---------------------------------------------------------------------------

class WalletGroups {
  const WalletGroups({
    required this.mine,
    required this.shared,
    required this.others,
    required this.otherOwners,
  });
  // Wallets owned by current user (personal)
  final List<Wallet> mine;
  // Shared wallets
  final List<Wallet> shared;
  // Personal wallets owned by other members, keyed by owner id
  final Map<int, List<Wallet>> others;
  // Members who own 'others' wallets
  final List<Member> otherOwners;
}

final walletGroupsProvider =
    Provider.family<WalletGroups, int>((ref, userId) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  final members = ref.watch(membersProvider).value ?? [];

  final mine =
      wallets.where((w) => w.scope == 'personal' && w.ownerUserId == userId).toList();
  final shared = wallets.where((w) => w.scope == 'shared').toList();

  final othersRaw =
      wallets.where((w) => w.scope == 'personal' && w.ownerUserId != userId).toList();

  final Map<int, List<Wallet>> othersMap = {};
  for (final w in othersRaw) {
    final ownerId = w.ownerUserId!;
    othersMap.putIfAbsent(ownerId, () => []).add(w);
  }

  // Order other owners by member id for consistency
  final ownerIds = othersMap.keys.toList()..sort();
  final otherOwners =
      ownerIds.map((id) => members.cast<Member?>().firstWhere(
            (m) => m?.id == id,
            orElse: () => null,
          )).whereType<Member>().toList();

  return WalletGroups(
    mine: mine,
    shared: shared,
    others: othersMap,
    otherOwners: otherOwners,
  );
});

// Subtotals
final myBalanceTotalProvider = Provider.family<int, int>((ref, userId) {
  final groups = ref.watch(walletGroupsProvider(userId));
  return groups.mine.fold(0, (s, w) => s + w.currentBalance);
});

final sharedBalanceTotalProvider = Provider<int>((ref) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  return wallets
      .where((w) => w.scope == 'shared')
      .fold(0, (s, w) => s + w.currentBalance);
});

final otherMemberBalanceProvider = Provider.family<int, int>((ref, ownerId) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  return wallets
      .where((w) => w.scope == 'personal' && w.ownerUserId == ownerId)
      .fold(0, (s, w) => s + w.currentBalance);
});
