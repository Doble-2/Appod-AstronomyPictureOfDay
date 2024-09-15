import 'package:flutter/material.dart';

class MonthButton extends StatelessWidget {
  final bool isSelected;
  final String month;
  final VoidCallback onTap;

  const MonthButton({
    Key? key,
    required this.isSelected,
    required this.month,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F7FE) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(
            month,
            style: TextStyle(
              color: isSelected ? Colors.blue : const Color(0xFFB8B8B8),
            ),
          ),
        ),
      ),
    );
  }
}
