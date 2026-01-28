import '../../../core/data/database_service.dart';
import 'package:flutter/foundation.dart';

import '../pos_dashboard_screen.dart' show ScreenBoardEntry;

class ScreenBoardRepository {
  ScreenBoardRepository() : _dbFuture = kIsWeb ? null : DatabaseService.create();
  final Future<DatabaseService>? _dbFuture;

  Future<List<_ScreenBoardRow>> fetch({String? search}) async {
    if (_dbFuture == null) return [];
    final db = await _dbFuture!;
    final rows = await db.queryScreenBoards(searchTerm: search);
    return rows
        .map((r) => _ScreenBoardRow(
              id: (r['id'] as int),
              entry: ScreenBoardEntry(
                boardOrScreen: (r['board'] ?? '-') as String,
                model: (r['model'] ?? '-') as String,
                quantity: (r['quantity'] ?? 0) as int,
                unitUsd: ((r['unit_usd'] ?? 0.0) as num).toDouble(),
                sold: (r['sold'] ?? 0) as int,
                notes: (r['notes'] ?? '-') as String,
              ),
            ))
        .toList();
  }

  Future<int?> insert(ScreenBoardEntry e) async {
    if (_dbFuture == null) return null;
    final db = await _dbFuture!;
    final id = await db.insertScreenBoard(
      board: e.boardOrScreen,
      model: e.model,
      quantity: e.quantity,
      unitUsd: e.unitUsd,
      sold: e.sold,
      notes: e.notes,
    );
    return id;
  }

  Future<void> updateQtySold(int id, int quantity, int sold) async {
    if (_dbFuture == null) return;
    final db = await _dbFuture!;
    await db.updateScreenBoardQtySold(id: id, quantity: quantity, sold: sold);
  }
}

class _ScreenBoardRow {
  const _ScreenBoardRow({required this.id, required this.entry});
  final int id;
  final ScreenBoardEntry entry;
}
