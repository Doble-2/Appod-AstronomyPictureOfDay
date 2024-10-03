abstract class ApodRepository {
  Future<Map<String, dynamic>?> getApod(String date);
  Future<List> getMultipleApod(String date);
  Future<List> getFavoritesApod();
}
