import 'exchange_models.dart';

class ExchangeUrlCodec {
  const ExchangeUrlCodec();

  ExchangeQuery parse(Uri uri) {
    final parameters = uri.queryParameters;
    return ExchangeQuery(
      search: parameters['q']?.trim() ?? '',
      neighborhood: _enumByName(
        Neighborhood.values,
        parameters['neighborhood'],
      ),
      category: _enumByName(ExchangeCategory.values, parameters['category']),
      status: _enumByName(ExchangeStatus.values, parameters['status']),
      sort:
          _enumByName(ExchangeSort.values, parameters['sort']) ??
          ExchangeSort.newest,
      view:
          _enumByName(ExchangeView.values, parameters['view']) ??
          ExchangeView.list,
    );
  }

  Uri encode({required String path, required ExchangeQuery query}) {
    final parameters = <String, String>{};
    if (query.search.trim().isNotEmpty) parameters['q'] = query.search.trim();
    if (query.neighborhood != null) {
      parameters['neighborhood'] = query.neighborhood!.name;
    }
    if (query.category != null) parameters['category'] = query.category!.name;
    if (query.status != null) parameters['status'] = query.status!.name;
    if (query.sort != ExchangeSort.newest) parameters['sort'] = query.sort.name;
    if (query.view != ExchangeView.list) parameters['view'] = query.view.name;
    return Uri(
      path: path,
      queryParameters: parameters.isEmpty ? null : parameters,
    );
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
