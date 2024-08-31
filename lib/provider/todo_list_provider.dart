import 'package:flutter/material.dart';
import 'package:flutterapp/modal/todo.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ToDoListProvider extends ChangeNotifier {
  final Box<ToDo> _todoBox = Hive.box<ToDo>('todoBox');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ToDo> get todos => _todoBox.values.toList();

  Future<void> addToDo(ToDo todo) async {
    await _todoBox.put(todo.id, todo);
    await _firestore.collection('todos').doc(todo.id).set({
      'title': todo.title,
      'description': todo.description,
      'isCompleted': todo.isCompleted,
    });
    notifyListeners();
  }

 Future<void> toggleCompletion(ToDo todo) async {
  todo.isCompleted = !todo.isCompleted;

  DocumentReference docRef = _firestore.collection('todos').doc(todo.id);

  await _todoBox.put(todo.id, todo); 
  await docRef.set({
    'title': todo.title,
    'description': todo.description,
    'isCompleted': todo.isCompleted,
  }, SetOptions(merge: true));  

  notifyListeners(); 
}

  Future<void> deleteToDo(ToDo todo) async {
    await _todoBox.delete(todo.id);
    await _firestore.collection('todos').doc(todo.id).delete();
    notifyListeners();
  }

  Future<void> fetchTodosFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('todos').get();

    for (var doc in snapshot.docs) {
      final todo = ToDo(
        id: doc.id,
        title: doc['title'],
        description: doc['description'],
        isCompleted: doc['isCompleted'],
      );
      _todoBox.put(todo.id, todo);
    }

    notifyListeners();
  }
}
