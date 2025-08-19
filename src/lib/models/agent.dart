class Agent {
  final String id;
  final String name;
  final String? description;
  final String instruction;
  final String model;
  final String color;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Agent({
    required this.id,
    required this.name,
    this.description,
    required this.instruction,
    required this.model,
    required this.color,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instruction: json['instruction'],
      model: json['model'],
      color: json['color'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instruction': instruction,
      'model': model,
      'color': color,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
