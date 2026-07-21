import 'package:flutter/material.dart';
import 'package:pdf_read/screen/reminder/model/reminder_master_model.dart';
import 'package:pdf_read/screen/reminder/provider/ReminderProvider.dart';
import 'package:provider/provider.dart';

class WishesScreen extends StatefulWidget {
  final MasterData? masterData;
  final String? categoryID;

  const WishesScreen({super.key, this.masterData, this.categoryID});

  @override
  State<WishesScreen> createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? selectedTypeId;
  String? selectedReminderBeforeId;

  final Set<String> _selectedChannels = {};

  List<Type> get _typesForCategory {
    if (widget.categoryID == null || widget.masterData == null) return [];
    return widget.masterData!.types
        .where((type) => type.categoryId.toString() == widget.categoryID.toString())
        .toList();
  }

  List<NotificationChannel> get _channels {
    return widget.masterData?.notificationChannels ?? [];
  }

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    print("Category ID: ${widget.categoryID}");
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Add Reminder",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // TYPE DROPDOWN
              const Text(
                "Select Type *",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildDropdown<String>(
                value: selectedTypeId,
                hint: _typesForCategory.isEmpty ? "No types available" : "Select type",
                items: _typesForCategory.map((type) {
                  return DropdownMenuItem<String>(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedTypeId = value),
              ),
              const SizedBox(height: 18),

              // REMINDER BEFORE DROPDOWN
              const Text(
                "Reminder Before *",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildDropdown<String>(
                value: selectedReminderBeforeId,
                hint: "Select reminder time",
                items: (widget.masterData?.reminderBeforeOptions ?? []).map((option) {
                  return DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(option.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedReminderBeforeId = value),
              ),
              const SizedBox(height: 18),

              // TITLE
              const Text(
                "Title *",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _textField(
                controller: titleController,
                hint: "Enter title",
              ),
              const SizedBox(height: 18),

              // DESCRIPTION
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _textField(
                controller: descriptionController,
                hint: "Enter description (optional)",
                maxLines: 4,
              ),
              const SizedBox(height: 18),

              // DATE
              const Text(
                "Date *",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: pickDate,
                child: _pickerField(
                  text: selectedDate == null
                      ? "Select date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // TIME
              const Text(
                "Time *",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: pickTime,
                child: _pickerField(
                  text: selectedTime == null
                      ? "Select time"
                      : selectedTime!.format(context),
                  icon: Icons.access_time_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // NOTIFICATION CHANNELS
              const Text(
                "Notification Channels *",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildNotificationChannels(),
              const SizedBox(height: 18),

              // NOTES
              const Text(
                "Notes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _textField(
                controller: notesController,
                hint: "Enter additional notes (optional)",
                maxLines: 3,
              ),
              const SizedBox(height: 35),

              // NEXT BUTTON
              Consumer<ReminderProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: provider.isCreating
                          ? null
                          : () async {
                        // Validate
                        if (selectedTypeId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select type')),
                          );
                          return;
                        }
                        if (selectedReminderBeforeId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select reminder time')),
                          );
                          return;
                        }
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter title')),
                          );
                          return;
                        }
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select date')),
                          );
                          return;
                        }
                        if (selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select time')),
                          );
                          return;
                        }
                        if (_selectedChannels.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least one channel')),
                          );
                          return;
                        }

                        final success = await provider.createReminder(
                          categoryId: widget.categoryID!,
                          typeId: selectedTypeId!,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          eventDate: _formatDate(selectedDate!),
                          eventTime: _formatTime(selectedTime!),
                          reminderBeforeId: selectedReminderBeforeId!,
                          notificationChannels: _selectedChannels.toList(),
                          notes: notesController.text.trim(),
                          status: 1,
                        );

                        if (success) {
                          // Pop and refresh
                          Navigator.pop(context, true);
                          // Optionally call provider.fetchAllData() in the dashboard using a callback
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: provider.isCreating
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xff3563FF), Color(0xff2151F5)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- NOTIFICATION CHANNELS WIDGET ----------
  Widget _buildNotificationChannels() {
    final channels = _channels;
    if (channels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "No channels available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: channels.map((channel) {
          final isSelected = _selectedChannels.contains(channel.value);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedChannels.add(channel.value);
                      } else {
                        _selectedChannels.remove(channel.value);
                      }
                    });
                  },
                  activeColor: const Color(0xff3563FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                channel.label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ---------- REUSABLE DROPDOWN ----------
  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(
          color: items.isEmpty ? Colors.red : Colors.grey,
        ),
      ),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff3563FF), width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  // ---------- REUSABLE TEXT FIELD ----------
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff3563FF), width: 1.5),
        ),
      ),
    );
  }

  // ---------- REUSABLE PICKER FIELD ----------
  Widget _pickerField({
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: text.contains("Select") ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Icon(icon, color: Colors.grey.shade700),
        ],
      ),
    );
  }
}