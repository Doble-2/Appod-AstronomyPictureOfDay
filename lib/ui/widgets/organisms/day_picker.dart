import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DayPicker extends StatefulWidget {
  const DayPicker({super.key});

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(DateTime? currentDate) async {
    final DateTime initialDate = currentDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1995, 6),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      context.read<ApodBloc>().add(ChangeDate(DateFormat('yyyy-MM-dd').format(picked)));
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(date);
      return DateFormat('d \'de\' MMMM, yyyy', 'es').format(dt);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApodBloc, ApodState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<ApodBloc, ApodState>(
        buildWhen: (prev, curr) => prev.date != curr.date,
        builder: (context, state) {
          final String formattedDate = _formatDate(state.date);
          _controller.text = formattedDate;
          return Material(
            elevation: 0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              controller: _controller,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                constraints: const BoxConstraints(maxHeight: 56),
                fillColor: Theme.of(context).colorScheme.surface,
                hintText: 'Elige una fecha',
                hintStyle: Theme.of(context).textTheme.titleMedium,
                filled: true,
                prefixIcon: Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary),
                prefixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 32),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
              readOnly: true,
              onTap: () {
                _selectDate(state.date.isNotEmpty ? DateTime.tryParse(state.date) : null);
              },
              cursorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
