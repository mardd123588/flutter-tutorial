import 'dart:collection';

import 'package:flutter/foundation.dart';

enum PlantFilter { all, needsCare, stable }

extension PlantFilterLabel on PlantFilter {
  String get label => switch (this) {
    PlantFilter.all => '全部',
    PlantFilter.needsCare => '需要照护',
    PlantFilter.stable => '状态稳定',
  };
}

@immutable
class PlantRecord {
  const PlantRecord({
    required this.id,
    required this.name,
    required this.zone,
    required this.moisture,
    required this.targetMoisture,
    required this.observation,
  });

  final String id;
  final String name;
  final String zone;
  final int moisture;
  final int targetMoisture;
  final String observation;

  bool get needsCare => moisture < targetMoisture;

  PlantRecord copyWith({int? moisture, String? observation}) {
    return PlantRecord(
      id: id,
      name: name,
      zone: zone,
      moisture: moisture ?? this.moisture,
      targetMoisture: targetMoisture,
      observation: observation ?? this.observation,
    );
  }
}

const seedPlants = <PlantRecord>[
  PlantRecord(
    id: 'ficus-lyrata',
    name: '琴叶榕',
    zone: '东窗 02',
    moisture: 24,
    targetMoisture: 45,
    observation: '新叶边缘平整，盆土表层已经发白。',
  ),
  PlantRecord(
    id: 'asplenium',
    name: '鸟巢蕨',
    zone: '雾台 01',
    moisture: 38,
    targetMoisture: 50,
    observation: '中心叶片有光泽，外圈叶片略向下垂。',
  ),
  PlantRecord(
    id: 'calathea',
    name: '青苹果竹芋',
    zone: '遮阴架 03',
    moisture: 58,
    targetMoisture: 48,
    observation: '叶背颜色稳定，暂时不需要补水。',
  ),
  PlantRecord(
    id: 'rosemary',
    name: '直立迷迭香',
    zone: '南台 04',
    moisture: 67,
    targetMoisture: 40,
    observation: '通风正常，枝条保持直立。',
  ),
];

// #region change-notifier-controller
class PlantCareController extends ChangeNotifier {
  PlantCareController({List<PlantRecord> plants = seedPlants})
    : _plants = List<PlantRecord>.of(plants);

  List<PlantRecord> _plants;
  PlantFilter _filter = PlantFilter.all;
  _CareSnapshot? _undoSnapshot;
  String _message = '已载入 4 份温室记录。';

  UnmodifiableListView<PlantRecord> get plants =>
      UnmodifiableListView<PlantRecord>(_plants);

  PlantFilter get filter => _filter;
  String get message => _message;
  bool get canUndo => _undoSnapshot != null;
  int get needsCareCount => _plants.where((plant) => plant.needsCare).length;

  List<PlantRecord> get visiblePlants {
    return _plants
        .where((plant) {
          return switch (_filter) {
            PlantFilter.all => true,
            PlantFilter.needsCare => plant.needsCare,
            PlantFilter.stable => !plant.needsCare,
          };
        })
        .toList(growable: false);
  }

  void setFilter(PlantFilter nextFilter) {
    if (_filter == nextFilter) {
      return;
    }
    _filter = nextFilter;
    _message = '当前显示：${nextFilter.label}。';
    notifyListeners();
  }

  void waterPlant(String plantId) {
    final plantIndex = _plants.indexWhere((plant) => plant.id == plantId);
    if (plantIndex == -1) {
      return;
    }

    final plant = _plants[plantIndex];
    _undoSnapshot = _CareSnapshot(
      plants: List<PlantRecord>.of(_plants),
      filter: _filter,
      plantName: plant.name,
      previousMoisture: plant.moisture,
    );

    final nextMoisture = (plant.moisture + 42).clamp(0, 100);
    _plants[plantIndex] = plant.copyWith(
      moisture: nextMoisture,
      observation: '刚刚完成浇水，下一班复查叶片与盆底。',
    );
    _plants = List<PlantRecord>.of(_plants)..sort(_compareCarePriority);
    _message = '${plant.name}已浇水：${plant.moisture}% → $nextMoisture%。';
    notifyListeners();
  }

  void undoLastCare() {
    final snapshot = _undoSnapshot;
    if (snapshot == null) {
      return;
    }

    _plants = List<PlantRecord>.of(snapshot.plants);
    _filter = snapshot.filter;
    _undoSnapshot = null;
    _message = '已撤销：${snapshot.plantName}恢复到 ${snapshot.previousMoisture}%。';
    notifyListeners();
  }

  static int _compareCarePriority(PlantRecord first, PlantRecord second) {
    if (first.needsCare != second.needsCare) {
      return first.needsCare ? -1 : 1;
    }
    final moistureOrder = first.moisture.compareTo(second.moisture);
    return moistureOrder != 0
        ? moistureOrder
        : first.name.compareTo(second.name);
  }
}
// #endregion change-notifier-controller

class _CareSnapshot {
  const _CareSnapshot({
    required this.plants,
    required this.filter,
    required this.plantName,
    required this.previousMoisture,
  });

  final List<PlantRecord> plants;
  final PlantFilter filter;
  final String plantName;
  final int previousMoisture;
}
