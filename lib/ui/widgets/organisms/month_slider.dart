import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';

class MonthSlider extends StatefulWidget {
  const MonthSlider({super.key});

  @override
  State<MonthSlider> createState() => _MonthSliderState();
}

class _MonthSliderState extends State<MonthSlider> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int selectedIndex) {
    // Centra el mes seleccionado en el slider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const double itemWidth = 70.0;
      final double screenWidth = MediaQuery.of(context).size.width;
      final double offset = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApodBloc, ApodState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage && (curr.errorMessage?.isNotEmpty == true),
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
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
          DateTime selectedDate;
          try {
            selectedDate = DateTime.parse(state.date);
          } catch (_) {
            selectedDate = DateTime.now();
          }
          final int selectedIndex = selectedDate.month - 1;
          _scrollToSelected(selectedIndex);
          return SizedBox(
            height: 48,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only( right: 16),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = selectedDate.month == index + 1;
                final monthName = toBeginningOfSentenceCase(
                  DateFormat.MMMM('es').format(DateTime(selectedDate.year, index + 1)),
                );
                return GestureDetector(
                  onTap: () {
                    final newDate = DateTime(selectedDate.year, index + 1, selectedDate.day);
                    context.read<ApodBloc>().add(ChangeDate(DateFormat('yyyy-MM-dd').format(newDate)));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        monthName,
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
