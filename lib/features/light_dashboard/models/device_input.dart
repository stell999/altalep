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
    required this.costCurrency,
  });

  final String customerName;
  final String deviceName;
  final String issue;
  final String department;
  final String employeeName;
  final String status;
  final String priorityColor;
  final String cost;
  final String costCurrency;

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
      'costCurrency': costCurrency,
    };
  }
}
