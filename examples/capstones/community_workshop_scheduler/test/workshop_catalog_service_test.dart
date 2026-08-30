import 'package:community_workshop_scheduler/src/data/workshop_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fixture catalog keeps the fixed learning-project contract', () async {
    const service = FixtureWorkshopCatalogService();

    final catalog = await service.load();

    expect(catalog.days, hasLength(2));
    expect(catalog.venues, hasLength(3));
    expect(catalog.instructors, hasLength(5));
    expect(catalog.workshops, hasLength(8));
    expect(catalog.initialSchedule, hasLength(10));
    expect(
      catalog.initialSchedule.map((entry) => entry.id),
      orderedEquals([
        'session-01',
        'session-02',
        'session-03',
        'session-04',
        'session-05',
        'session-06',
        'session-07',
        'session-08',
        'session-09',
        'session-10',
      ]),
    );
  });
}
