import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_services.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  List<Task> displayedTasks = [];
  bool isLoading = true;
  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() {
      isLoading = true;
    });
    
    final loadedTasks = await TaskService.getTasks();
    
    setState(() {
      tasks = loadedTasks;
      _applyFilterAndSort();
      isLoading = false;
    });
  }

  void _applyFilterAndSort() {
    List<Task> result = List.from(tasks);
    
    if (currentFilter != null) {
      result = TaskService.filterTasks(result, currentFilter!);
    }
    
    if (currentSort != null) {
      result = TaskService.sortTasks(result, currentSort!);
    }
    
    setState(() {
      displayedTasks = result;
    });
  }

  Future<void> deleteTask(int id) async {
    bool success = await TaskService.deleteTask(id);
    if (success) {
      await loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      }
    }
  }

  Future<void> completeTask(int id) async {
    bool success = await TaskService.completeTask(id);
    if (success) {
      await loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed! 🎉')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          
          if (result == true) {
            await loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayedTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        currentFilter != null ? "No tasks match filter" : "No tasks yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentFilter != null 
                            ? "Tap filter icon to clear filter"
                            : "Tap the + button to add a task",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: displayedTasks.length,
                  itemBuilder: (context, index) {
                    final task = displayedTasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTaskScreen(task: task),
                            ),
                          );
                          if (result == true) {
                            await loadTasks();
                          }
                        },
                        leading: Icon(
                          task.status == "Completed"
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.status == "Completed" ? Colors.green : Colors.grey,
                          size: 28,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.status == "Completed"
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              task.description.isNotEmpty ? task.description : "No description",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: task.priority == "High"
                                        ? Colors.red.shade100
                                        : task.priority == "Medium"
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: task.priority == "High"
                                          ? Colors.red.shade800
                                          : task.priority == "Medium"
                                              ? Colors.orange.shade800
                                              : Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  task.deadline,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.label, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  task.status,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.status != "Completed")
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                onPressed: () => completeTask(task.id),
                                tooltip: 'Mark as completed',
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(task: task),
                                  ),
                                );
                                if (result == true) {
                                  await loadTasks();
                                }
                              },
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTask(task.id),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All'),
              onTap: () {
                currentFilter = null;
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed'),
              onTap: () {
                currentFilter = 'completed';
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending, color: Colors.orange),
              title: const Text('Not Completed'),
              onTap: () {
                currentFilter = 'not-completed';
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high, color: Colors.red),
              title: const Text('High Priority'),
              onTap: () {
                currentFilter = 'high-priority';
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('By Deadline'),
              onTap: () {
                currentSort = 'deadline';
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('By Priority'),
              onTap: () {
                currentSort = 'priority';
                Navigator.pop(context);
                _applyFilterAndSort();
              },
            ),
          ],
        ),
      ),
    );
  }
}