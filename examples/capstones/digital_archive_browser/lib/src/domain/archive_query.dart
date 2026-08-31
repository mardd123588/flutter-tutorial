import 'archive_models.dart';

enum ArchiveSort {
  year('year', '按年代'),
  title('title', '按题名');

  const ArchiveSort(this.slug, this.label);

  final String slug;
  final String label;
}

enum ArchiveView {
  list('list', '列表'),
  grid('grid', '紧凑网格');

  const ArchiveView(this.slug, this.label);

  final String slug;
  final String label;
}

// #region archive-url-query
class ArchiveQuery {
  const ArchiveQuery({
    this.search = '',
    this.era,
    this.collection,
    this.access,
    this.sort = ArchiveSort.year,
    this.view = ArchiveView.list,
  });

  factory ArchiveQuery.fromUri(Uri uri) {
    final parameters = uri.queryParametersAll;
    final search = _single(parameters, 'q');
    return ArchiveQuery(
      search: search == null ? '' : _collapseWhitespace(search),
      era: _enumBySlug(
        ArchiveEra.values,
        _single(parameters, 'era'),
        (v) => v.slug,
      ),
      collection: _enumBySlug(
        ArchiveCollection.values,
        _single(parameters, 'collection'),
        (value) => value.slug,
      ),
      access: _enumBySlug(
        ArchiveAccess.values,
        _single(parameters, 'access'),
        (value) => value.slug,
      ),
      sort:
          _enumBySlug(
            ArchiveSort.values,
            _single(parameters, 'sort'),
            (value) => value.slug,
          ) ??
          ArchiveSort.year,
      view:
          _enumBySlug(
            ArchiveView.values,
            _single(parameters, 'view'),
            (value) => value.slug,
          ) ??
          ArchiveView.list,
    );
  }

  final String search;
  final ArchiveEra? era;
  final ArchiveCollection? collection;
  final ArchiveAccess? access;
  final ArchiveSort sort;
  final ArchiveView view;

  ArchiveQuery copyWith({
    String? search,
    ArchiveEra? Function()? era,
    ArchiveCollection? Function()? collection,
    ArchiveAccess? Function()? access,
    ArchiveSort? sort,
    ArchiveView? view,
  }) {
    return ArchiveQuery(
      search: search == null ? this.search : _collapseWhitespace(search),
      era: era == null ? this.era : era(),
      collection: collection == null ? this.collection : collection(),
      access: access == null ? this.access : access(),
      sort: sort ?? this.sort,
      view: view ?? this.view,
    );
  }

  Map<String, String> toQueryParameters() => {
    if (search.isNotEmpty) 'q': search,
    if (era != null) 'era': era!.slug,
    if (collection != null) 'collection': collection!.slug,
    if (access != null) 'access': access!.slug,
    if (sort != ArchiveSort.year) 'sort': sort.slug,
    if (view != ArchiveView.list) 'view': view.slug,
  };

  Uri toUri({String path = '/archive'}) {
    final parameters = toQueryParameters();
    return Uri(
      path: path,
      queryParameters: parameters.isEmpty ? null : parameters,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ArchiveQuery &&
      other.search == search &&
      other.era == era &&
      other.collection == collection &&
      other.access == access &&
      other.sort == sort &&
      other.view == view;

  @override
  int get hashCode => Object.hash(search, era, collection, access, sort, view);
}
// #endregion archive-url-query

String? _single(Map<String, List<String>> parameters, String key) {
  final values = parameters[key];
  return values?.length == 1 ? values!.single : null;
}

T? _enumBySlug<T>(List<T> values, String? slug, String Function(T) readSlug) {
  if (slug == null) return null;
  for (final value in values) {
    if (readSlug(value) == slug) return value;
  }
  return null;
}

String _collapseWhitespace(String value) => value
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .join(' ');
