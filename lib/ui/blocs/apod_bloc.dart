import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/domain/use_case.dart';

enum ApodStatus { loading, success, failed }

DateFormat formateador = DateFormat('yyyy-MM-dd');

class ApodState {
  final ApodStatus status;
  final Map<String, dynamic>? apodData;
  final ApodStatus multiplestatus;
  final List multipleApodData;
  final List favoriteApodData;
  final ApodStatus favoriteApodStatus;
  String date = formateador.format(DateTime.now());

  ApodState({
    required this.status,
    this.apodData,
    required this.date,
    this.multipleApodData = const [],
    this.favoriteApodData = const [],
    required this.favoriteApodStatus,
    required this.multiplestatus,
  });
}

abstract class ApodEvent {}

class FetchApod extends ApodEvent {
  String? date;
  FetchApod();
}

class FetchMultipleApod extends ApodEvent {
  String? date;
  FetchMultipleApod();
}

class FetchFavoriteApod extends ApodEvent {
  FetchFavoriteApod();
}

class ChangeDate extends ApodEvent {
  String date;

  ChangeDate(this.date);
}

class ApodBloc extends Bloc<ApodEvent, ApodState> {
  final ApodUseCase _apodUseCase;

  ApodBloc(this._apodUseCase)
      : super(ApodState(
            status: ApodStatus.loading,
            multiplestatus: ApodStatus.loading,
            favoriteApodStatus: ApodStatus.success,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
    on<FetchApod>((event, emit) async {
      try {
        final apodData = await _apodUseCase
            .getApod(state.date); // Aquí usamos la fecha del estado
        emit(ApodState(
            status: ApodStatus.success,
            apodData: apodData,
            multiplestatus: ApodStatus.loading,
            favoriteApodStatus: state.favoriteApodStatus,
            date: state.date,
            multipleApodData: []));
      } catch (error) {
        emit(ApodState(
            status: ApodStatus.failed,
            multiplestatus: ApodStatus.loading,
            favoriteApodStatus: state.favoriteApodStatus,
            date: state.date,
            multipleApodData: []));
      }
    });

    on<FetchMultipleApod>((event, emit) async {
      try {
        final multipleApodData = await _apodUseCase
            .getMultipleApod(state.date); // Aquí usamos la fecha del estado
        emit(ApodState(
          status: ApodStatus.success,
          multipleApodData: multipleApodData,
          multiplestatus: ApodStatus.success,
          favoriteApodStatus: state.favoriteApodStatus,
          date: state.date,
          apodData: state.apodData,
        ));
      } catch (error) {
        emit(ApodState(
            status: ApodStatus.success,
            multiplestatus: ApodStatus.failed,
            favoriteApodStatus: state.favoriteApodStatus,
            date: state.date,
            apodData: state.apodData));
      }
    });
    on<FetchFavoriteApod>((event, emit) async {
      try {
        print('object');
        final favorites = await _apodUseCase
            .getFavoritesApod(); // Aquí usamos la fecha del estado

        print(favorites);
        emit(ApodState(
          status: ApodStatus.success,
          multiplestatus: ApodStatus.success,
          date: state.date,
          favoriteApodData: favorites,
          favoriteApodStatus: ApodStatus.success,
          apodData: state.apodData,
        ));
      } catch (error) {
        emit(ApodState(
            status: ApodStatus.success,
            multiplestatus: ApodStatus.success,
            favoriteApodStatus: ApodStatus.failed,
            date: state.date,
            apodData: state.apodData));
      }
    });
    on<ChangeDate>((event, emit) async {
      try {
        emit(ApodState(
          status: ApodStatus.loading,
          multipleApodData: state.multipleApodData,
          favoriteApodData: state.favoriteApodData,
          favoriteApodStatus: state.favoriteApodStatus,
          multiplestatus: ApodStatus.loading,
          date: event.date,
        ));
        add(FetchApod());
        add(FetchMultipleApod());
      } catch (error) {
        emit(ApodState(
            status: state.status,
            multiplestatus: state.multiplestatus,
            favoriteApodStatus: state.favoriteApodStatus,
            date: state.date,
            apodData: state.apodData));
      }
    });
  }
}
