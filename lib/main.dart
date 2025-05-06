import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  bool isDone;
  bool isLiked;

  Task(this.title, {this.isDone = false, this.isLiked = false});
}

enum TaskFilter { all, liked, done }

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

  TaskFilter currentFilter = TaskFilter.all;

  List<Task> get filteredTasks {
    switch (currentFilter) {
      case TaskFilter.liked:
        return tasks.where((task) => task.isLiked).toList();
      case TaskFilter.done:
        return tasks.where((task) => task.isDone).toList();
      case TaskFilter.all:
        return tasks;
    }
  }

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

  void _toggleLike(int index) {
    setState(() {
      tasks[index].isLiked = !tasks[index].isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Tarefas'),
        actions: [
          // Filtro de tarefas
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: "Filtrar tarefas",
            onSelected: (filter) {
              setState(() {
                currentFilter = filter;
              });
            },
            itemBuilder:
                (context) => [
                  CheckedPopupMenuItem(
                    value: TaskFilter.all,
                    checked: currentFilter == TaskFilter.all,
                    child: const Text("Todas"),
                  ),
                  CheckedPopupMenuItem(
                    value: TaskFilter.liked,
                    checked: currentFilter == TaskFilter.liked,
                    child: const Text("Curtidas"),
                  ),
                  CheckedPopupMenuItem(
                    value: TaskFilter.done,
                    checked: currentFilter == TaskFilter.done,
                    child: const Text("Concluídas"),
                  ),
                ],
          ),
          // Tema
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.color_lens),
            tooltip: "Configurar tema",
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
          // Campo de adição de tarefa
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
          // Lista de tarefas
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (_, index) {
                final task = filteredTasks[index];
                final taskIndex = tasks.indexOf(task);

                return ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => _toggleDone(taskIndex),
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
                        icon: Icon(
                          task.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: task.isLiked ? Colors.red : null,
                        ),
                        onPressed: () => _toggleLike(taskIndex),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTask(taskIndex),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(taskIndex),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${filteredTasks.length} tarefa(s)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
