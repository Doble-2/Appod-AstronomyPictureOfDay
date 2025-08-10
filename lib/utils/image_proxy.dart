import 'package:flutter/foundation.dart';
import 'package:nasa_apod/data/nasa.dart';

/// Utilidad para mitigar problemas CORS en Flutter Web con imágenes remotas.
///
/// Configura un proxy pasando una variable de entorno en build/run:
///   flutter run -d chrome --dart-define=IMAGE_PROXY=https://tu-proxy.example.com/?u=
/// El proxy debe:
///  1. Aceptar la URL destino en un parámetro (ej: ?u=URL_ENCODED) o concatenada.
///  2. Reenviar la petición y añadir cabecera: Access-Control-Allow-Origin: *
///  3. Opcional: añadir User-Agent de navegador para evitar bloqueos.
///
/// Ejemplo Cloudflare Worker:
/// ```js
/// export default { async fetch(req) {
///   const u=new URL(req.url).searchParams.get('u');
///   if(!u) return new Response('missing u',{status:400});
///   const r=await fetch(u,{headers:{'User-Agent':'Mozilla/5.0'}});
///   const h=new Headers(r.headers); h.set('Access-Control-Allow-Origin','*');
///   return new Response(r.body,{status:r.status,headers:h}); } }
/// ```
///
/// Si no se define IMAGE_PROXY o no estamos en web, se retorna la URL original.
// Variable de entorno esperada: IMAGE_PROXY_BASE_URL
// Ej: --dart-define=IMAGE_PROXY_BASE_URL=https://proxycp.onrender.com/proxy-img?url=
// Se prioriza la variable compile-time directa y como respaldo ApiConstants.imageProxyBaseUrl
const String _envImageProxy = String.fromEnvironment('IMAGE_PROXY_BASE_URL', defaultValue: '');

String get _kImageProxyBase {
  // Si se pasó por --dart-define gana esa.
  if (_envImageProxy.isNotEmpty) return _envImageProxy;
  // Respaldo (no debería cambiar en runtime)
  return ApiConstants.imageProxyBaseUrl;
}

String proxiedImageUrl(String url) {
  if (!kIsWeb) return url;
  final base = _kImageProxyBase;
  if (base.isEmpty) return url;
  // Si termina en '=' (caso ?url=) concatenamos la URL codificada
  if (base.endsWith('=')) {
    return '$base${Uri.encodeComponent(url)}';
  }
  // Si contiene '?' pero no termina en '=' asumimos que el backend espera URI codificada al final
  if (base.contains('?')) {
    return '$base${Uri.encodeComponent(url)}';
  }
  // Caso base: simple concatenación (asegurar slash si falta)
  return '$base${base.endsWith('/') ? '' : '/'}${Uri.encodeFull(url)}';
}
