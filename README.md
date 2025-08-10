# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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

## Ejecución Local

Asegura Flutter actualizado.

```bash
flutter pub get
flutter run
```

### Web con Proxy de Imágenes (CORS)

La API/APOD no envía cabeceras CORS para imágenes → necesitas un proxy si pruebas en Web.

1. Despliega (o usa) un proxy compatible (ejemplo proporcionado en `server.js`).
2. Define la variable `IMAGE_PROXY` al correr en Chrome. IMPORTANTE: envolver el argumento en comillas para zsh.

```bash
flutter run -d chrome '--dart-define=IMAGE_PROXY=https://proxycp.onrender.com/proxy-img?url='
```

Build release web:

```bash
flutter build web '--dart-define=IMAGE_PROXY=https://proxycp.onrender.com/proxy-img?url='
```

#### Cómo funciona

El código llama `proxiedImageUrl(originalUrl)` que retorna:

- URL original (plataformas nativas / si no defines proxy)
- `IMAGE_PROXY + encode(originalUrl)` en Web.

Archivo relevante: `lib/utils/image_proxy.dart`.

#### Evitar problemas zsh

`?` actúa como comodín → usa comillas o escapa:

```bash
flutter run -d chrome --dart-define=IMAGE_PROXY=https://proxycp.onrender.com/proxy-img\?url=
```

## Variables Dart-Define adicionales

Puedes añadir más:

```bash
flutter run -d chrome \
  '--dart-define=IMAGE_PROXY=https://proxycp.onrender.com/proxy-img?url=' \
  '--dart-define=FLAVOR=dev'
```

## Proxy Node (Resumen)

Características recomendadas: whitelist de hosts, rate limit, cache LRU, cabeceras CORS. Ruta ejemplo: `/proxy-img?url=`.

## Accesibilidad

- Tooltips y Semantics en navegación, botones de acción y elementos de selección.
- Estructura de foco para desktop (month select y side rail).

## Próximas Mejores Prácticas

- Tests widget/golden para layouts anchos.
- Cache offline selectiva.
- Mejorar soporte de vídeo (media_type != image).

## Licencia

Uso educativo/demostración.
