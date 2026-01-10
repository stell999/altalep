class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.department,
  });

  final String id;
  final String name;
  final String department;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: '${json['id']}',
      name: (json['name'] ?? '') as String,
      department: (json['department'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'department': department};
  }

  Employee copyWith({String? department}) {
    return Employee(
      id: id,
      name: name,
      department: department ?? this.department,
    );
  }
}
