class Project {
  final int? id;
  final int customerId;
  final String projectName;
  final String? notes;

  Project({
    this.id,
    required this.customerId,
    required this.projectName,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'project_name': projectName,
      'notes': notes,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      customerId: map['customer_id'],
      projectName: map['project_name'],
      notes: map['notes'],
    );
  }
}
