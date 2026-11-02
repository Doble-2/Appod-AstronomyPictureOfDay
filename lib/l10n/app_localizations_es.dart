// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get explore => 'Explorar';

  @override
  String get apodToday => 'Imagen del día';

  @override
  String get otherApods => 'Otras imágenes';

  @override
  String get downloadApod => 'Descargar imagen';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get removeFromFavorites => 'Eliminar de favoritos';

  @override
  String get pleaseLoginToSeeFavorites =>
      'Por favor, inicia sesión para ver tus favoritos';

  @override
  String get soon => 'Pronto';

  @override
  String get appeareance => 'Apariencia';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get account => 'Cuenta';

  @override
  String get favorites => 'Favoritos';

  @override
  String get favoritesLocalHint =>
      'Tus favoritos se guardan en este dispositivo. Inicia sesión para sincronizarlos.';

  @override
  String get noFavoritesYet =>
      'Aún no tienes favoritos. Toca el corazón en cualquier imagen para guardarla.';

  @override
  String get settings => 'Configuración';

  @override
  String get diariesNotification => 'Notificación diaria';

  @override
  String get qualityDownload => 'Calidad de descarga';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get notHaveAccount => '¿No tienes una cuenta? Regístrate';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get register => 'Registrarse';

  @override
  String get yetHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get extras => 'Extras';

  @override
  String get pleaseInterEmail => 'Por favor, introduce tu correo electrónico';

  @override
  String get pleaseInterPassword => 'Por favor, introduce tu contraseña';

  @override
  String get pleaseInterValidEmail =>
      'Por favor, introduce un correo electrónico válido';

  @override
  String get digitsPass => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get emailAlreadyInUse => 'El correo electrónico ya está en uso';

  @override
  String get getApp => 'Descargar app';

  @override
  String get getAppTitle => 'Recomendamos la app';

  @override
  String get getAppIntro =>
      'Este sitio fue creado originalmente como una app. Te recomendamos instalar la app para una experiencia completa.';

  @override
  String get getAppNotInPlay =>
      'Disponible directamente como APK — no necesitas Play Store. Instálala y disfruta la experiencia completa.';

  @override
  String get getAppAndroidOnly => 'Solo Android';

  @override
  String get getAppAction => 'Descargar APK';

  @override
  String get nasaDownTitle => 'Servicio de NASA con problemas';

  @override
  String nasaDownBody(Object code) {
    return 'No podemos cargar los contenidos porque los servicios de la NASA están fallando (error $code). Esto no depende de nosotros. Inténtalo de nuevo más tarde.';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get genericError => 'No se pudieron cargar los datos.';

  @override
  String get translate => 'Traducir';

  @override
  String get share => 'Compartir';

  @override
  String get translating => 'Traduciendo…';

  @override
  String get today => 'Hoy';

  @override
  String get previousDay => 'Día anterior';

  @override
  String get nextDay => 'Día siguiente';

  @override
  String get chooseDate => 'Elegir una fecha';

  @override
  String get backToToday => 'Ir a la imagen de hoy';

  @override
  String get previousDays => 'Días anteriores';

  @override
  String get readMore => 'Abrir esta imagen';

  @override
  String get viewFullScreen => 'Ver en pantalla completa';

  @override
  String get close => 'Cerrar';

  @override
  String get openVideo => 'Abrir video';

  @override
  String get imageLoadError => 'No se pudo cargar esta imagen.';

  @override
  String get imageCredit => 'Crédito';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutBody =>
      'Appod muestra la imagen astronómica del día de la NASA. Las imágenes y los textos pertenecen a la NASA y a sus autores acreditados. Appod no está afiliada a la NASA ni cuenta con su respaldo.';

  @override
  String get sourceCode => 'Código fuente en GitHub';

  @override
  String get loginToSync =>
      'Inicia sesión para conservar tus favoritos entre dispositivos.';

  @override
  String get favoritesError => 'No se pudieron cargar tus favoritos.';

  @override
  String get favoriteAdded => 'Añadida a favoritos';

  @override
  String get favoriteRemoved => 'Quitada de favoritos';

  @override
  String get errorBadDate =>
      'No hay imagen para esta fecha. Prueba con otro día.';

  @override
  String get errorKey => 'La clave de la NASA no es válida o caducó.';

  @override
  String get errorNotFound =>
      'No hay contenido para esta fecha. Prueba con otro día.';

  @override
  String get errorRateLimit =>
      'Demasiadas peticiones a la NASA. Espera un momento y vuelve a intentarlo.';

  @override
  String get errorNasa =>
      'El servicio de la NASA tiene problemas. Vuelve a intentarlo más tarde.';

  @override
  String get errorTimeout =>
      'La NASA tardó demasiado en responder. Vuelve a intentarlo.';

  @override
  String get errorConnection =>
      'Revisa tu conexión a internet y vuelve a intentarlo.';

  @override
  String get shareCopied => 'Enlace copiado. Pégalo donde quieras.';

  @override
  String get shareFailed => 'No se pudo compartir esta imagen.';

  @override
  String get downloadStarted => 'Descarga iniciada.';

  @override
  String get downloadFailed => 'No se pudo descargar esta imagen.';

  @override
  String get imageSaved => 'Imagen guardada en tu galería.';

  @override
  String get permissionDenied =>
      'Permite el acceso a tu galería para guardar imágenes.';

  @override
  String shareText(String date, String url) {
    return 'Mira la imagen astronómica del $date: $url';
  }

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get pageNotFound => 'Esta página no existe';

  @override
  String get pageNotFoundBody =>
      'La dirección es incorrecta o no hay imagen para esa fecha.';

  @override
  String get onThisDay => 'En este día';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String get fromTheArchive => 'Del archivo';

  @override
  String get showingSaved => 'Sin conexión. Mostrando lo guardado.';
}
