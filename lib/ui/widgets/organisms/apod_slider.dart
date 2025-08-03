import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_button.dart';
// Asegúrate de importar tu bloc

class ApodSlider extends StatefulWidget {
  const ApodSlider({super.key});

  @override
  State<ApodSlider> createState() => _ApodSliderState();
}

class _ApodSliderState extends State<ApodSlider> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      buildWhen: (previous, current) =>
          previous.multiplestatus != current.multiplestatus || previous.date != current.date,
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        if (state.multiplestatus == ApodStatus.success && state.multipleApodData.isNotEmpty) {
          return SizedBox(
            height: 210,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: ListView.separated(
                padding: const EdgeInsets.only(right: 8),
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final apodData = state.multipleApodData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    
                    child:apodData["url"] != null? ApodButton(
                      image: apodData['url'],
                      title: apodData['title'],
                      date: apodData['date'],
                      author: apodData['copyright'] ?? 'Nasa',
                    ): const SkeletonApodButton(),
                  );
                },
                itemCount: state.multipleApodData.length,
              ),
            ),
          );
        } else if (state.multiplestatus != ApodStatus.failed) {
          return SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 8),
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const SkeletonApodButton();
              },
              itemCount: 7,
            ),
          );
        } else {
          // Error visual moderno
          return SizedBox(
            height: 210,
            child: ListView.separated(
                padding: const EdgeInsets.only(right: 8),
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF23272F), const Color(0xFF181A20)]
                          : [const Color(0xFFE3E6EC), const Color(0xFFF5F6FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black : Colors.grey,
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 10),
                        Text(
                          'Error de conexión',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No se pudo cargar el contenido',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: 3,
            ),
          );
        }
      },
    );
  }
}
