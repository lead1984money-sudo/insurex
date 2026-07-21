import 'package:flutter/material.dart';
import 'model/reminder_master_model.dart';




class MeetScreen extends StatefulWidget {
  final MasterData? masterData;
  final String? categoryID;

  const MeetScreen({super.key, this.masterData, this.categoryID});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  String relatedTo = "Amit Patel (Client)";
  String remindMe = "1 hour before";

  final titleController =
  TextEditingController(text: "Client Review Meeting");

  final descriptionController =
  TextEditingController(text: "Quarterly policy review meeting");

  final notesController =
  TextEditingController(text: "Discuss policy updates and renewal.");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Header
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

              const Text(
                "Type",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _typeCard(
                    icon: Icons.cake_outlined,
                    title: "Wishes",
                    color: Colors.pink,
                    selected: false,
                  ),
                  _typeCard(
                    icon: Icons.event_outlined,
                    title: "Events",
                    color: Colors.green,
                    selected: false,
                  ),
                  _typeCard(
                    icon: Icons.groups,
                    title: "Meet",
                    color: const Color(0xff7E57FF),
                    selected: true,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _label("Title", true),

              const SizedBox(height: 8),

              _textField(titleController),

              const SizedBox(height: 16),

              _label("Description", false),

              const SizedBox(height: 8),

              _textField(descriptionController),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label("Date", true),
                        const SizedBox(height: 8),
                        _dateTimeField(
                          "16 May, 2024",
                          Icons.calendar_today_outlined,
                        ),
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
                        const SizedBox(height: 8),
                        _dateTimeField(
                          "12:00 PM",
                          Icons.access_time,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _label("Related To", true),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: relatedTo,
                decoration: _inputDecoration(),
                items: [
                  "Amit Patel (Client)",
                  "Rahul Sharma",
                  "Sales Team",
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

              const SizedBox(height: 16),

              _label("Remind Me", false),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: remindMe,
                decoration: _inputDecoration(),
                items: [
                  "1 hour before",
                  "2 hours before",
                  "1 day before",
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

              const SizedBox(height: 16),

              _label("Notes (optional)", false),

              const SizedBox(height: 8),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff2F5DFF),
                          Color(0xff204AE5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    required String title,
    required Color color,
    required bool selected,
  }) {
    return Container(
      width: 100,
      height: 95,
      decoration: BoxDecoration(
        color: selected
            ? color.withOpacity(.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? color
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
            ),
          )
        ],
      ),
    );
  }

  Widget _label(String title, bool required) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _textField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(),
    );
  }

  Widget _dateTimeField(
      String text,
      IconData icon,
      ) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Icon(icon, size: 20),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(
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
          color: Color(0xff7E57FF),
        ),
      ),
    );
  }
}