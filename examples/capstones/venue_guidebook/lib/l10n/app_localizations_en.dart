// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Venue Guidebook';

  @override
  String get appSubtitle => 'Floors, places, and routes in one field guide';

  @override
  String get venuesDestination => 'Places';

  @override
  String get routesDestination => 'Routes';

  @override
  String get aboutDestination => 'About';

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get closeNavigation => 'Close navigation';

  @override
  String get languageLabel => 'Interface language';

  @override
  String get switchToChinese => '切换为中文';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get searchLabel => 'Search places';

  @override
  String get searchHint => 'Enter a gallery, facility, or tag';

  @override
  String get searchShortcutHint => 'Press / to focus search';

  @override
  String get clearSearch => 'Clear search';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places found',
      one: '1 place found',
      zero: 'No matching places',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'No places found';

  @override
  String get noResultsBody => 'Try another place name, floor, or tag.';

  @override
  String get browseAll => 'Show all places';

  @override
  String get featuredGuide => 'Today\'s guide index';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Guide date: $dateString';
  }

  @override
  String get viewVenue => 'View place';

  @override
  String venueItemLabel(String name, String floor, String tags) {
    return '$name, $floor, $tags';
  }

  @override
  String floorLabel(int floor) {
    return 'Floor $floor';
  }

  @override
  String floorShortLabel(int floor) {
    return 'F$floor';
  }

  @override
  String get allFloors => 'All floors';

  @override
  String get filterByFloor => 'Filter by floor';

  @override
  String get filterByTag => 'Filter by tag';

  @override
  String get clearTag => 'All tags';

  @override
  String get quietTag => 'Quiet';

  @override
  String get accessibleTag => 'Accessible';

  @override
  String get familyTag => 'Family';

  @override
  String get studioTag => 'Studio';

  @override
  String get selectedState => 'Selected';

  @override
  String get venueDetails => 'Place details';

  @override
  String get backToVenues => 'Back to places';

  @override
  String get openHours => 'Open hours';

  @override
  String openPeriod(String start, String end) {
    return '$start–$end';
  }

  @override
  String get currentFloor => 'Current floor';

  @override
  String get floorPlanTitle => 'Floor diagram';

  @override
  String floorPlanSummary(int floor, String rooms) {
    return 'Floor $floor diagram summary: $rooms';
  }

  @override
  String get placesOnFloor => 'Places on this floor';

  @override
  String get routeIndexTitle => 'Three indoor routes';

  @override
  String get routeIndexBody =>
      'Routes use fixed local data. Check the stop order, then walk at your own pace.';

  @override
  String routeStopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get aboutTitle => 'How this guidebook works';

  @override
  String get aboutBody =>
      'A stable place ID lives in the path. Floor and tag live in the query. Switching languages keeps the current address and place.';

  @override
  String get keyboardTitle => 'Keyboard';

  @override
  String get keyboardBody =>
      'Press / to focus place search. Press Escape to close temporary layers such as the drawer. While typing, / remains a normal character.';

  @override
  String get accessibilityTitle => 'The diagram is only a summary';

  @override
  String get accessibilityBody =>
      'The floor diagram has no controls. Screen readers receive a summary, while keyboard and touch actions live in the real place list.';

  @override
  String get linkErrorTitle => 'This place link cannot open';

  @override
  String get unmatchedTitle => 'No page matches this address';

  @override
  String unknownVenueError(String venueId) {
    return 'The place “$venueId” does not exist.';
  }

  @override
  String get invalidFloorError => 'floor must be an integer.';

  @override
  String unavailableFloorError(int floor) {
    return 'This place is not on floor $floor.';
  }

  @override
  String invalidTagError(String tag) {
    return 'The tag “$tag” does not apply to this place.';
  }

  @override
  String duplicateParameterError(String parameter) {
    return 'The parameter “$parameter” appears more than once.';
  }

  @override
  String unsupportedParameterError(String parameter) {
    return 'The parameter “$parameter” is not supported.';
  }

  @override
  String get repairLink => 'Return to places';

  @override
  String get unmatchedBody =>
      'This address has no content. Re-enter from Places, Routes, or About.';

  @override
  String get atriumName => 'Central Atrium';

  @override
  String get atriumSummary =>
      'The clearest orientation point, linking the main entry, galleries, and second-floor bridge.';

  @override
  String get materialHallName => 'Materials Hall';

  @override
  String get materialHallSummary =>
      'Repair samples in wood, paper, metal, and textile, arranged for close comparison.';

  @override
  String get soundLabName => 'Sound Lab';

  @override
  String get soundLabSummary =>
      'A bookable quiet space for collection recordings and soundscape works.';

  @override
  String get roofStudioName => 'Roof Studio';

  @override
  String get roofStudioSummary =>
      'A hands-on area for families and groups, with a terrace in good weather.';

  @override
  String get informationDesk => 'Information desk';

  @override
  String get mainGallery => 'Main gallery';

  @override
  String get quietAlcove => 'Quiet alcove';

  @override
  String get bridge => 'Bridge';

  @override
  String get materialsArchive => 'Materials archive';

  @override
  String get sampleTables => 'Sample tables';

  @override
  String get listeningRoom => 'Listening room';

  @override
  String get recordingBooth => 'Recording booth';

  @override
  String get workbench => 'Workbench';

  @override
  String get terrace => 'Terrace';

  @override
  String get orientationRoute => 'First visit';

  @override
  String get orientationRouteBody =>
      'Orient in the atrium, then visit Materials Hall and the Sound Lab.';

  @override
  String get quietRoute => 'Quiet route';

  @override
  String get quietRouteBody =>
      'Avoid studio hours and pass the quiet alcove, materials archive, and listening room.';

  @override
  String get familyRoute => 'Family route';

  @override
  String get familyRouteBody =>
      'Collect an activity sheet at the desk and finish a piece in the Roof Studio.';
}
