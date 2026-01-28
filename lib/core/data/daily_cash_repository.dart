import '../models/daily_cash_entry.dart';
import '../../features/light_dashboard/services/local_storage_service.dart';

class DailyCashRepository {
  DailyCashRepository(this._storageFuture);

  final Future<LocalStorageService> _storageFuture;

  Future<List<DailyCashEntry>> fetchEntries() async {
    final storage = await _storageFuture;
    final data = await storage.readDailyCashEntries();
    return data.map(DailyCashEntry.fromJson).toList();
  }

  Future<void> persistEntries(List<DailyCashEntry> entries) async {
    final storage = await _storageFuture;
    await storage.writeDailyCashEntries(
      entries.map((entry) => entry.toJson()).toList(),
    );
  }
}
