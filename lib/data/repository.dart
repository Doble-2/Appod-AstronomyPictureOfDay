import 'nasa.dart';
import 'package:nasa_apod/domain/contract.dart';
import 'package:intl/intl.dart';

class ApodRepositoryImpl implements ApodRepository {
  final NetworkService _networkService;

  ApodRepositoryImpl(this._networkService);

  @override
  Future<Map<String, dynamic>?> getApod(String date) async {
    // Implement sign in using mock network service
    return await _networkService.getApod(date);
  }

  @override
  Future<List> getMultipleApod(String date) async {
    final List<Map<String, dynamic>> multipleApodData = [];
    final DateFormat format = DateFormat('yyyy-MM-dd');
    DateTime endDate = format.parse(date);
    final DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day - 7);
    endDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final String date = format.format(startDate.add(Duration(days: i)));
      // Aquí puedes agregar la lógica para obtener los datos de APOD para cada fecha
      final Map<String, dynamic> apodData = await _networkService.getApod(date);
      multipleApodData.add(apodData);
    }
    return multipleApodData;
  }
}
