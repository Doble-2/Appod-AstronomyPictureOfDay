import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_button.dart';

/// Colección adaptativa de APODs: lista horizontal en mobile, grid en desktop.
class ApodCollection extends StatelessWidget {
  const ApodCollection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<ApodBloc, ApodState>(
        buildWhen: (p, c) => p.multiplestatus != c.multiplestatus || p.date != c.date,
        builder: (context, state) {
          if (state.multiplestatus == ApodStatus.success && state.multipleApodData.isNotEmpty) {
            if (context.isDesktop) {
              final width = constraints.maxWidth;
              int crossAxisCount = 2;
              if (width >= 1400) {
                crossAxisCount = 4;
              } else if (width >= 1100) {
                crossAxisCount = 3;
              }
      return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: state.multipleApodData.length,
                itemBuilder: (context, index) {
                  final apodData = state.multipleApodData[index];
                  if (apodData['url'] == null) return const SkeletonApodButton();
                  return ApodButton(
                    image: apodData['url'],
                    title: apodData['title'],
                    date: apodData['date'],
                    author: apodData['copyright'] ?? 'Nasa',
        expand: true,
                  );
                },
              );
            }
            return SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.only(right: 8),
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                scrollDirection: Axis.horizontal,
                itemCount: state.multipleApodData.length,
                itemBuilder: (context, index) {
                  final apodData = state.multipleApodData[index];
                  if (apodData['url'] == null) return const SkeletonApodButton();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ApodButton(
                      image: apodData['url'],
                      title: apodData['title'],
                      date: apodData['date'],
                      author: apodData['copyright'] ?? 'Nasa',
                    ),
                  );
                },
              ),
            );
          }
          if (state.multiplestatus != ApodStatus.failed) {
            if (context.isDesktop) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const SkeletonApodButton(),
              );
            }
            return SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.only(right: 8),
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => const SkeletonApodButton(),
                itemCount: 7,
              ),
            );
          }
          return Text(
            'Error al cargar contenidos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          );
        },
      );
    });
  }
}
