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
  final String date;
  final String? errorMessage;

  ApodState({
    required this.status,
    this.apodData,
    required String date,
  this.multipleApodData = const [],
    this.favoriteApodData = const [],
    required this.favoriteApodStatus,
    required this.multiplestatus,
    this.errorMessage,
  }) : date = _limitToToday(date);

  ApodState copyWith({
    ApodStatus? status,
    Map<String, dynamic>? apodData,
    ApodStatus? multiplestatus,
    List? multipleApodData,
    List? favoriteApodData,
    ApodStatus? favoriteApodStatus,
    String? date,
    String? errorMessage,
  }) {
    return ApodState(
      status: status ?? this.status,
      apodData: apodData ?? this.apodData,
      multiplestatus: multiplestatus ?? this.multiplestatus,
      multipleApodData: multipleApodData ?? this.multipleApodData,
      favoriteApodData: favoriteApodData ?? this.favoriteApodData,
      favoriteApodStatus: favoriteApodStatus ?? this.favoriteApodStatus,
      date: date ?? this.date,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static String _limitToToday(String dateStr) {
    final DateTime now = DateTime.now();
    try {
      final DateTime parsed = DateTime.parse(dateStr);
      if (parsed.isAfter(now)) {
        return formateador.format(now);
      }
      return formateador.format(parsed);
    } catch (_) {
      return formateador.format(now);
    }
  }
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

class FetchMultipleApodSized extends ApodEvent {
  final int count;
  FetchMultipleApodSized(this.count);
}

// Evento de paginación eliminado

class FetchFavoriteApod extends ApodEvent {
  FetchFavoriteApod();
}

class RefreshData extends ApodEvent {}

class ChangeDate extends ApodEvent {
  final String date;

  ChangeDate(String date)
      : date = ApodState._limitToToday(date);
}

class ApodBloc extends Bloc<ApodEvent, ApodState> {
  final ApodUseCase _apodUseCase;

  ApodBloc(this._apodUseCase)
      : super(ApodState(
            status: ApodStatus.loading,
            multiplestatus: ApodStatus.loading,
            favoriteApodStatus: ApodStatus.loading,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
    on<FetchApod>((event, emit) async {
      try {
        final apodData = await _apodUseCase.getApod(state.date);
        emit(state.copyWith(
          status: ApodStatus.success,
          apodData: apodData,
        ));
      } catch (error) {
        emit(state.copyWith(status: ApodStatus.failed));
      }
    });

    on<FetchMultipleApod>((event, emit) async {
      try {
        final multipleApodData =
            await _apodUseCase.getMultipleApod(state.date);
        emit(state.copyWith(
          multipleApodData: multipleApodData,
          multiplestatus: ApodStatus.success,
        ));
      } catch (error) {
        emit(state.copyWith(multiplestatus: ApodStatus.failed));
      }
    });
    on<FetchMultipleApodSized>((event, emit) async {
      try {
        final multipleApodData = await _apodUseCase.getMultipleApod(state.date, count: event.count);
        emit(state.copyWith(
          multipleApodData: multipleApodData,
          multiplestatus: ApodStatus.success,
        ));
      } catch (error) {
        emit(state.copyWith(multiplestatus: ApodStatus.failed));
      }
    });
    on<FetchFavoriteApod>((event, emit) async {
      emit(state.copyWith(favoriteApodStatus: ApodStatus.loading));
      try {
        final favorites = await _apodUseCase.getFavoritesApod();

        emit(state.copyWith(
          favoriteApodData: favorites,
          favoriteApodStatus: ApodStatus.success,
        ));
      } catch (error) {
        emit(state.copyWith(favoriteApodStatus: ApodStatus.failed));
      }
    });
    on<RefreshData>((event, emit) async {
      try {
        emit(state.copyWith(
          status: ApodStatus.loading,
          multiplestatus: ApodStatus.loading,
        ));

        final results = await Future.wait([
          _apodUseCase.getApod(state.date),
          _apodUseCase.getMultipleApod(state.date),
        ]);

        final apodData = results[0] as Map<String, dynamic>;
        final multipleApodData = results[1] as List;

        emit(state.copyWith(
          status: ApodStatus.success,
          apodData: apodData,
          multiplestatus: ApodStatus.success,
          multipleApodData: multipleApodData,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: ApodStatus.failed,
          multiplestatus: ApodStatus.failed,
        ));
      }
    });
    on<ChangeDate>((event, emit) async {
      try {
        final DateTime now = DateTime.now();
        DateTime? parsed;
        String? errorMessage;
        try {
          parsed = DateTime.parse(event.date);
          if (parsed.isAfter(now)) {
            parsed = now;
            errorMessage = 'Fecha limitada a hoy.';
          }
        } catch (_) {
          parsed = now;
          errorMessage = 'Formato de fecha inválido.';
        }
        final newDate = formateador.format(parsed);

        emit(state.copyWith(
          date: newDate,
          status: ApodStatus.loading,
          multiplestatus: ApodStatus.loading,
          errorMessage: errorMessage,
        ));

        // Fetch both main APOD and slider APODs concurrently
        final results = await Future.wait([
          _apodUseCase.getApod(newDate),
          _apodUseCase.getMultipleApod(newDate),
        ]);

        final apodData = results[0] as Map<String, dynamic>;
        final multipleApodData = results[1] as List;

        emit(state.copyWith(
          status: ApodStatus.success,
          apodData: apodData,
          multiplestatus: ApodStatus.success,
          multipleApodData: multipleApodData,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: ApodStatus.failed,
          multiplestatus: ApodStatus.failed,
        ));
      }
    });
    // Handler de paginación eliminado
  }
}
