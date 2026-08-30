enum VenueTag { quiet, accessible, family, studio }

extension VenueTagId on VenueTag {
  String get id => name;
}

enum VenueTextKey {
  atriumName,
  atriumSummary,
  materialHallName,
  materialHallSummary,
  soundLabName,
  soundLabSummary,
  roofStudioName,
  roofStudioSummary,
  informationDesk,
  mainGallery,
  quietAlcove,
  bridge,
  materialsArchive,
  sampleTables,
  listeningRoom,
  recordingBooth,
  workbench,
  terrace,
}

class Venue {
  const Venue({
    required this.id,
    required this.nameKey,
    required this.summaryKey,
    required this.floors,
    required this.tags,
    required this.roomsByFloor,
    required this.openStart,
    required this.openEnd,
  });

  final String id;
  final VenueTextKey nameKey;
  final VenueTextKey summaryKey;
  final List<int> floors;
  final Set<VenueTag> tags;
  final Map<int, List<VenueTextKey>> roomsByFloor;
  final String openStart;
  final String openEnd;
}

const venues = <Venue>[
  Venue(
    id: 'atrium',
    nameKey: VenueTextKey.atriumName,
    summaryKey: VenueTextKey.atriumSummary,
    floors: [1, 2],
    tags: {VenueTag.accessible, VenueTag.family},
    roomsByFloor: {
      1: [VenueTextKey.informationDesk, VenueTextKey.mainGallery],
      2: [VenueTextKey.quietAlcove, VenueTextKey.bridge],
    },
    openStart: '09:00',
    openEnd: '18:00',
  ),
  Venue(
    id: 'materials-hall',
    nameKey: VenueTextKey.materialHallName,
    summaryKey: VenueTextKey.materialHallSummary,
    floors: [1, 2],
    tags: {VenueTag.accessible, VenueTag.quiet},
    roomsByFloor: {
      1: [VenueTextKey.mainGallery, VenueTextKey.sampleTables],
      2: [VenueTextKey.materialsArchive, VenueTextKey.quietAlcove],
    },
    openStart: '10:00',
    openEnd: '17:30',
  ),
  Venue(
    id: 'sound-lab',
    nameKey: VenueTextKey.soundLabName,
    summaryKey: VenueTextKey.soundLabSummary,
    floors: [2, 3],
    tags: {VenueTag.quiet, VenueTag.accessible},
    roomsByFloor: {
      2: [VenueTextKey.listeningRoom, VenueTextKey.quietAlcove],
      3: [VenueTextKey.recordingBooth, VenueTextKey.listeningRoom],
    },
    openStart: '11:00',
    openEnd: '19:00',
  ),
  Venue(
    id: 'roof-studio',
    nameKey: VenueTextKey.roofStudioName,
    summaryKey: VenueTextKey.roofStudioSummary,
    floors: [4],
    tags: {VenueTag.family, VenueTag.studio},
    roomsByFloor: {
      4: [VenueTextKey.workbench, VenueTextKey.terrace],
    },
    openStart: '10:30',
    openEnd: '16:30',
  ),
];

Venue? venueById(String id) {
  for (final venue in venues) {
    if (venue.id == id) return venue;
  }
  return null;
}

class GuideRoute {
  const GuideRoute({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.venueIds,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final List<String> venueIds;
}

const guideRoutes = <GuideRoute>[
  GuideRoute(
    id: 'orientation',
    titleKey: 'orientationRoute',
    bodyKey: 'orientationRouteBody',
    venueIds: ['atrium', 'materials-hall', 'sound-lab'],
  ),
  GuideRoute(
    id: 'quiet',
    titleKey: 'quietRoute',
    bodyKey: 'quietRouteBody',
    venueIds: ['atrium', 'materials-hall', 'sound-lab'],
  ),
  GuideRoute(
    id: 'family',
    titleKey: 'familyRoute',
    bodyKey: 'familyRouteBody',
    venueIds: ['atrium', 'roof-studio'],
  ),
];
