import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/principal_apod_button.dart';

class PrincipalApod extends StatefulWidget {
  final VoidCallback onTap;

  const PrincipalApod({
    Key? key,
    required this.onTap,
  }) : super(key: key);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleArea(text: 'This day in space'),
        PrincipalApodButton(onTap: widget.onTap),
      ],
    );
  }
}
