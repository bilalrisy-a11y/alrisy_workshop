class Opening {
  final int? id;
  final int projectId;
  final String autoCode; // W01, W02, D01...
  final String type; // نافذة / باب
  final String category; // غرف، حمامات، مطابخ...
  final double width;
  final double height;
  final bool hasArch;
  final double? archSittingHeight;
  final double? archTotalHeight;
  final String? description;

  Opening({
    this.id,
    required this.projectId,
    required this.autoCode,
    required this.type,
    required this.category,
    required this.width,
    required this.height,
    this.hasArch = false,
    this.archSittingHeight,
    this.archTotalHeight,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'auto_code': autoCode,
      'type': type,
      'category': category,
      'width': width,
      'height': height,
      'has_arch': hasArch ? 1 : 0,
      'arch_sitting_height': archSittingHeight,
      'arch_total_height': archTotalHeight,
      'description': description,
    };
  }

  factory Opening.fromMap(Map<String, dynamic> map) {
    return Opening(
      id: map['id'],
      projectId: map['project_id'],
      autoCode: map['auto_code'],
      type: map['type'],
      category: map['category'],
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      hasArch: map['has_arch'] == 1,
      archSittingHeight: map['arch_sitting_height'] != null
          ? (map['arch_sitting_height'] as num).toDouble()
          : null,
      archTotalHeight: map['arch_total_height'] != null
          ? (map['arch_total_height'] as num).toDouble()
          : null,
      description: map['description'],
    );
  }
}
