import 'event.dart';
import 'event_cache.dart';

abstract interface class EventLocalStore {
  Stream<Set<String>> watchSavedIds();
  Future<void> toggleSaved(CityEvent event);
  Future<CachedEventFeed?> readCache();
  Future<void> writeCache(CachedEventFeed value);
  Future<void> close();
}
