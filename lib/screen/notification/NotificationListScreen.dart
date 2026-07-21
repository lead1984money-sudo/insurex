import 'package:flutter/material.dart';
import 'package:pdf_read/screen/notification/model/notification_model.dart';
import 'package:pdf_read/screen/notification/provider/NotificationProvider.dart';
import 'package:provider/provider.dart';


class NotificationListScreen extends StatefulWidget {

  final Map<String, dynamic>? arguments;

  // ✅ Use const constructor (this prevents the hot‑reload error)
  const NotificationListScreen({super.key, this.arguments});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white), // 👈 back button becomes white
          title: const Text('Notifications', style: TextStyle(
            fontWeight:  FontWeight.bold,color: Colors.white
          ),),
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.unreadCount > 0 && !provider.isMarkingAllRead) {
                  return IconButton(
                    icon: const Icon(Icons.done_all,color: Colors.white),
                    onPressed: () => provider.markAllAsRead(),
                    tooltip: 'Mark all as read',
                  );
                }
                if (provider.isMarkingAllRead) {
                  return const SizedBox(
                    width: 48,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (provider.errorMessage.isNotEmpty && provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
      
            if (provider.notifications.isEmpty) {
              return const Center(
                child: Text('No notifications'),
              );
            }
      
            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: ListView.separated(
                itemCount: provider.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () {
                      if (!notification.read) {
                        provider.markAsRead(notification.id);
                      }
                      // Optionally navigate to target_path
                      // Navigator.pushNamed(context, notification.targetPath);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero, // we handle padding via outer Padding
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.read ? Colors.grey[300] : Colors.blue,
            child: notification.read
                ? const Icon(Icons.mark_email_read, color: Colors.grey)
                : const Icon(Icons.mark_email_unread, color: Colors.white),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                _formatDate(notification.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: onTap,
          trailing: notification.read ? null : const Icon(Icons.circle, size: 12, color: Colors.blue),
        ),
      ),
    );
  }

  String _formatDate(String dateTimeStr) {
    // same as before
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return dateTimeStr;
    }
  }
}