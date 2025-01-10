import 'package:flutter/material.dart';
import 'package:todo_app/widgets/notifications_dialog.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        children: [
          PopupMenuButton(
            offset: const Offset(-220, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            color: const Color(0xFF1E1F25).withOpacity(0.95),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: const NotificationsDialog(),
                ),
              ),
            ],
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white70,
              size: 26,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF8E2DE2),
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 