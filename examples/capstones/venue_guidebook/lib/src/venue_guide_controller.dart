import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

// #region guide-controller
class VenueGuideController extends ChangeNotifier {
  VenueGuideController({Locale initialLocale = const Locale('zh')})
    : _locale = initialLocale;

  Locale _locale;
  FocusNode? _searchFocusNode;

  Locale get locale => _locale;

  void setLocale(Locale locale, {FocusNode? restoreFocus}) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restoreFocus?.canRequestFocus ?? false) {
        restoreFocus!.requestFocus();
      }
    });
  }

  void registerSearchFocusNode(FocusNode node) {
    _searchFocusNode = node;
  }

  void unregisterSearchFocusNode(FocusNode node) {
    if (identical(_searchFocusNode, node)) {
      _searchFocusNode = null;
    }
  }

  void focusSearch(BuildContext context) {
    if (GoRouterState.of(context).uri.path != '/venues') {
      context.go('/venues');
    }
    _requestSearchFocus(remainingFrames: 3);
  }

  void _requestSearchFocus({required int remainingFrames}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final node = _searchFocusNode;
      if (node?.canRequestFocus ?? false) {
        node!.requestFocus();
      } else if (remainingFrames > 1) {
        _requestSearchFocus(remainingFrames: remainingFrames - 1);
      }
    });
  }
}
// #endregion guide-controller
