import 'package:flutter/material.dart';

class HomeCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const HomeCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = const Color.fromARGB(255, 93, 69, 218),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        color: const Color.fromARGB(255, 240, 239, 247),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(icon, size: 60, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
