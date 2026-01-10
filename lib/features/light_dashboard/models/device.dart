class Device {
  const Device({
    required this.id,
    required this.customerName,
    required this.deviceName,
    required this.issue,
    required this.department,
    required this.employeeName,
    required this.status,
    required this.priorityColor,
    required this.date,
    required this.time,
    required this.deliveredDate,
    required this.deliveredTime,
    required this.cost,
    required this.createdAt,
  });

  final String id;
  final String customerName;
  final String deviceName;
  final String issue;
  final String department;
  final String employeeName;
  final String status;
  final String priorityColor;
  final String date;
  final String time;
  final String deliveredDate;
  final String deliveredTime;
  final String cost;
  final DateTime? createdAt;

  bool get hasAssignedEmployee => employeeName.isNotEmpty;

  String get formattedCustomer => customerName.isEmpty ? '-' : customerName;

  factory Device.fromJson(Map<String, dynamic> map) {
    final createdValue = map['created_at'] ?? map['createdAt'];
    return Device(
      id: '${map['id']}',
      customerName: (map['customerName'] ?? '') as String,
      deviceName: (map['deviceName'] ?? '') as String,
      issue: (map['issue'] ?? '') as String,
      department: (map['department'] ?? '') as String,
      employeeName: (map['employeeName'] ?? '') as String,
      status: (map['status'] ?? '') as String,
      priorityColor: (map['priorityColor'] ?? '') as String,
      date: (map['date'] ?? '') as String,
      time: (map['time'] ?? '') as String,
      deliveredDate: (map['deliveredDate'] ?? '') as String,
      deliveredTime: (map['deliveredTime'] ?? '') as String,
      cost: (map['cost'] ?? '') as String,
      createdAt: createdValue == null
          ? null
          : DateTime.tryParse('$createdValue'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'deviceName': deviceName,
      'issue': issue,
      'department': department,
      'employeeName': employeeName,
      'status': status,
      'priorityColor': priorityColor,
      'date': date,
      'time': time,
      'deliveredDate': deliveredDate,
      'deliveredTime': deliveredTime,
      'cost': cost,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Device copyWith({
    String? department,
    String? employeeName,
    String? status,
    String? cost,
    String? deliveredDate,
    String? deliveredTime,
  }) {
    return Device(
      id: id,
      customerName: customerName,
      deviceName: deviceName,
      issue: issue,
      department: department ?? this.department,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      priorityColor: priorityColor,
      date: date,
      time: time,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      deliveredTime: deliveredTime ?? this.deliveredTime,
      cost: cost ?? this.cost,
      createdAt: createdAt,
    );
  }
}
