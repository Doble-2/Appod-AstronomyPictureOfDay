# APOD NASA (Flutter)

Aplicación Flutter multiplataforma (Web, Android, Desktop) para explorar Astronomy Picture of the Day con soporte responsive, internacionalización y modo oscuro.

## Características

- Layout responsive (breakpoints custom) con navegación adaptativa (bottom bar / side rail).
- Selector de fecha y mes (dropdown en desktop, carrusel en móvil).
- Vista detalle con traducción bajo demanda (Google unofficial) y acciones (favorito, descargar, ampliar).
- Favoritos persistentes (Firebase/AuthService) y theming dinámico.
- Mitigación CORS en Web mediante proxy configurable.

## Estructura Clave

`lib/ui/responsive/responsive.dart` Breakpoints y `MaxWidthContainer`. `lib/utils/image_proxy.dart` Utilidad para proxificar imágenes en Web. `lib/ui/widgets/organisms/` Componentes adaptativos (layout, navigation, month selector, etc.).

## Ejecución local

Requisitos: Flutter estable (3.32+), Dart 3.8+, Chrome para Web opcional.

```bash
flutter pub get
flutter run
```

### Web y CORS de imágenes (proxy opcional)

La API de NASA APOD no envía cabeceras CORS para imágenes en algunos dominios. Para Web puedes usar un proxy.

Variables soportadas en build/run:

- NASA_KEY: tu clave de API de NASA (opcional; por defecto usa DEMO_KEY).
- IMAGE_PROXY_BASE_URL: base del proxy para imágenes. Ej: https://proxycp.onrender.com/proxy-img?url=

Ejecutar en Chrome con zsh (escapar el ? o usar comillas):

```bash
flutter run -d chrome \
  --dart-define=NASA_KEY=TU_CLAVE \
  --dart-define=IMAGE_PROXY_BASE_URL=https://proxycp.onrender.com/proxy-img\?url=
```

Build web release:

```bash
flutter build web \
  --release \
  --dart-define=NASA_KEY=TU_CLAVE \
  --dart-define=IMAGE_PROXY_BASE_URL=https://proxycp.onrender.com/proxy-img\?url=
```

Cómo funciona: `proxiedImageUrl(originalUrl)` devuelve la URL original en nativo y `IMAGE_PROXY_BASE_URL + encode(originalUrl)` en Web. Implementación en `lib/utils/image_proxy.dart`.

## Variables Dart-Define adicionales

Puedes añadir más banderas personalizadas como `FLAVOR=dev` si las aprovechas en tu código.

## Proxy recomendado (resumen)

Sea cual sea la tecnología (Node, Cloudflare Worker, etc.), se sugiere: whitelist de hosts, rate limit, cache LRU, y cabeceras CORS. Ruta ejemplo: `/proxy-img?url=`.

## Accesibilidad

- Tooltips y Semantics en navegación, botones de acción y elementos de selección.
- Estructura de foco para desktop (month select y side rail).

## Próximas Mejores Prácticas

- Tests widget/golden para layouts anchos.
- Cache offline selectiva.
- Mejorar soporte de vídeo (media_type != image).

## Licencia

Este repositorio se distribuye bajo licencia MIT. Consulta el archivo `LICENSE`.
