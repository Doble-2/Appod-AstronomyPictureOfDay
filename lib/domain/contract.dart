abstract class ApodRepository {
  Future<Map<String, dynamic>?> getApod(String date);
  Future<List> getMultipleApod(String date, {int count = 5});
  Future<List> getFavoritesApod();
  // getApodRange eliminado (paginación retirada)
}
