class Task {
  final int id;
  final String title;
  final String description;
  final String deadline;
  final String priority;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing task from JSON: $json');
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] ?? '',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'ToDo',
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      "id": id,
      "title": title,
      "description": description,
      "deadline": deadline,
      "priority": priority,
      "status": status,
    };
    print('📤 Converting task to JSON: $json');
    return json;
  }
}