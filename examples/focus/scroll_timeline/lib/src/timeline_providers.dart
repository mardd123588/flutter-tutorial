import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timeline_data.dart';

final selectedTopicsProvider =
    NotifierProvider<SelectedTopicsController, Set<TimelineTopic>>(
      SelectedTopicsController.new,
    );

final filteredTimelineProvider = Provider<List<TimelineEvent>>((ref) {
  return filterTimelineEvents(ref.watch(selectedTopicsProvider));
});

class SelectedTopicsController extends Notifier<Set<TimelineTopic>> {
  @override
  Set<TimelineTopic> build() => const {};

  void toggle(TimelineTopic topic) {
    state = state.contains(topic)
        ? Set.unmodifiable(state.where((candidate) => candidate != topic))
        : Set.unmodifiable({...state, topic});
  }

  void clear() {
    state = const {};
  }
}
