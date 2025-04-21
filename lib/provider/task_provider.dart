import '../model/task_model.dart';
import 'package:home_widget_practice/service/database_helper.dart';
import 'package:flutter/foundation.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Task>> get tasks async {
    return await _databaseHelper.getTasks();
  }

  Future<void> addTask(Task task) async {
    await _databaseHelper.insertTask(task);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _databaseHelper.updateTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    notifyListeners();
  }
}
