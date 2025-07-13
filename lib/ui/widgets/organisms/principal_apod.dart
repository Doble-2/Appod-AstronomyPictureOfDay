import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/principal_apod_button.dart';

class PrincipalApod extends StatefulWidget {
  final VoidCallback onTap;

  const PrincipalApod({
    super.key,
    required this.onTap,
  });

  @override
  _PrincipalApodState createState() => _PrincipalApodState();
}

class _PrincipalApodState extends State<PrincipalApod> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AnimatedSlide(
                    offset: Offset.zero,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: TitleArea(text: 'This day in space'),
                  ),
                  const SizedBox(height: 16),
                  PrincipalApodButton(onTap: widget.onTap),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
