import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> _tasks = []; // Список завдань
  final TextEditingController _controller = TextEditingController(); // Контролер для введення завдання
  bool _isAddingTask = false; // Статус, чи відображається поле для додавання завдання

  // Функція для додавання нового завдання
  void _addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.insert(0, task); // Додаємо завдання на початок списку
      });
      _controller.clear(); // Очищуємо поле після додавання
      setState(() {
        _isAddingTask = false; // Сховуємо поле вводу після додавання завдання
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isAddingTask = !_isAddingTask; // Перемикаємо видимість поля вводу
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Якщо _isAddingTask true, то показуємо поле вводу для завдання
            if (_isAddingTask)
              Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _addTask(_controller.text);
                    },
                    child: Text('Add Task'),
                    style: ButtonStyle(
                     ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            // Список завдань
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    title: Text(_tasks[index]),
                  );
                },
              ),
            ),
         ],
       ),
      ),
    );
  }
}
