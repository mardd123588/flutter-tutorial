enum RouteMode { balanced, quiet, fast }

extension RouteModeText on RouteMode {
  String get id => name;

  String get label => switch (this) {
    RouteMode.balanced => '均衡',
    RouteMode.quiet => '安静',
    RouteMode.fast => '快速',
  };

  String get note => switch (this) {
    RouteMode.balanced => '保留完整站点，按常规节奏行进。',
    RouteMode.quiet => '优先经过安静区域，并留出更多停留时间。',
    RouteMode.fast => '缩短停留时间，先看路线中的主要站点。',
  };
}

class TourRoute {
  const TourRoute({
    required this.id,
    required this.title,
    required this.summary,
    required this.durationMinutes,
    required this.distanceKilometers,
    required this.stops,
  });

  final String id;
  final String title;
  final String summary;
  final int durationMinutes;
  final double distanceKilometers;
  final List<String> stops;
}

const tourRoutes = <TourRoute>[
  TourRoute(
    id: 'museum-loop',
    title: '博物馆环线',
    summary: '从旧仓库出发，沿展馆和修复室绕回中庭。',
    durationMinutes: 75,
    distanceKilometers: 2.4,
    stops: ['旧仓库入口', '材料馆', '修复室', '声音走廊', '中央庭院'],
  ),
  TourRoute(
    id: 'river-workshops',
    title: '河岸工坊线',
    summary: '串起陶作、印刷和木工开放工坊，适合边走边看。',
    durationMinutes: 95,
    distanceKilometers: 3.1,
    stops: ['南侧坡道', '陶作间', '印刷所', '木工棚', '河岸平台'],
  ),
  TourRoute(
    id: 'night-beacons',
    title: '夜场灯标线',
    summary: '沿灯光装置穿过高架步道，终点是北侧观景台。',
    durationMinutes: 55,
    distanceKilometers: 1.8,
    stops: ['夜场服务台', '蓝灯巷', '高架步道', '风塔', '北侧观景台'],
  ),
];

TourRoute? routeById(String id) {
  for (final route in tourRoutes) {
    if (route.id == id) return route;
  }
  return null;
}
