import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  bool isDone;

  Task(this.title, {this.isDone = false});
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Lista de Tarefas',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          home: TaskListScreen(
            onThemeChanged: (mode) {
              themeNotifier.value = mode;
            },
            currentTheme: currentTheme,
          ),
        );
      },
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final ThemeMode currentTheme;

  const TaskListScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String title) {
    if (title.isEmpty) return;
    setState(() {
      tasks.add(Task(title));
    });
    _taskController.clear();
  }

  void _editTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: tasks[index].title,
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editar Tarefa"),
            content: TextField(controller: editController, autofocus: true),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tasks[index].title = editController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.currentTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Tarefas'),
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.color_lens),
            tooltip: "Definição do Tema",
            onSelected: widget.onThemeChanged,
            itemBuilder:
                (context) => [
                  CheckedPopupMenuItem(
                    value: ThemeMode.system,
                    checked: theme == ThemeMode.system,
                    child: const Text("Sistema"),
                  ),
                  CheckedPopupMenuItem(
                    value: ThemeMode.light,
                    checked: theme == ThemeMode.light,
                    child: const Text("Claro"),
                  ),
                  CheckedPopupMenuItem(
                    value: ThemeMode.dark,
                    checked: theme == ThemeMode.dark,
                    child: const Text("Escuro"),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(labelText: 'Nova Tarefa'),
                    onSubmitted: _addTask,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_taskController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => _toggleDone(index),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTask(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
