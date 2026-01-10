class DeviceInput {
  const DeviceInput({
    required this.customerName,
    required this.deviceName,
    required this.issue,
    required this.department,
    required this.employeeName,
    required this.status,
    required this.priorityColor,
    required this.cost,
  });

  final String customerName;
  final String deviceName;
  final String issue;
  final String department;
  final String employeeName;
  final String status;
  final String priorityColor;
  final String cost;

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'deviceName': deviceName,
      'issue': issue,
      'department': department,
      'employeeName': employeeName,
      'status': status,
      'priorityColor': priorityColor,
      'cost': cost,
    };
  }
}
