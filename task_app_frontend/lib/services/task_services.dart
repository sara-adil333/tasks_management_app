import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class TaskService {
  static const String fileName = "tasks.json";
  
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  static Future<List<Task>> getTasks() async {
    try {
      final file = await _getFile();
      
      if (!await file.exists()) {
        developer.log('File $fileName not found!', name: 'TaskService');
        return [];
      }
      
      final contents = await file.readAsString();
      developer.log('File contents: $contents', name: 'TaskService');
      
      if (contents.trim().isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Task.fromJson(json)).toList();
      
    } catch (e) {
      developer.log('Error reading tasks.json: ${e.toString()}', name: 'TaskService');
      return [];
    }
  }

  static Future<bool> _saveTasks(List<Task> tasks) async {
    try {
      final file = await _getFile();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      final contents = jsonEncode(jsonList);
      await file.writeAsString(contents);
      developer.log('Tasks saved to tasks.json', name: 'TaskService');
      return true;
    } catch (e) {
      developer.log('Error saving to tasks.json: ${e.toString()}', name: 'TaskService');
      return false;
    }
  }

  static Future<bool> addTask(Task task) async {
    try {
      final tasks = await getTasks();
      
      final newId = tasks.isEmpty ? 1 : (tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);
      
      final newTask = Task(
        id: newId,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        priority: task.priority,
        status: "ToDo",
      );
      
      tasks.add(newTask);
      return await _saveTasks(tasks);
      
    } catch (e) {
      developer.log('Error adding task: ${e.toString()}', name: 'TaskService');
      return false;
    }
  }

  static Future<bool> updateTask(int id, Task updatedTask) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == id);
      
      if (index != -1) {
        tasks[index] = Task(
          id: id,
          title: updatedTask.title,
          description: updatedTask.description,
          deadline: updatedTask.deadline,
          priority: updatedTask.priority,
          status: updatedTask.status,
        );
        return await _saveTasks(tasks);
      }
      
      return false;
      
    } catch (e) {
      developer.log('Error updating task: ${e.toString()}', name: 'TaskService');
      return false;
    }
  }

  static Future<bool> deleteTask(int id) async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((t) => t.id == id);
      return await _saveTasks(tasks);
      
    } catch (e) {
      developer.log('Error deleting task: ${e.toString()}', name: 'TaskService');
      return false;
    }
  }

  static Future<bool> completeTask(int id) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == id);
      
      if (index != -1) {
        tasks[index] = Task(
          id: tasks[index].id,
          title: tasks[index].title,
          description: tasks[index].description,
          deadline: tasks[index].deadline,
          priority: tasks[index].priority,
          status: "Completed",
        );
        return await _saveTasks(tasks);
      }
      
      return false;
      
    } catch (e) {
      developer.log('Error completing task: ${e.toString()}', name: 'TaskService');
      return false;
    }
  }

  static Future<String?> exportTasks(List<Task> tasks) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      final buffer = StringBuffer();
      buffer.writeln("===== TASKS EXPORT =====");
      buffer.writeln();
      buffer.writeln("Generated: ${DateTime.now()}");
      buffer.writeln("Total Tasks: ${tasks.length}");
      buffer.writeln();
      
      for (var task in tasks) {
        buffer.writeln("─────────────────────────");
        buffer.writeln("ID: ${task.id}");
        buffer.writeln("Title: ${task.title}");
        buffer.writeln("Description: ${task.description}");
        buffer.writeln("Deadline: ${task.deadline}");
        buffer.writeln("Priority: ${task.priority}");
        buffer.writeln("Status: ${task.status}");
        buffer.writeln("─────────────────────────");
        buffer.writeln();
      }
      
      await file.writeAsString(buffer.toString());
      return file.path;
      
    } catch (e) {
      developer.log('Error exporting tasks: ${e.toString()}', name: 'TaskService');
      return null;
    }
  }

  static List<Task> sortTasks(List<Task> tasks, String sortBy) {
    final List<Task> sortedTasks = List.from(tasks);
    
    if (sortBy == "deadline") {
      sortedTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else if (sortBy == "priority") {
      final priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
      sortedTasks.sort((a, b) => 
        priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!)
      );
    }
    
    return sortedTasks;
  }

  static List<Task> filterTasks(List<Task> tasks, String filterBy) {
    switch (filterBy.toLowerCase()) {
      case 'completed':
        return tasks.where((t) => t.status == "Completed").toList();
      case 'not-completed':
        return tasks.where((t) => t.status != "Completed").toList();
      case 'high-priority':
        return tasks.where((t) => t.priority == "High").toList();
      default:
        return tasks;
    }
  }
  
  static Future<String> getTasksFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}