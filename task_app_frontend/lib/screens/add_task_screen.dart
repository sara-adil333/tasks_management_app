import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_services.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final deadlineController = TextEditingController();
  String priority = "Medium";
  bool isLoading = false;

  Future<void> saveTask() async {
    // التحقق من إدخال العنوان
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    print('=== بدء حفظ المهمة ===');
    print('Title: ${titleController.text}');
    print('Description: ${descController.text}');
    print('Deadline: ${deadlineController.text}');
    print('Priority: $priority');

    Task task = Task(
      id: 0, // ID سيتولد تلقائياً في TaskService
      title: titleController.text,
      description: descController.text,
      deadline: deadlineController.text.isEmpty 
          ? DateTime.now().toIso8601String().split('T')[0]
          : deadlineController.text,
      priority: priority,
      status: "ToDo",
    );

    bool success = await TaskService.addTask(task);
    
    print('Result: $success');
    
    setState(() {
      isLoading = false;
    });

    if (success) {
      print('✅ تمت الإضافة بنجاح');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      print('❌ فشلت الإضافة');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add task. Check console for errors.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Task"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Task Title *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Deadline (YYYY-MM-DD)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: "2024-12-31",
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: priority,
                  isExpanded: true,
                  items: ["High", "Medium", "Low"]
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(
                                  p == "High" ? Icons.priority_high :
                                  p == "Medium" ? Icons.trending_flat :
                                  Icons.low_priority,
                                  color: p == "High" ? Colors.red :
                                         p == "Medium" ? Colors.orange :
                                         Colors.green,
                                ),
                                const SizedBox(width: 10),
                                Text(p),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      priority = val!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Task", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    deadlineController.dispose();
    super.dispose();
  }
}