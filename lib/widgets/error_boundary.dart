import 'package:flutter/material.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      debugPrint('Widget hatası: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Widget hatası oluştu: ${details.exception}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    };
    
    return child;
  }
} 