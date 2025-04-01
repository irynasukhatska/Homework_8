import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      themeMode: ThemeMode.system,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  bool _isAddingTask = false;
  bool _isButtonEnabled = false;
  
  get onSelected => null;

  // Метод для додавання нового завдання
  void _addTask() {
    if (_controller.text.trim().isNotEmpty) {
      // Створення нового AnimationController для анімації кожного елементу
      AnimationController animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
      );

      // Додавання нового завдання в список
      setState(() {
        _tasks.insert(0, {
          'title': _controller.text.trim(),
          'isCompleted': false,
          'animationController': animationController,
        });

        // Запускаємо анімацію для нового завдання
        animationController.forward();
      });

      // Очищуємо поле вводу після додавання завдання
      _controller.clear();
      _isAddingTask = false;
      _isButtonEnabled = false;
    }
  }

  // Метод для видалення завдання
  void _removeTask(int index) {
    // Спочатку виконуємо анімацію видалення (зворотній рух)
    setState(() {
      _tasks[index]['animationController'].reverse().then((_) {
        setState(() {
          _tasks.removeAt(index); // Видаляємо елемент після завершення анімації
        });
      });
    });
  }

  // Метод для показу меню завдання (видалення завдання)
  void _showTaskMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Task'),
                onTap: () {
                  Navigator.pop(context);
                  _removeTask(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Переміщення завдання в нове місце
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(_isAddingTask ? Icons.cancel_outlined : Icons.add),
            onPressed: () {
              setState(() {
                _isAddingTask = !_isAddingTask;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_isAddingTask)
              Column(
                children: [
                  TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {
                        _isButtonEnabled = text.trim().isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isButtonEnabled ? _addTask : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey.shade300;
                          }
                          return Colors.green;
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey;
                          }
                          return Colors.white;
                        },
                      ),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
                    ),
                    child: Text('Add Task'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Expanded(
              child: ReorderableListView(
                onReorder: _onReorder, // Це функція для обробки перетягування
                children: _tasks.map((task) {
                  int index = _tasks.indexOf(task);
                  return AnimatedBuilder(
                    key: ValueKey(task['title']), // Це важливо для правильного відображення
                    animation: task['animationController'],
                    builder: (context, child) {
                      return Opacity(
                        opacity: task['animationController'].value,
                        child: ListTile(
                          leading: Checkbox(
                            value: task['isCompleted'],
                            onChanged: (bool? value) {
                              setState(() {
                                task['isCompleted'] = value!;
                              });
                            },
                          ),
                          title: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 300),
                            style: TextStyle(
                              color: task['isCompleted'] ? Colors.grey : Colors.black,
                              decoration: task['isCompleted']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(task['title']),
                          ),
                          trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _removeTask(index);
                            };
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row (
                                children:[
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete Task'),
                                ],
                              ),
                            ),
                          ],
                         ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
