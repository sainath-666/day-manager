import 'package:flutter/material.dart';

/// Category of appointment.
enum AppointmentType {
  medical(0, 'Medical', Icons.medical_services_outlined),
  dental(1, 'Dental', Icons.health_and_safety_outlined),
  business(2, 'Business', Icons.business_center_outlined),
  personal(3, 'Personal', Icons.person_outline),
  other(4, 'Other', Icons.more_horiz);

  const AppointmentType(this.value, this.label, this.icon);

  final int value;
  final String label;
  final IconData icon;

  static AppointmentType fromInt(int value) => AppointmentType.values
      .firstWhere((t) => t.value == value, orElse: () => AppointmentType.other);
}
