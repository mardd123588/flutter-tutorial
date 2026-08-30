import 'package:shared_preferences/shared_preferences.dart';

class EventPreferences {
  const EventPreferences({this.district = '全部', this.savedOnly = false});

  final String district;
  final bool savedOnly;
}

abstract interface class EventPreferenceStore {
  Future<EventPreferences> readPreferences();
  Future<void> writePreferences(EventPreferences value);
}

// #region async-preferences
class SharedPreferencesEventStore implements EventPreferenceStore {
  SharedPreferencesEventStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _districtKey = 'radar.district';
  static const _savedOnlyKey = 'radar.savedOnly';
  final SharedPreferencesAsync _preferences;

  @override
  Future<EventPreferences> readPreferences() async {
    return EventPreferences(
      district: await _preferences.getString(_districtKey) ?? '全部',
      savedOnly: await _preferences.getBool(_savedOnlyKey) ?? false,
    );
  }

  @override
  Future<void> writePreferences(EventPreferences value) async {
    await Future.wait([
      _preferences.setString(_districtKey, value.district),
      _preferences.setBool(_savedOnlyKey, value.savedOnly),
    ]);
  }
}
// #endregion async-preferences
