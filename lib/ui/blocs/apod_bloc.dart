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
  String date = formateador.format(DateTime.now());

  ApodState({
    required this.status,
    this.apodData,
    required this.date,
    this.multipleApodData = const [],
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
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
    on<FetchApod>((event, emit) async {
      try {
        final apodData = await _apodUseCase
            .getApod(state.date); // Aquí usamos la fecha del estado
        emit(ApodState(
            status: ApodStatus.success,
            apodData: apodData,
            multiplestatus: ApodStatus.loading,
            date: state.date,
            multipleApodData: []));
      } catch (error) {
        emit(ApodState(
            status: ApodStatus.failed,
            multiplestatus: ApodStatus.loading,
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
          date: state.date,
          apodData: state.apodData,
        ));
      } catch (error) {
        emit(ApodState(
            status: ApodStatus.success,
            multiplestatus: ApodStatus.failed,
            date: state.date,
            apodData: state.apodData));
      }
    });

    on<ChangeDate>((event, emit) async {
      try {
        emit(ApodState(
          status: ApodStatus.loading,
          multipleApodData: state.multipleApodData,
          multiplestatus: ApodStatus.loading,
          date: event.date,
        ));
        add(FetchApod());
        add(FetchMultipleApod());
      } catch (error) {
        emit(ApodState(
            status: state.status,
            multiplestatus: state.multiplestatus,
            date: state.date,
            apodData: state.apodData));
      }
    });
  }
}
