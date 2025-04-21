import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/task_model.dart';
import '../provider/task_provider.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Task'),
                content: Text('Are you sure you want to delete "${task.title}"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                ],
              ),
        );
      },
      onDismissed: (_) {
        try {
          Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${task.title} deleted')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
        }
      },
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) async {
            try {
              await Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(task);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error toggling task: $e')));
            }
          },
        ),
      ),
    );
  }
}
