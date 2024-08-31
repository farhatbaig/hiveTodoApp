import 'package:flutter/material.dart';
import 'package:flutterapp/modal/todo.dart';
import 'package:flutterapp/provider/todo_list_provider.dart';
import 'package:provider/provider.dart';

class ToDoListScreen extends StatelessWidget {
  const ToDoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              Provider.of<ToDoListProvider>(context, listen: false)
                  .fetchTodosFromFirestore();
            },
          ),
        ],
      ),
      body: Consumer<ToDoListProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return ListTile(
                title: Text(todo.title),
                subtitle: Text(todo.description),
                trailing: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (value) {
                    provider.toggleCompletion(todo);
                  },
                ),
                onLongPress: () {
                  provider.deleteToDo(todo);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddToDoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddToDoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ToDo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final todo = ToDo(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                );
                Provider.of<ToDoListProvider>(context, listen: false)
                    .addToDo(todo);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
