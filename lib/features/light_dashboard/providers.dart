import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/light_department_repository.dart';
import 'domain/user_role.dart';
import 'notifiers/light_dashboard_controller.dart';
import 'notifiers/light_dashboard_state.dart';
import 'services/device_label_service.dart';

final lightRepositoryProvider = Provider<LightDepartmentRepository>((ref) {
  return LightDepartmentRepository();
});

final deviceLabelServiceProvider = Provider<DeviceLabelService>((ref) {
  return DeviceLabelService();
});

class LightDashboardArgs {
  const LightDashboardArgs({
    required this.department,
    required this.userRole,
    required this.userName,
  });

  final String department;
  final UserRole userRole;
  final String userName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LightDashboardArgs &&
        other.department == department &&
        other.userRole == userRole &&
        other.userName == userName;
  }

  @override
  int get hashCode => Object.hash(department, userRole, userName);
}

final lightDashboardControllerProvider = StateNotifierProvider.autoDispose
    .family<LightDashboardController, LightDashboardState, LightDashboardArgs>(
        (ref, args) {
  final repository = ref.watch(lightRepositoryProvider);
  final labelService = ref.watch(deviceLabelServiceProvider);
  final controller = LightDashboardController(
    repository: repository,
    labelService: labelService,
    currentDepartment: args.department,
    currentUserRole: args.userRole,
    currentUserName: args.userName,
  );
  controller.loadInitialData();
  return controller;
});
