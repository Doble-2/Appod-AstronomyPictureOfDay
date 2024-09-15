import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DayPicker extends StatefulWidget {
  const DayPicker({
    Key? key,
  }) : super(key: key);

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  TextEditingController _controller = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime initialDate = context.read<ApodBloc>().state.date == ''
        ? DateTime.now()
        : DateTime.parse(context.read<ApodBloc>().state.date);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1995, 6),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      context
          .read<ApodBloc>()
          .add(ChangeDate(DateFormat('yyyy-MM-dd').format(picked)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      return TextField(
          controller: _controller,
          decoration: InputDecoration(
            constraints: const BoxConstraints(
              maxHeight: 50,
            ),
            fillColor: const Color(0xFFF3F8FE),
            labelStyle: const TextStyle(color: Color(0xFFB8B8B8)),
            hintText: state.date,
            hintStyle: const TextStyle(color: Color(0xFFB8B8B8)),
            filled: true,
            prefixIconColor: const Color(0xFFB8B8B8),
            prefixIcon: const Icon(Icons.calendar_today),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 65,
              minHeight: 25,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          readOnly: true,
          onTap: _selectDate);
    });
  }
}
