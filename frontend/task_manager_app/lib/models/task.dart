class Task {
  final String? id; // id is now optional (nullable)
  final String title;
  final String description;
  bool isCompleted;

  Task({
    this.id, // optional
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    print("Task JSON: $json");

    return Task(
      id: json['_id']?.toString(), // safely convert to string if exists
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
