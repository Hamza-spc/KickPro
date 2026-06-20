import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/locale_provider.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final matchReminderServiceProvider = Provider<MatchReminderService>((ref) {
  return MatchReminderService(ref);
});

class MatchReminderService {
  MatchReminderService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    if (!kIsWeb) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> syncApprovedMatches({
    required List<FootballMatch> matches,
    required int myProfileId,
  }) async {
    await initialize();
    await _plugin.cancelAll();

    for (final match in matches) {
      if (match.status == MatchStatus.cancelled || match.status == MatchStatus.completed) {
        continue;
      }

      final myParticipant = match.participants.where((p) => p.playerId == myProfileId).firstOrNull;
      if (myParticipant?.status != ParticipantStatus.approved) continue;

      final reminderTime = match.dateTime.subtract(const Duration(hours: 1));
      if (!reminderTime.isAfter(DateTime.now())) continue;

      final locale = _ref.read(localeProvider);
      final title = locale.languageCode == 'fr' ? 'Rappel de match' : 'Match reminder';
      final body = locale.languageCode == 'fr'
          ? '${match.stadiumName} dans 1 heure'
          : '${match.stadiumName} in 1 hour';

      await _plugin.zonedSchedule(
        match.id,
        title,
        body,
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'match_reminders',
            'Match Reminders',
            channelDescription: 'Reminders before approved matches',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
