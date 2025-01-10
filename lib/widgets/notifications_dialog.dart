import 'package:flutter/material.dart';
import 'package:todo_app/services/notification_service.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bildirimler',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.6),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yaklaşan görev',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Görev adı - 1 gün kaldı',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: const Color(0xFF1E1F25).withOpacity(0.95),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Bildirimi Ertele',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildDelayOption(context, '1 saat sonra'),
                                        _buildDelayOption(context, '3 saat sonra'),
                                        _buildDelayOption(context, '1 gün sonra'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Ertele',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NotificationService.instance.cancelEventNotifications(index);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Sil',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDelayOption(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // Erteleme işlemi
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 