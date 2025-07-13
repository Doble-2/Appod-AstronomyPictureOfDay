import 'package:flutter/material.dart';

class MonthButton extends StatelessWidget {
  final bool isSelected;
  final String month;
  final VoidCallback onTap;

  const MonthButton({
    super.key,
    required this.isSelected,
    required this.month,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(
            month,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFFB8B8B8),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
