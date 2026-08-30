import 'dart:async';

import 'package:flutter/foundation.dart';

import 'book.dart';
import 'book_search_service.dart';

enum BookSearchPhase { idle, loading, success, empty, failure }

class BookSearchController extends ChangeNotifier {
  BookSearchController({
    required this._service,
    this.debounceDuration = const Duration(milliseconds: 320),
  });

  final BookSearchService _service;
  final Duration debounceDuration;

  Timer? _debounceTimer;
  int _issuedRequest = 0;
  int _activeRequest = 0;
  bool _disposed = false;

  BookSearchPhase phase = BookSearchPhase.idle;
  String query = '';
  String settledQuery = '';
  List<Book> results = const [];
  String? errorMessage;
  int ignoredResponseCount = 0;

  int get activeRequest => _activeRequest;
  bool get keepsPreviousResults =>
      phase == BookSearchPhase.loading && results.isNotEmpty;

  // #region debounce-and-generation
  void updateQuery(String value) {
    query = value.trim();
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _activeRequest = ++_issuedRequest;
      phase = BookSearchPhase.idle;
      settledQuery = '';
      results = const [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    phase = BookSearchPhase.loading;
    errorMessage = null;
    notifyListeners();
    _debounceTimer = Timer(debounceDuration, () => _run(query));
  }

  Future<void> retry() => _run(query);

  Future<void> searchNow(String value) async {
    query = value.trim();
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      updateQuery('');
      return;
    }
    await _run(query);
  }

  Future<void> _run(String requestedQuery) async {
    final request = ++_issuedRequest;
    _activeRequest = request;
    phase = BookSearchPhase.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final nextResults = await _service.search(requestedQuery);
      if (request != _activeRequest || _disposed) {
        if (!_disposed) {
          ignoredResponseCount += 1;
          notifyListeners();
        }
        return;
      }
      settledQuery = requestedQuery;
      results = nextResults;
      phase = nextResults.isEmpty
          ? BookSearchPhase.empty
          : BookSearchPhase.success;
    } on BookSearchException catch (error) {
      if (request != _activeRequest || _disposed) {
        if (!_disposed) {
          ignoredResponseCount += 1;
          notifyListeners();
        }
        return;
      }
      settledQuery = requestedQuery;
      phase = BookSearchPhase.failure;
      errorMessage = error.message;
    } catch (error) {
      if (request != _activeRequest || _disposed) {
        if (!_disposed) {
          ignoredResponseCount += 1;
          notifyListeners();
        }
        return;
      }
      settledQuery = requestedQuery;
      phase = BookSearchPhase.failure;
      errorMessage = '检索失败：$error';
    }

    if (!_disposed) notifyListeners();
  }
  // #endregion debounce-and-generation

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}
