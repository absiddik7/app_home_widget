import '../model/task_model.dart';
import '../service/database_helper.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Task> _tasks = [];
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    final tasks = await _databaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: _tasks.isEmpty
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
                        style: TextStyle(
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}