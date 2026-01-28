import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/daily_cash_repository.dart';
import '../models/daily_cash_entry.dart';
import '../../features/light_dashboard/services/local_storage_service.dart';

final dailyCashRepositoryProvider = Provider<DailyCashRepository>((ref) {
  return DailyCashRepository(LocalStorageService.create());
});

final dailyCashControllerProvider =
    StateNotifierProvider<DailyCashController, List<DailyCashEntry>>((ref) {
  final repository = ref.watch(dailyCashRepositoryProvider);
  return DailyCashController(repository)..load();
});

class DailyCashController extends StateNotifier<List<DailyCashEntry>> {
  DailyCashController(this._repository) : super(const []);

  final DailyCashRepository _repository;
  bool _loaded = false;
  Future<void>? _loadFuture;

  Future<void> load() async {
    if (_loaded) return;
    _loadFuture ??= () async {
      final entries = await _repository.fetchEntries();
      state = entries;
      _loaded = true;
      _loadFuture = null;
    }();
    await _loadFuture;
  }

  Future<void> addEntry(DailyCashEntry entry) async {
    await load();
    final updated = [entry, ...state];
    state = updated;
    await _repository.persistEntries(updated);
  }

  Future<void> clear() async {
    await load();
    state = const [];
    await _repository.persistEntries(state);
  }
}
