import 'package:flutter/material.dart';

class LightConstants {
  static const departments = [
    'مطفي',
    'شاشات',
    'سوفت وير',
    'معالجات',
    'أعطال خفيفة',
  ];

  static const statusOptions = [
    'جاري العمل',
    'تم الإصلاح',
    'تم التسليم',
    'لا يصلح',
    'انتظار',
    'زبون مابدو',
    'صلح',
    'مرتجع',
  ];

  static const priorityColors = [
    'أحمر',
    'أصفر',
    'برتقالي',
    'أخضر',
  ];

  static const adminSender = 'admin';
}

Color mapPriorityColor(String? label) {
  switch (label) {
    case 'أحمر':
      return Colors.redAccent;
    case 'أصفر':
    case 'برتقالي':
      return Colors.orangeAccent;
    case 'أخضر':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
