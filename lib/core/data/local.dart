// lib/core/data/data_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../model/task.dart';

class DataRepository {
  static const String _fileName = 'tasks.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
    return [];
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final file = await _getLocalFile();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }
}
