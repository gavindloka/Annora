import 'package:annora_survey/models/notif.dart';
import 'package:annora_survey/viewModels/notif_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String username;
  final String email;

  const TopBar({super.key, required this.username, required this.email});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(170);
}

class _TopBarState extends State<TopBar> {
  List<Notif> notifications = [];
  String errorMsg = '';
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    final result = await NotifViewModel().getNotifications(widget.email);
    if (result['success']) {
      setState(() {
        notifications = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMsg = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount =
        notifications.where((notif) => notif.status == "unread").length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.notifications,
                      size: 35,
                      color: Colors.amber,
                    ),
                    itemBuilder: (context) {
                      if (isLoading) {
                        return [
                          const PopupMenuItem(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ];
                      }
                      if (notifications.isEmpty) {
                        return [
                          const PopupMenuItem(
                            child: Text("No new notifications"),
                          ),
                        ];
                      }
                      return notifications.map((notif) {
                        bool isUnread = notif.status == "unread";

                        return PopupMenuItem(
                          child: ListTile(
                            leading: Icon(
                              isUnread
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              color: isUnread ? Colors.orange : Colors.grey,
                            ),
                            title: Text(
                              notif.notification,
                              style: TextStyle(
                                fontWeight:
                                    isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(notif.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 5,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.account_circle,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hai, ${widget.username}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Selamat datang di Surveyor Annora",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
