import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/app_animations.dart';
import '../../core/enums/appointment_status.dart';
import '../../core/enums/appointment_type.dart';
import '../../providers/appointment_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/appointment_form.dart';

/// Appointment detail, edit, and status management screen.
class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final String appointmentId;

  void _showEditSheet(BuildContext context, WidgetRef ref, appointment) {
    AppAnimations.showBottomSheet(
      context: context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AppointmentForm(
          appointment: appointment,
          onSave: (updated) async {
            await ref
                .read(appointmentsNotifierProvider.notifier)
                .updateAppointment(updated);
            if (context.mounted) Navigator.pop(context);
          },
          onDelete: () async {
            final confirm = await showConfirmDialog(
              context,
              title: AppStrings.deleteAppointment,
              message: AppStrings.confirmDelete,
            );
            if (confirm == true) {
              await ref
                  .read(appointmentsNotifierProvider.notifier)
                  .delete(appointmentId);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) context.pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(
      FutureProvider(
        (ref) => ref.watch(appointmentRepositoryProvider).getById(appointmentId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appointments),
      ),
      body: appointmentAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(height: 300),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (appointment) {
          if (appointment == null) {
            return const Center(child: Text('Appointment not found'));
          }

          final type = AppointmentType.fromInt(appointment.appointmentType);
          final status = AppointmentStatus.fromInt(appointment.status);
          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: appointment.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(type.icon, color: appointment.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        if (appointment.providerName != null)
                          Text(
                            appointment.providerName!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ).staggerIn(0, stepMs: 0),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: AppStrings.date,
                value: DateFormat('EEEE, MMMM d, yyyy').format(appointment.date),
              ).staggerIn(1),
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: AppStrings.appointmentTime,
                value: '${appointment.time} (${appointment.durationMinutes} min)',
              ).staggerIn(2),
              if (appointment.location != null)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: AppStrings.location,
                  value: appointment.location!,
                ).staggerIn(3),
              _DetailRow(
                icon: type.icon,
                label: AppStrings.appointmentType,
                value: type.label,
              ).staggerIn(appointment.location != null ? 4 : 3),
              _DetailRow(
                icon: status.icon,
                label: AppStrings.status,
                value: status.label,
                valueColor: status.color,
              ).staggerIn(appointment.location != null ? 5 : 4),
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Update Status',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppointmentStatus.values.map((s) {
                  final selected = s == status;
                  return FilterChip(
                    selected: selected,
                    label: Text(s.label),
                    avatar: Icon(s.icon, size: 18, color: s.color),
                    onSelected: (_) async {
                      await ref
                          .read(appointmentsNotifierProvider.notifier)
                          .updateStatus(appointmentId, s);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showEditSheet(context, ref, appointment),
                icon: const Icon(Icons.edit_outlined),
                label: const Text(AppStrings.edit),
              ).staggerIn(6),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
