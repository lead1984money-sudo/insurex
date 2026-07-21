import 'package:flutter/material.dart';
import 'model/reminder_master_model.dart';
import 'model/reminder_model.dart';

class ViewReminderDialog extends StatelessWidget {
  final Reminder reminder;
  final MasterData masterData;

  const ViewReminderDialog({
    Key? key,
    required this.reminder,
    required this.masterData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper to find category/type names from master data
    final category = masterData.categories.firstWhere(
          (cat) => cat.id == reminder.categoryId,
      orElse: () => masterData.categories.first,
    );
    final type = masterData.types.firstWhere(
          (type) => type.id == reminder.typeId,
      orElse: () => masterData.types.first,
    );
    final reminderBefore = masterData.reminderBeforeOptions.firstWhere(
          (rb) => rb.id == reminder.reminderBeforeId,
      orElse: () => masterData.reminderBeforeOptions.first,
    );

    // Format date
    final dateParts = reminder.eventDate.split('-');
    final formattedDate = dateParts.length == 3
        ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'
        : reminder.eventDate;

    // Format time
    String formattedTime = reminder.eventTime ?? '--';
    if (formattedTime.length == 5 && formattedTime.contains(':')) {
      final parts = formattedTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      formattedTime = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- Header ----------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xffF0F0F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'View Reminder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ---------- Body (Scrollable) ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section heading
                    const Text(
                      'Reminder Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff374151),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Category ----
                    _buildLabel('Category'),
                    const SizedBox(height: 4),
                    _buildValue(category.name),
                    const SizedBox(height: 16),

                    // ---- Type ----
                    _buildLabel('Type'),
                    const SizedBox(height: 4),
                    _buildValue(type.name),
                    const SizedBox(height: 16),

                    // ---- Title ----
                    _buildLabel('Title'),
                    const SizedBox(height: 4),
                    _buildValue(reminder.title),
                    const SizedBox(height: 16),

                    // ---- Description ----
                    _buildLabel('Description'),
                    const SizedBox(height: 4),
                    _buildValue(reminder.description ?? '—'),
                    const SizedBox(height: 16),

                    // ---- Date & Time Row ----
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              const SizedBox(height: 4),
                              _buildValue(formattedDate),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time'),
                              const SizedBox(height: 4),
                              _buildValue(formattedTime),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ---- Reminder Before ----
                    _buildLabel('Reminder Before'),
                    const SizedBox(height: 4),
                    _buildValue(reminderBefore.name),
                    const SizedBox(height: 20),

                    // ---- Notification Channels ----
                    const Text(
                      'Notification Channels',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xff374151),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: masterData.notificationChannels
                          .where((channel) =>
                          reminder.notificationChannels.contains(channel.value))
                          .map((channel) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            channel.label,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ---- Notes ----
                    _buildLabel('Notes'),
                    const SizedBox(height: 4),
                    _buildValue(reminder.notes ?? '—'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ---------- Footer (Close button) ----------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffF0F0F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Color(0xff6B7280),
      ),
    );
  }

  Widget _buildValue(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xff1F2937),
      ),
    );
  }
}