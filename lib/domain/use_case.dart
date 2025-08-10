import 'package:nasa_apod/domain/contract.dart';

class ApodUseCase {
  final ApodRepository _apodRepository;

  ApodUseCase(this._apodRepository);

  Future<Map<String, dynamic>?> getApod(String date) =>
      _apodRepository.getApod(date);
    Future<List> getMultipleApod(String date, {int count = 5}) =>
            _apodRepository.getMultipleApod(date, count: count);
  Future<List> getFavoritesApod() => _apodRepository.getFavoritesApod();
    // Método de rango eliminado
}
