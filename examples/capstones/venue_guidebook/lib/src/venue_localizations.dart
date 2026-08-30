import '../l10n/app_localizations.dart';
import 'venue_data.dart';

extension VenueLocalizations on AppLocalizations {
  String venueText(VenueTextKey key) => switch (key) {
    VenueTextKey.atriumName => atriumName,
    VenueTextKey.atriumSummary => atriumSummary,
    VenueTextKey.materialHallName => materialHallName,
    VenueTextKey.materialHallSummary => materialHallSummary,
    VenueTextKey.soundLabName => soundLabName,
    VenueTextKey.soundLabSummary => soundLabSummary,
    VenueTextKey.roofStudioName => roofStudioName,
    VenueTextKey.roofStudioSummary => roofStudioSummary,
    VenueTextKey.informationDesk => informationDesk,
    VenueTextKey.mainGallery => mainGallery,
    VenueTextKey.quietAlcove => quietAlcove,
    VenueTextKey.bridge => bridge,
    VenueTextKey.materialsArchive => materialsArchive,
    VenueTextKey.sampleTables => sampleTables,
    VenueTextKey.listeningRoom => listeningRoom,
    VenueTextKey.recordingBooth => recordingBooth,
    VenueTextKey.workbench => workbench,
    VenueTextKey.terrace => terrace,
  };

  String venueName(Venue venue) => venueText(venue.nameKey);

  String venueSummary(Venue venue) => venueText(venue.summaryKey);

  String tagLabel(VenueTag tag) => switch (tag) {
    VenueTag.quiet => quietTag,
    VenueTag.accessible => accessibleTag,
    VenueTag.family => familyTag,
    VenueTag.studio => studioTag,
  };

  String guideRouteTitle(GuideRoute route) => switch (route.id) {
    'orientation' => orientationRoute,
    'quiet' => quietRoute,
    'family' => familyRoute,
    _ => route.id,
  };

  String guideRouteBody(GuideRoute route) => switch (route.id) {
    'orientation' => orientationRouteBody,
    'quiet' => quietRouteBody,
    'family' => familyRouteBody,
    _ => route.id,
  };
}
