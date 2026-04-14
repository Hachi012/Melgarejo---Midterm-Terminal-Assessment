class Task {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String status; // 'draft', 'synced', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = 'draft',
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'draft',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isSynced: json['isSynced'] is int
          ? (json['isSynced'] as int) == 1
          : (json['isSynced'] as bool? ?? false),
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
