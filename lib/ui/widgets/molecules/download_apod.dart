// Exporta implementación específica según plataforma.
export 'download_apod_io.dart'
  if (dart.library.html) 'download_apod_web.dart';
