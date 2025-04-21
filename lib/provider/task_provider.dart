import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../model/task_model.dart';
import '../service/database_helper.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final String appGroupId = "group.homeScreenWidget";
  final String todoDataKey = "todo_data_key";
  final String iOSWidgetName = "MyHomeWidget";
  final String androidWidgetName = "AllTodoWidget";

  List<Task> _tasks = [];

  TaskProvider() {
    HomeWidget.setAppGroupId(appGroupId);
    _loadTasks();
  }

  List<Task> get tasks => _tasks;

  Future<void> _loadTasks() async {
    _tasks = await _databaseHelper.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _databaseHelper.insertTask(task);
    _tasks.add(task);
    notifyListeners();
    await updateTodoWidget();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _databaseHelper.updateTask(task);
    notifyListeners();
    await updateTodoWidget();
  }

  Future<void> deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await updateTodoWidget();
  }

  Future<void> updateTodoWidget() async {
    final taskData = _tasks
        .map((task) => {
              'id': task.id,
              'title': task.title,
              'isCompleted': task.isCompleted,
            })
        .toList();

    final jsonString = jsonEncode(taskData);
    await HomeWidget.saveWidgetData(todoDataKey, jsonString);
    await HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
}