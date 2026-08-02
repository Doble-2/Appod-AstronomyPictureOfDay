import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/data/repository.dart';

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
  final int? errorCode;

  ApodState({
    required this.status,
    this.apodData,
    required String date,
  this.multipleApodData = const [],
    this.favoriteApodData = const [],
    required this.favoriteApodStatus,
    required this.multiplestatus,
    this.errorMessage,
  this.errorCode,
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
    int? errorCode,
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
      errorCode: errorCode ?? this.errorCode,
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

class FetchApod extends ApodEvent {}

class FetchMultipleApod extends ApodEvent {}

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
  final ApodRepositoryImpl _apodRepository;

  ApodBloc(this._apodRepository)
      : super(ApodState(
            status: ApodStatus.loading,
            multiplestatus: ApodStatus.loading,
            favoriteApodStatus: ApodStatus.loading,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
  (int?, String?) errorInfo(Object error) {
    try {
      return (
        (error as dynamic).statusCode as int?,
        (error as dynamic).message as String?,
      );
    } catch (_) {
      return (null, null);
    }
  }

  /// Traduce un error de red/API a un mensaje amigable y su tipo.
  /// Evita filtrar texto crudo de la API (ej: 'HTTP 500', 'API_KEY_INVALID').
  ({int? code, String? message}) friendlyError(Object error) {
    final (code, rawMsg) = errorInfo(error);
    final message = switch (code) {
      400 => 'La fecha seleccionada no tiene datos disponibles.',
      401 || 403 => 'La clave de la NASA no es válida o expiró.',
      404 => 'No se encontró contenido para esta fecha.',
      429 => 'Se alcanzó el límite de peticiones. Espera un momento e inténtalo de nuevo.',
      500 || 502 || 503 => 'La NASA está teniendo problemas con su servicio.',
      504 => 'El servicio tardó demasiado en responder.',
      _ => rawMsg ?? 'Error de conexión. Verifica tu internet e inténtalo de nuevo.',
    };
    return (code: code, message: message);
  }

    on<FetchApod>((event, emit) async {
      try {
        final apodData = await _apodRepository.getApod(state.date);
        emit(state.copyWith(
          status: ApodStatus.success,
          apodData: apodData,
          errorMessage: null,
          errorCode: null,
        ));
      } catch (error) {
        final err = friendlyError(error);
        emit(state.copyWith(
          status: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
        ));
      }
    });

    on<FetchMultipleApod>((event, emit) async {
      try {
        final multipleApodData =
            await _apodRepository.getMultipleApod(state.date);
        emit(state.copyWith(
          multipleApodData: multipleApodData,
          multiplestatus: ApodStatus.success,
          errorMessage: null,
          errorCode: null,
        ));
      } catch (error) {
        final err = friendlyError(error);
        emit(state.copyWith(
          multiplestatus: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
        ));
      }
    });
    on<FetchMultipleApodSized>((event, emit) async {
      try {
        final multipleApodData = await _apodRepository.getMultipleApod(state.date, count: event.count);
        emit(state.copyWith(
          multipleApodData: multipleApodData,
          multiplestatus: ApodStatus.success,
        ));
      } catch (error) {
        final err = friendlyError(error);
        emit(state.copyWith(
          multiplestatus: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
        ));
      }
    });
    on<FetchFavoriteApod>((event, emit) async {
      emit(state.copyWith(favoriteApodStatus: ApodStatus.loading));
      try {
        final favorites = await _apodRepository.getFavoritesApod();

        emit(state.copyWith(
          favoriteApodData: favorites,
          favoriteApodStatus: ApodStatus.success,
        ));
      } catch (error) {
        final err = friendlyError(error);
        emit(state.copyWith(
          favoriteApodStatus: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
        ));
      }
    });
    on<RefreshData>((event, emit) async {
      try {
        emit(state.copyWith(
          status: ApodStatus.loading,
          multiplestatus: ApodStatus.loading,
        ));

        final results = await Future.wait([
          _apodRepository.getApod(state.date),
          _apodRepository.getMultipleApod(state.date),
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
        final err = friendlyError(error);
        emit(state.copyWith(
          status: ApodStatus.failed,
          multiplestatus: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
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
          _apodRepository.getApod(newDate),
          _apodRepository.getMultipleApod(newDate),
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
        final err = friendlyError(error);
        emit(state.copyWith(
          status: ApodStatus.failed,
          multiplestatus: ApodStatus.failed,
          errorMessage: err.message,
          errorCode: err.code,
        ));
      }
    });
    // Handler de paginación eliminado
  }
}
