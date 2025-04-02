import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => TodoCubit()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: TodoListScreen(),
    );
  }
}

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// Cubit для управління списком задач
class TodoCubit extends Cubit<List<Map<String, dynamic>>> {
  TodoCubit() : super([]);

  void addTask(String title, TickerProvider vsync) {
    AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 300),
    );
    final newTask = {
      'title': title,
      'isCompleted': false,
      'animationController': animationController,
    };
    animationController.forward();
    emit([newTask, ...state]);
  }

  void removeTask(int index) {
    state[index]['animationController'].reverse().then((_) {
      final newState = List<Map<String, dynamic>>.from(state)..removeAt(index);
      emit(newState);
    });
  }

  void toggleTask(int index) {
    final newState = List<Map<String, dynamic>>.from(state);
    newState[index]['isCompleted'] = !newState[index]['isCompleted'];
    emit(newState);
  }

  void reorderTasks(int oldIndex, int newIndex) {
    final newState = List<Map<String, dynamic>>.from(state);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);
    emit(newState);
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isAddingTask = false;
  bool _isButtonEnabled = false;

  void _addTask() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<TodoCubit>().addTask(_controller.text.trim(), this);
      _controller.clear();
      setState(() {
        _isAddingTask = false;
        _isButtonEnabled = false;
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
            icon: Icon(_isAddingTask ? Icons.cancel_outlined : Icons.add),
            onPressed: () => setState(() => _isAddingTask = !_isAddingTask),
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
                    onChanged: (text) => setState(() => _isButtonEnabled = text.trim().isNotEmpty),
                    decoration: InputDecoration(
                      labelText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isButtonEnabled ? _addTask : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? Colors.green : Colors.grey.shade300,
                      foregroundColor: _isButtonEnabled ? Colors.white : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Add Task'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<TodoCubit, List<Map<String, dynamic>>>(
                builder: (context, tasks) {
                  return ReorderableListView(
                    onReorder: (oldIndex, newIndex) => context.read<TodoCubit>().reorderTasks(oldIndex, newIndex),
                    children: tasks.asMap().entries.map((entry) {
                      int index = entry.key;
                      var task = entry.value;
                      return AnimatedBuilder(
                        key: ValueKey(task['title']),
                        animation: task['animationController'],
                        builder: (context, child) {
                          return Opacity(
                            opacity: task['animationController'].value,
                            child: ListTile(
                              leading: Checkbox(
                                value: task['isCompleted'],
                                onChanged: (_) => context.read<TodoCubit>().toggleTask(index),
                              ),
                              title: AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: Colors.black, 
                                  decoration: task['isCompleted'] ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                                child: Text(task['title']),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    context.read<TodoCubit>().removeTask(index);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
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
