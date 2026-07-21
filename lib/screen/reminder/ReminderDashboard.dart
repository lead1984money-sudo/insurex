import 'package:flutter/material.dart';
import 'package:pdf_read/screen/reminder/provider/ReminderProvider.dart';
import 'package:provider/provider.dart';
import 'EditReminderDialog.dart';
import 'ViewReminderDialog.dart';
import 'WishesScreen.dart';
import 'model/reminder_master_model.dart';
import 'model/reminder_model.dart';


class ReminderDashboard extends StatefulWidget {
  const ReminderDashboard({super.key});

  @override
  State<ReminderDashboard> createState() => _ReminderDashboardState();

}

class _ReminderDashboardState extends State<ReminderDashboard> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      body: SafeArea(
        child: Consumer<ReminderProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchAllData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return _buildContent(context, provider);
          },
        ),
      ),
    );
  }


  Widget _buildContent(BuildContext context, ReminderProvider provider) {
    final reminders = provider.reminders;
    final categories = provider.masterData?.categories ?? [];
    final categoryCounts = provider.categoryCounts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Reminders",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 10),

          // DYNAMIC CATEGORY CARDS
          if (categories.isNotEmpty)
            Row(
              children: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                final count = categoryCounts[cat.alias] ?? 0;
                final (icon, color) = _getCategoryDetails(cat.alias);
                return [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToCategoryScreen(
                          context, cat.alias, provider.masterData, cat.id),
                      child: _dashboardCard(
                        title: cat.name,
                        count: count.toString(),
                        icon: icon,
                        color: color,
                      ),
                    ),
                  ),
                  if (index < categories.length - 1) const SizedBox(width: 12),
                ];
              }).expand((widgets) => widgets).toList(),
            )
          else
            const SizedBox.shrink(),

          const SizedBox(height: 30),

          // UPCOMING REMINDERS SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upcoming Reminders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle "View All" navigation
                },
                child: const Text("View All"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // REMINDERS LIST
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final item = reminders[index];
              return _reminderCard(
                item,
                onView: () => _showViewDialog(item),
                onEdit: () => _showEditDialog(item),
                onDelete: () => _showDeleteDialog(item),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------- Helper Methods ----------------------

  /// Returns icon and color for a given category alias.
  (IconData, Color) _getCategoryDetails(String alias) {
    switch (alias) {
      case 'wishes':
        return (Icons.cake, const Color(0xffFF5C8A));
      case 'events':
        return (Icons.event, const Color(0xff20C997));
      case 'meet':
        return (Icons.groups, const Color(0xff7E57FF));
      default:
        return (Icons.category, Colors.grey);
    }
  }



  /// Navigates to the appropriate screen based on category alias.
  void _navigateToCategoryScreen(
      BuildContext context, String alias, MasterData? masterData, String categoryID) {
    Widget screen;
    switch (alias) {
      case 'wishes':
      case 'events':
      case 'meet':
        screen = WishesScreen(masterData: masterData, categoryID: categoryID);
        break;
      default:
        screen = Scaffold(
          appBar: AppBar(title: Text('$alias Reminders')),
          body: const Center(child: Text('Screen not implemented yet')),
        );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((result) {
      if (result == true) {
        context.read<ReminderProvider>().fetchAllData();
      }
    });
  }

  // ---------------------- Dialog Methods ----------------------

  void _showEditDialog(Reminder reminder) {
    final masterData = context.read<ReminderProvider>().masterData;
    if (masterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master data not available')),
      );
      return;
    }

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditReminderDialog(
        reminder: reminder,
        masterData: masterData,
      ),
    ).then((result) {
      if (result == true) {
        context.read<ReminderProvider>().fetchAllData();
      }
    });
  }

  void _showViewDialog(Reminder reminder) {
    final masterData = context.read<ReminderProvider>().masterData;
    if (masterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master data not available')),
      );
      return;
    }

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ViewReminderDialog(
        reminder: reminder,
        masterData: masterData,
      ),
    );
  }

  void _showDeleteDialog(Reminder reminder) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderProvider>().deleteReminder(reminder.id).then((success) {
                Navigator.pop(context, success);
                if (success) {
                  context.read<ReminderProvider>().fetchAllData();
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------------------- UI Widgets ----------------------

  Widget _dashboardCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 26,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Upcoming",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(
      Reminder item, {
        VoidCallback? onView,
        VoidCallback? onEdit,
        VoidCallback? onDelete,
      }) {
    final (icon, color) = _getCategoryDetails(item.categoryAlias.toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(.9),
                    color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ),
                      // ---- Category Chip only (status removed) ----
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.categoryAlias.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.eventDate,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.eventTime ?? "--",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons
                  Row(
                    children: [
                      // View
                      GestureDetector(
                        onTap: onView,
                        child: _actionButton(
                          icon: Icons.visibility_rounded,
                          color: Colors.blue,
                          onTap: onView,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Edit
                      GestureDetector(
                        onTap: onEdit,
                        child: _actionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.orange,
                          onTap: onEdit,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Delete
                      GestureDetector(
                        onTap: onDelete,
                        child: _actionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.red,
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}