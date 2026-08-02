import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

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
    if (!context.isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const double itemWidth = 80.0;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double offset = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDesktop = context.isDesktop;
    final currentLanguage = localeProvider.selectedLanguage;

    return BlocBuilder<ApodBloc, ApodState>(
      buildWhen: (prev, curr) => prev.date != curr.date,
      builder: (context, state) {
        DateTime selectedDate;
        try { selectedDate = DateTime.parse(state.date); } catch (_) { selectedDate = DateTime.now(); }
        final int selectedIndex = selectedDate.month - 1;
        _scrollToSelected(selectedIndex);

        // Lista de meses para ambos modos
        final monthItems = List.generate(12, (i) => toBeginningOfSentenceCase(
              DateFormat.MMMM(currentLanguage.languageCode).format(DateTime(selectedDate.year, i + 1)),
            ));

        if (isDesktop) {
          // SELECT (Dropdown) estilizado para escritorio
          return SizedBox(
            width: 340,
            child: Semantics(
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    value: selectedIndex,
                    icon: Icon(Icons.expand_more_rounded, color: Theme.of(context).colorScheme.primary),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: [
                      for (int i = 0; i < monthItems.length; i++)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Row(
                            children: [
                              if (i == selectedIndex)
                                Icon(Icons.check_circle_rounded,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 12),
                              Text(
                                monthItems[i],
                                style: TextStyle(
                                  fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      final newMonth = value + 1;
                      // Meses futuros del año actual: no seleccionables (NASA no tiene datos del futuro)
                      if (DateTime(selectedDate.year, newMonth, 1)
                          .isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1))) {
                        return;
                      }
                      // Clamp day to 28 para evitar invalid date
                      final newDate = DateTime(selectedDate.year, newMonth, selectedDate.day.clamp(1, 28));
                      context.read<ApodBloc>().add(ChangeDate(DateFormat('yyyy-MM-dd').format(newDate)));
                    },
                  ),
                ),
              ),
            ),
          );
        }

        // MÓVIL: lista horizontal existente
        return SizedBox(
          height: 56,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: 12,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              // Meses futuros del año actual: deshabilitados (NASA no tiene datos del futuro)
              final isFutureMonth = DateTime(selectedDate.year, index + 1, 1)
                  .isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1));
              return MouseRegion(
                cursor: isFutureMonth ? SystemMouseCursors.basic : SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isFutureMonth
                      ? null
                      : () {
                          final newDate = DateTime(selectedDate.year, index + 1, selectedDate.day.clamp(1, 28));
                          context.read<ApodBloc>().add(ChangeDate(DateFormat('yyyy-MM-dd').format(newDate)));
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isFutureMonth
                              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.4)
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        monthItems[index],
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : isFutureMonth
                                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                                  : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
