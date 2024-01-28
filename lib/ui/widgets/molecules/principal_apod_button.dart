import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
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
          return SkeletonPrincipalApodButton();
        } else if (state.status == ApodStatus.success &&
            state.apodData != null) {
          return Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ApodView()));
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.network(
                      state.apodData!['url'],
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
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5.0),
                                  child: Bubble(
                                    child: Text(
                                      state.apodData!['title'],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
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
                                    Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF606060),
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      state.apodData!['date'],
                                      style: TextStyle(
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
                            onTap: widget.onTap,
                            child: Icon(
                              Icons.more_vert_outlined,
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
          return Text('Failed to load data');
        }
      },
    );
  }
}
