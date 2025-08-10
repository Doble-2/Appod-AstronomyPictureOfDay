import 'package:flutter/foundation.dart';

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
const String _kImageProxy = String.fromEnvironment('IMAGE_PROXY', defaultValue: '');

String proxiedImageUrl(String url) {
  if (!kIsWeb) return url;
  if (_kImageProxy.isEmpty) return url;
  if (_kImageProxy.contains('?')) {
    return '$_kImageProxy${Uri.encodeComponent(url)}';
  }
  return '$_kImageProxy${Uri.encodeFull(url)}';
}
