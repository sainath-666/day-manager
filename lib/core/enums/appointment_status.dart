import 'package:flutter/material.dart';

/// Lifecycle status for an appointment.
enum AppointmentStatus {
  scheduled(0, 'Scheduled', Icons.event_outlined, Color(0xFF3B82F6)),
  confirmed(1, 'Confirmed', Icons.verified_outlined, Color(0xFF10B981)),
  completed(2, 'Completed', Icons.check_circle_outline, Color(0xFF6B7280)),
  cancelled(3, 'Cancelled', Icons.cancel_outlined, Color(0xFFEF4444));

  const AppointmentStatus(this.value, this.label, this.icon, this.color);

  final int value;
  final String label;
  final IconData icon;
  final Color color;

  static AppointmentStatus fromInt(int value) => AppointmentStatus.values
      .firstWhere((s) => s.value == value, orElse: () => AppointmentStatus.scheduled);

  bool get isActive => this == scheduled || this == confirmed;
}
