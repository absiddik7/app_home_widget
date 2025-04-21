import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:home_widget_practice/widgets/task_list_item.dart';

import '../model/task_model.dart';
import '../provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  String appGroupId = "group.homeScreenWidget";
  String iOSWidgetName = "MyHomeWidget";
  String androidWidgetName = "TodoWidget";
  String androidWidgetName2 = "AllTodoWidget";
  String dataKey = "text_from_flutter";
  String todoDataKey = "todo_data_key";

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
  }

  void incrementCounter() async {
    setState(() {
      _counter++;
    });
    String data = "Cont = $_counter";
    await HomeWidget.saveWidgetData(dataKey, data);
    await HomeWidget.updateWidget(
      name: iOSWidgetName,
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
      qualifiedAndroidName: "com.example.home_widget_practice.AllTodoWidget",
    );
  }

  void updateTodoWidget(List<Task> tasks) async {
    final taskData =
        tasks.map((task) => {'id': task.id, 'title': task.title, 'isCompleted': task.isCompleted}).toList();

    final jsonString = jsonEncode(taskData);
    await HomeWidget.saveWidgetData(todoDataKey, jsonString);
    await HomeWidget.updateWidget(iOSName: iOSWidgetName, androidName: androidWidgetName2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return FutureBuilder<List<Task>>(
            future: taskProvider.tasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks available'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return TaskListItem(task: snapshot.data![index]);
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          incrementCounter();
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter task description'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(
                    Task(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: controller.text,
                      isCompleted: false,
                    ),
                  );
                  final tasks = await Provider.of<TaskProvider>(context, listen: false).tasks;
                  updateTodoWidget(tasks);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
