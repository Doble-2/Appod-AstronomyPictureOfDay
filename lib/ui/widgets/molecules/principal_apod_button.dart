import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';

class PrincipalApodButton extends StatefulWidget {
  final VoidCallback onTap;

  const PrincipalApodButton({
    super.key,
    required this.onTap,
  });

  @override
  _PrincipalApodState createState() => _PrincipalApodState();
}

class _PrincipalApodState extends State<PrincipalApodButton> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.status == ApodStatus.loading) {
          return const SkeletonPrincipalApodButton();
        } else if (state.status == ApodStatus.success && state.apodData != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<ApodBloc>().add(
                  ChangeDate(state.apodData!['date']),
                );
                Navigator.pushNamed(context, '/appod');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                      spreadRadius: .5,
                      blurRadius: 1,
                      offset: const Offset(0, .5),
                    ),
                  ],
                ),
                child: const Stack(
                  children: [
                    // Aquí puedes agregar el contenido visual del botón principal
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: const Center(child: Text('No data available')),
          );
        }
      },
    );
  }
// ...fin del widget PrincipalApodButton...
}
