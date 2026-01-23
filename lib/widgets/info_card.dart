import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final String title;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.text,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double iconSize = width * 0.25;
        final double titleFontSize = width * 0.08;
        final double textFontSize = width * 0.06;

        return Container(
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textFontSize,
                  color: Colors.grey[800],
                ),
                softWrap: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
