import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/reminder_master_model.dart';
import 'model/reminder_model.dart';
import 'provider/ReminderProvider.dart';

class EditReminderDialog extends StatefulWidget {
  final Reminder reminder;
  final MasterData masterData;

  const EditReminderDialog({
    Key? key,
    required this.reminder,
    required this.masterData,
  }) : super(key: key);

  @override
  State<EditReminderDialog> createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<EditReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  late Category? _selectedCategory;
  late Type? _selectedType;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late ReminderBefore? _selectedReminderBefore;
  late Set<String> _selectedChannels;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController = TextEditingController(text: reminder.title);
    _descriptionController = TextEditingController(text: reminder.description ?? '');
    _notesController = TextEditingController(text: reminder.notes ?? '');

    _selectedCategory = widget.masterData.categories.firstWhere(
          (cat) => cat.id == reminder.categoryId,
      orElse: () => widget.masterData.categories.first,
    );

    _selectedType = widget.masterData.types.firstWhere(
          (type) => type.id == reminder.typeId,
      orElse: () => widget.masterData.types.first,
    );

    try {
      _selectedDate = DateTime.parse(reminder.eventDate);
    } catch (_) {
      _selectedDate = DateTime.now();
    }

    if (reminder.eventTime != null && reminder.eventTime!.isNotEmpty) {
      final parts = reminder.eventTime!.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      _selectedTime = TimeOfDay.now();
    }

    _selectedReminderBefore = widget.masterData.reminderBeforeOptions.firstWhere(
          (rb) => rb.id == reminder.reminderBeforeId,
      orElse: () => widget.masterData.reminderBeforeOptions.first,
    );

    _selectedChannels = Set<String>.from(reminder.notificationChannels ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Type> get _filteredTypes {
    if (_selectedCategory == null) return [];
    return widget.masterData.types
        .where((type) => type.categoryId == _selectedCategory!.id)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'id': widget.reminder.id,
      'category_id': _selectedCategory!.id,
      'type_id': _selectedType?.id ?? '',
      'title': _titleController.text,
      'description': _descriptionController.text,
      'notes': _notesController.text,
      'event_date': _selectedDate?.toIso8601String().split('T').first ?? '',
      'event_time': _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '',
      'reminder_before_id': _selectedReminderBefore?.id ?? '',
      'notification_channels': _selectedChannels.toList(),
    };

    final success = await context.read<ReminderProvider>().updateReminder(payload);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update reminder')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Edit Reminder',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Section heading ----
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
                      _buildLabel('Category *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: _inputDecoration('Select Category'),
                        items: widget.masterData.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (newCat) {
                          setState(() {
                            _selectedCategory = newCat;
                            if (_selectedType != null &&
                                _selectedType!.categoryId != newCat?.id) {
                              _selectedType = null;
                            }
                          });
                        },
                        validator: (val) =>
                        val == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),

                      // ---- Type ----
                      _buildLabel('Type *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Type>(
                        value: _selectedType,
                        decoration: _inputDecoration('Select Type'),
                        items: _filteredTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (newType) =>
                            setState(() => _selectedType = newType),
                        validator: (val) =>
                        val == null ? 'Please select a type' : null,
                      ),
                      const SizedBox(height: 16),

                      // ---- Title ----
                      _buildLabel('Title *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('Enter title'),
                        validator: (val) =>
                        val?.isEmpty ?? true ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),

                      // ---- Description ----
                      _buildLabel('Description'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Enter description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // ---- Date & Time Row ----
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Date *'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: _inputDecoration('Select date'),
                                    child: Text(
                                      _selectedDate != null
                                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                          : 'Select date',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Time'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _selectTime,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: _inputDecoration('Select time'),
                                    child: Text(
                                      _selectedTime != null
                                          ? _selectedTime!.format(context)
                                          : 'Select time',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ---- Reminder Before ----
                      _buildLabel('Reminder Before'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ReminderBefore>(
                        value: _selectedReminderBefore,
                        decoration: _inputDecoration('Select reminder before'),
                        items: widget.masterData.reminderBeforeOptions.map((rb) {
                          return DropdownMenuItem(
                            value: rb,
                            child: Text(rb.name),
                          );
                        }).toList(),
                        onChanged: (newRb) =>
                            setState(() => _selectedReminderBefore = newRb),
                      ),
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
                        children: widget.masterData.notificationChannels
                            .map((channel) {
                          final isSelected =
                          _selectedChannels.contains(channel.value);
                          return FilterChip(
                            label: Text(channel.label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedChannels.add(channel.value);
                                } else {
                                  _selectedChannels.remove(channel.value);
                                }
                              });
                            },
                            backgroundColor: const Color(0xffF3F4F6),
                            selectedColor: Colors.blue.shade50,
                            checkmarkColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue.shade300
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ---- Notes ----
                      _buildLabel('Notes'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        decoration: _inputDecoration('Enter notes'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Footer (Buttons) ----------
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
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
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
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save Changes',
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xff9CA3AF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff4F46E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ---------- Pickers ----------
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}