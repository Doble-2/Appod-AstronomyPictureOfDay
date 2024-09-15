import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';

class PrincipalApodButton extends StatefulWidget {
  final VoidCallback onTap;

  const PrincipalApodButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

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
        } else if (state.status == ApodStatus.success &&
            state.apodData != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () {
                context.read<ApodBloc>().add(
                      ChangeDate(state.apodData!['date']),
                    );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ApodView()));
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.network(
                      state.apodData!['url'],
                      errorBuilder: (context, error, stackTrace) {
                        return Stack(
                          children: [
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF161616),
                                    Color(0xFF1A1A1A)
                                  ],
                                  stops: [0.2, 2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 10,
                              left: 10,
                              child: Text('Error de conexion'),
                            )
                          ],
                        );
                      },
                      fit: BoxFit.cover,
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Bubble(
                                    child: Text(
                                      state.apodData!['title'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF606060),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Bubble(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF606060),
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      state.apodData!['date'],
                                      style: const TextStyle(
                                        color: Color(0xFF606060),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              saveNetworkImage(state.apodData!['hdurl'],
                                  state.apodData!['title']);
                            },
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Stack(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF161616), Color(0xFF1A1A1A)],
                    stops: [0.2, 2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: Text('Error de conexion'),
              )
            ],
          );
        }
      },
    );
  }
}
