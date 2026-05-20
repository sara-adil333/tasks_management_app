import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // طباعة موقع ملف المهام
  final directory = await getApplicationDocumentsDirectory();
  print('📁 موقع حفظ المهام: ${directory.path}/tasks.json');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(),
    );
  }
}