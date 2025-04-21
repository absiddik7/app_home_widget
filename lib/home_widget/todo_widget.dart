import 'dart:convert';

import 'package:home_widget_practice/model/task_model.dart';
import 'package:home_widget_practice/service/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class TodoWidget extends StatefulWidget {
  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  List<Task> _tasks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    HomeWidget.widgetClicked.listen(_onWidgetClick);
  }

  void _onWidgetClick(Uri? uri) {
    if (uri != null) {
      // Handle widget click here - possibly toggle a task
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    final tasks = await _databaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
    _updateWidget();
  }

  Future<void> _updateWidget() async {
    try {
      // Convert tasks to simple format for widget
      List<Map<String, dynamic>> simpleTasks =
          _tasks
              .map((task) => {'id': task.id, 'title': task.title, 'isCompleted': task.isCompleted ? 1 : 0})
              .toList();

      await HomeWidget.saveWidgetData<String>('tasks', jsonEncode(simpleTasks));
      await HomeWidget.updateWidget(
        name: 'TodoWidgetProvider',
        androidName: 'TodoWidgetProvider',
        iOSName: 'TodoWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints.expand(),
      child:
          _tasks.isEmpty
              ? const Center(child: Text('No tasks'))
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Row(
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) async {
                          task.isCompleted = value ?? false;
                          await _databaseHelper.updateTask(task);
                          _loadTasks();
                        },
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
