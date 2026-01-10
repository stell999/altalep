enum UserRole {
  admin,
  employee;

  static UserRole fromString(String value) {
    return value == 'admin' ? UserRole.admin : UserRole.employee;
  }

  String get arabicLabel => this == UserRole.admin ? 'مشرف' : 'موظف';
}
