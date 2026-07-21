import 'package:flutter/material.dart';

import 'model/reminder_master_model.dart';

class EventScreen extends StatefulWidget {
  final MasterData? masterData;
  final String? categoryID;

  const EventScreen({super.key, this.masterData, this.categoryID});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final titleController =
  TextEditingController(text: "Company Annual Day");

  final descriptionController =
  TextEditingController(text: "SecureLife Insurance Annual Day Event");

  final notesController =
  TextEditingController(text: "Arrange venue and refreshments.");

  String relatedTo = "SecureLife Team";
  String remindMe = "1 day before";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Add Reminder",
                        style: TextStyle(
                          fontSize: 22,
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

              const SizedBox(height: 20),

              /// TYPE
              const Text(
                "Type",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _typeCard(
                    icon: Icons.cake_outlined,
                    color: Colors.pink,
                    selected: false,
                    title: "Wishes",
                  ),
                  _typeCard(
                    icon: Icons.event,
                    color: Colors.green,
                    selected: true,
                    title: "Events",
                  ),
                  _typeCard(
                    icon: Icons.groups,
                    color: Colors.deepPurple,
                    selected: false,
                    title: "Meet",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _label("Title", true),

              const SizedBox(height: 6),

              _textField(
                controller: titleController,
              ),

              const SizedBox(height: 15),

              _label("Description", false),

              const SizedBox(height: 6),

              _textField(
                controller: descriptionController,
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label("Date", true),
                        const SizedBox(height: 6),
                        _dateField(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label("Time", true),
                        const SizedBox(height: 6),
                        _timeField(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _label("Related To", true),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: relatedTo,
                decoration: inputDecoration(),
                items: [
                  "SecureLife Team",
                  "Sales Team",
                  "Marketing Team"
                ]
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    relatedTo = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              _label("Remind Me", false),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: remindMe,
                decoration: inputDecoration(),
                items: [
                  "1 day before",
                  "2 days before",
                  "3 days before",
                  "1 week before"
                ]
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    remindMe = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              _label("Notes (optional)", false),

              const SizedBox(height: 6),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: inputDecoration(),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff2D5BFF),
                          Color(0xff1F49E0),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard({
    required IconData icon,
    required Color color,
    required bool selected,
    required String title,
  }) {
    return Container(
      width: 95,
      height: 90,
      decoration: BoxDecoration(
        color: selected
            ? color.withOpacity(.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? color.withOpacity(.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  Widget _label(String text, bool required) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: inputDecoration(),
    );
  }

  Widget _dateField() {
    return TextField(
      readOnly: true,
      decoration: inputDecoration(
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 20,
        ),
      ).copyWith(
        hintText: "16 May, 2024",
      ),
    );
  }

  Widget _timeField() {
    return TextField(
      readOnly: true,
      decoration: inputDecoration(
        suffixIcon: const Icon(
          Icons.access_time,
          size: 20,
        ),
      ).copyWith(
        hintText: "09:00 AM",
      ),
    );
  }

  InputDecoration inputDecoration({
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xff2D5BFF),
        ),
      ),
    );
  }
}