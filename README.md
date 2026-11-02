# APOD NASA (Flutter)

Aplicación Flutter multiplataforma (Web, Android, Desktop) para explorar Astronomy Picture of the Day con soporte responsive, internacionalización y modo oscuro.

## Características

- Layout responsive (breakpoints custom) con navegación adaptativa (bottom bar / side rail).
- Selector de fecha y mes (dropdown en desktop, carrusel en móvil).
- Vista detalle con traducción bajo demanda (Google unofficial) y acciones (favorito, descargar, ampliar).
- Favoritos persistentes (Firebase/AuthService) y theming dinámico.

## Estructura Clave

`lib/ui/responsive/responsive.dart` Breakpoints y `MaxWidthContainer`. `lib/utils/image_proxy.dart` Utilidad para proxificar imágenes en Web. `lib/ui/widgets/organisms/` Componentes adaptativos (layout, navigation, month selector, etc.).

## Fuente de datos

Las imágenes y los textos se leen de `science.nasa.gov` (`lib/data/nasa_site.dart`), adonde la NASA movió el archivo. `api.nasa.gov/planetary/apod` responde ahora con su logo como imagen, así que solo se usa como respaldo si el sitio falla y la API entrega datos válidos. El navegador puede leer ambos directamente, sin proxy.

## Ejecución local

Requisitos: Flutter estable (3.32+), Dart 3.8+, Chrome para Web opcional.

```bash
flutter pub get
flutter run
```

### Web

```bash
flutter run -d chrome
flutter build web --release
```

Las imágenes se leen directamente de la NASA, sin proxy. Las direcciones son limpias (`/apod/2026-10-26`), así que el servidor debe entregar `index.html` en cualquier ruta: `vercel.json` y `server_og.py` ya lo hacen.

## Variables Dart-Define adicionales

Puedes añadir más banderas personalizadas como `FLAVOR=dev` si las aprovechas en tu código.


## Accesibilidad

- Tooltips y Semantics en navegación, botones de acción y elementos de selección.
- Estructura de foco para desktop (month select y side rail).

## Próximas Mejores Prácticas

- Tests widget/golden para layouts anchos.
- Cache offline selectiva.
- Mejorar soporte de vídeo (media_type != image).

## Licencia

Este repositorio se distribuye bajo licencia MIT. Consulta el archivo `LICENSE`.
