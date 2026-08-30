import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care_desk/src/plant_data.dart';

void main() {
  test('filters records without duplicating source state', () {
    final controller = PlantCareController();

    controller.setFilter(PlantFilter.needsCare);

    expect(controller.visiblePlants.map((plant) => plant.id), [
      'ficus-lyrata',
      'asplenium',
    ]);
    expect(controller.plants, hasLength(4));
    controller.dispose();
  });

  test('watering reorders care priority and stores one undo snapshot', () {
    final controller = PlantCareController();

    controller.waterPlant('ficus-lyrata');

    expect(controller.plants.first.id, 'asplenium');
    expect(
      controller.plants
          .singleWhere((plant) => plant.id == 'ficus-lyrata')
          .moisture,
      66,
    );
    expect(controller.canUndo, isTrue);

    controller.undoLastCare();

    expect(controller.plants.first.id, 'ficus-lyrata');
    expect(controller.plants.first.moisture, 24);
    expect(controller.canUndo, isFalse);
    controller.dispose();
  });

  test('undo restores the filter active before care', () {
    final controller = PlantCareController();
    controller.setFilter(PlantFilter.needsCare);
    controller.waterPlant('ficus-lyrata');
    controller.setFilter(PlantFilter.all);

    controller.undoLastCare();

    expect(controller.filter, PlantFilter.needsCare);
    expect(controller.visiblePlants.map((plant) => plant.id), [
      'ficus-lyrata',
      'asplenium',
    ]);
    controller.dispose();
  });
}
