import 'package:flutter/material.dart';
import '../db_helper.dart';

class TaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  TaskScreen({this.task});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskController.text = widget.task!['task'];
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (widget.task == null) {
        // Insert new task
        await DBHelper().insertTask({
          'task': _taskController.text,
          'category': 'General',
          'dueDate': DateTime.now().toString(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task created successfully!')),
        );
      } else {
        // Update existing task
        final db = await DBHelper().database;
        await db.update(
          'tasks',
          {
            'task': _taskController.text,
            'category': 'General',
            'dueDate': widget.task!['dueDate']
          },
          where: 'id = ?',
          whereArgs: [widget.task!['id']],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully!')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _taskController,
                decoration: InputDecoration(labelText: 'Task'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Save Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
