# altalep_v2 – Light Department Desktop Dashboard

This repository now contains a production-grade Flutter (Windows desktop-first) implementation of the "قسم أعطال خفيفة" dashboard that mirrors the existing Next.js experience 1:1, including Supabase data access, Arabic RTL styling, and role-based permissions for admins and employees.

## Current mock-mode setup

To unblock UI development, the Supabase dependency has been removed temporarily. The repository now seeds in-memory demo data so you can exercise every workflow (filters, add/edit/delete, printing, employee management) without wiring any backend:

1. Run `flutter pub get`.
2. Launch the Windows desktop build with `flutter run -d windows`.
3. All device/employee operations mutate local lists only. Restarting the app resets the seed data.
4. When you're ready to reintroduce Supabase, rewire `LightDepartmentRepository` + `providers.dart` to use your API client again (the controller/state APIs stayed the same to make this drop-in).

## Screen wiring & navigation

The Light Department experience lives in `LightDepartmentScreen` and requires the following parameters:

```dart
LightDepartmentScreen(
  currentUserName: authenticatedEmployeeName,
  currentUserRole: UserRole.admin, // or UserRole.employee
  initialDepartment: 'أعطال خفيفة',
  onNavigateHome: () {
    // Close the current window, emit a desktop shell event,
    // or navigate back to your main dashboard route.
  },
)
```

`lib/app.dart` currently sets this screen as the `home` widget for clarity. In a full application:

1. Replace `home: LightDepartmentScreen(...)` with your root navigator/shell.
2. Push `LightDepartmentScreen` when the user chooses the "Light Department" dashboard, supplying the authenticated user/role and an `onNavigateHome` callback that pops to your root (or closes the window). The password modal (`PasswordDialog`) already calls that callback after the hard-coded `"admin"` password is confirmed; wire it to whatever "back to dashboard" behavior fits your desktop UX.

## Key folders & widgets

- `lib/features/light_dashboard/` – Data models, Supabase repository, Riverpod state controllers, and modular widgets:
  - `widgets/devices_table.dart` renders the RTL table with the same semantics seen in the provided screenshots (index column, customer/device/issue info, priority dot, new التكلفة column with inline editing, printer/delete/show buttons, etc.).
  - `widgets/device_entry_form.dart` exposes the green “إضافة جهاز جديد” form. Non-admins are automatically locked to their department and user identity, while admins can pick any department/employee/status/priority combination before saving. The form now includes a تكلفة field that feeds both the table and the label receipt.
  - `widgets/employee_management_panel.dart` mirrors the employee admin board (add employee + per-row delete/update buttons). Access can be toggled in the header actions.
  - `services/device_label_service.dart` generates the Arabic label layout (customer/device/issue/status/cost + received/delivery dates) and sends it to the system print dialog via the `printing` package. Plug your Windows XPrinter/XPrenter driver in the usual way; the TODO spot inside the controller/service is where you can swap in direct ESC/POS output if you prefer raw printer commands.
- Per-row “طباعة” buttons call the label service with the selected device, so technicians can stick a receipt like the provided sample. Make sure the `printing` package is allowed to display the system print dialog and the XPrinter is the default Windows printer, or wire up ESC/POS output if you need a silent flow.
- `lib/core/theme/app_theme.dart` – Global theme tuned for RTL Arabic with the Cairo font.
- `assets/logo.png` – Sidebar branding placeholder; replace with the production logo if available.

With the mock data in place, the Windows desktop build mirrors the requested dashboard: filters (date/status/employee/department), actions to migrate delivered devices (simply clears delivered rows locally), device creation with permissions, editable التكلفة column (showing on the label as well), per-row printing/deletion, and a dedicated employee management view. Reconnect the backend once the UI is signed off.
