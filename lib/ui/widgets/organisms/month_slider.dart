import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/ui/widgets/molecules/month_button.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';

class MonthSlider extends StatelessWidget {
  const MonthSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      return SizedBox(
        height: 35,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final date = state.date;
              final month = DateTime.parse(date);
              return MonthButton(
                isSelected: index + 1 == DateTime.parse(date).month,
                month: DateFormat.MMMM('es_ES')
                    .format(DateTime(month.year, index + 1, month.day)),
                onTap: () {
                  context.read<ApodBloc>().add(
                        ChangeDate(DateFormat('yyyy-MM-dd')
                            .format(DateTime(2023, index + 1, month.day))),
                      );
                },
              );
            },
            itemCount: 12),
      );
    });
  }
}
