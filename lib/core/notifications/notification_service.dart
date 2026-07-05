import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Envoltorio simple sobre flutter_local_notifications para programar
/// recordatorios de los eventos del calendario.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  Future<void> init() async {
    if (_inicializado) return;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const macSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macSettings,
    );

    try {
      await _plugin.initialize(settings);
      _inicializado = true;
    } catch (_) {
      // En plataformas de escritorio (Windows/Linux) usadas solo para
      // previsualizar, las notificaciones pueden no estar disponibles;
      // la app sigue funcionando normalmente sin ellas.
      _inicializado = false;
    }
  }

  Future<void> programarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    if (!_inicializado) return;
    if (fecha.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'agro_app_eventos',
      'Eventos del calendario',
      channelDescription: 'Recordatorios de siembras, cosechas, vacunas, etc.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        titulo,
        cuerpo,
        tz.TZDateTime.from(fecha, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Si la plataforma actual no soporta notificaciones programadas
      // (por ejemplo, algunos entornos de escritorio), lo ignoramos
      // silenciosamente: el evento queda igual guardado en el calendario.
    }
  }

  Future<void> cancelarNotificacion(int id) async {
    if (!_inicializado) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }
}
