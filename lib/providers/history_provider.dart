import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_entry.dart';
import '../utils/constants.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryEntry> _history = [];

  List<HistoryEntry> get history => _history;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final box = Hive.isBoxOpen(AppConstants.historyBox)
          ? Hive.box<HistoryEntry>(AppConstants.historyBox)
          : await Hive.openBox<HistoryEntry>(AppConstants.historyBox);
      _history = box.values.toList();
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      // If box is already open as Box<dynamic>, just use the existing box
      try {
        final box = await Hive.openBox<HistoryEntry>(AppConstants.historyBox);
        _history = box.values.toList();
        _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      } catch (error) {
        // Log error: 'Error loading history: $error'
      }
    }
  }

  Future<void> addEntry(
      String expression, String result, String calculatorType) async {
    final entry = HistoryEntry(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
      calculatorType: calculatorType,
    );

    try {
      final box = await Hive.openBox<HistoryEntry>(AppConstants.historyBox);
      await box.add(entry);
      _history.insert(0, entry);
      notifyListeners();
    } catch (e) {
      // If there's an error saving to history, just update the local list
      _history.insert(0, entry);
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    final box = await Hive.openBox<HistoryEntry>(AppConstants.historyBox);
    await box.clear();

    _history.clear();
    notifyListeners();
  }

  Future<void> deleteEntry(int index) async {
    final box = await Hive.openBox<HistoryEntry>(AppConstants.historyBox);
    final entry = _history[index];
    await box.delete(entry.key);

    _history.removeAt(index);
    notifyListeners();
  }
}
