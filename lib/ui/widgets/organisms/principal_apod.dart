import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
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
  State<PrincipalApod> createState() => _PrincipalApodState();
}

class _PrincipalApodState extends State<PrincipalApod> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        return Padding(
          padding: context.isDesktop ? const EdgeInsets.symmetric(vertical: 40.0) : EdgeInsets.zero,
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
                  AnimatedSlide(
                    offset: Offset.zero,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: TitleArea(text:    l10n.apodToday,),
                  ),
                  const SizedBox(height: 10),
                  PrincipalApodButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/appod');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
