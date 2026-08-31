import 'package:characters/characters.dart';

enum ListingOrigin { fixture, local }

enum ExchangeCategory { tools, garden, kitchen, reading, eventKit, skill }

enum Neighborhood { qinghe, shiqiao, nanyuan, hebutou, songying, wangta }

enum HandoffMethod { locker, dutyDesk, inPerson }

enum ExchangeStatus { available, reserved, completed }

enum ExchangeSort { newest, earliestPickup, title }

enum ExchangeView { list, compactGrid }

extension ExchangeCategoryLabel on ExchangeCategory {
  String get label => switch (this) {
    ExchangeCategory.tools => '工具',
    ExchangeCategory.garden => '园艺',
    ExchangeCategory.kitchen => '厨房',
    ExchangeCategory.reading => '阅读',
    ExchangeCategory.eventKit => '活动物料',
    ExchangeCategory.skill => '技能时段',
  };
}

extension NeighborhoodLabel on Neighborhood {
  String get label => switch (this) {
    Neighborhood.qinghe => '青禾里',
    Neighborhood.shiqiao => '石桥巷',
    Neighborhood.nanyuan => '南园',
    Neighborhood.hebutou => '河埠头',
    Neighborhood.songying => '松影街',
    Neighborhood.wangta => '望塔坊',
  };
}

extension HandoffMethodLabel on HandoffMethod {
  String get label => switch (this) {
    HandoffMethod.locker => '社区共享柜',
    HandoffMethod.dutyDesk => '值班台',
    HandoffMethod.inPerson => '当面约定',
  };
}

extension ExchangeStatusLabel on ExchangeStatus {
  String get label => switch (this) {
    ExchangeStatus.available => '可认领',
    ExchangeStatus.reserved => '已认领完',
    ExchangeStatus.completed => '已完成',
  };
}

class AvailableWindow {
  const AvailableWindow({
    required this.id,
    required this.label,
    required this.order,
  });

  final String id;
  final String label;
  final int order;

  static const values = [
    AvailableWindow(id: 'weekday-evening', label: '工作日 18:30–20:30', order: 1),
    AvailableWindow(id: 'saturday-morning', label: '周六 09:00–12:00', order: 2),
    AvailableWindow(
      id: 'saturday-afternoon',
      label: '周六 14:00–17:30',
      order: 3,
    ),
    AvailableWindow(id: 'sunday-afternoon', label: '周日 13:30–17:00', order: 4),
  ];

  static AvailableWindow fromId(String id) {
    return values.firstWhere(
      (window) => window.id == id,
      orElse: () => values.first,
    );
  }
}

class ExchangeListing {
  const ExchangeListing({
    required this.id,
    required this.origin,
    required this.title,
    required this.description,
    required this.category,
    required this.neighborhood,
    required this.handoffMethod,
    required this.availableWindow,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.ownerId,
    required this.ownerDisplayName,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.claimedByCurrentUser = false,
  });

  final String id;
  final ListingOrigin origin;
  final String title;
  final String description;
  final ExchangeCategory category;
  final Neighborhood neighborhood;
  final HandoffMethod handoffMethod;
  final AvailableWindow availableWindow;
  final int totalQuantity;
  final int remainingQuantity;
  final String ownerId;
  final String ownerDisplayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool claimedByCurrentUser;

  ExchangeStatus get status {
    if (completedAt != null) return ExchangeStatus.completed;
    if (remainingQuantity == 0) return ExchangeStatus.reserved;
    return ExchangeStatus.available;
  }

  bool canBeClaimedBy(String userId) {
    return status == ExchangeStatus.available &&
        ownerId != userId &&
        !claimedByCurrentUser;
  }

  ExchangeListing copyWith({
    int? remainingQuantity,
    bool? claimedByCurrentUser,
  }) {
    return ExchangeListing(
      id: id,
      origin: origin,
      title: title,
      description: description,
      category: category,
      neighborhood: neighborhood,
      handoffMethod: handoffMethod,
      availableWindow: availableWindow,
      totalQuantity: totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      ownerId: ownerId,
      ownerDisplayName: ownerDisplayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      claimedByCurrentUser: claimedByCurrentUser ?? this.claimedByCurrentUser,
    );
  }
}

class ExchangeClaim {
  const ExchangeClaim({
    required this.listingId,
    required this.claimantId,
    required this.claimedAt,
  });

  final String listingId;
  final String claimantId;
  final DateTime claimedAt;
}

class ExchangeQuery {
  const ExchangeQuery({
    this.search = '',
    this.neighborhood,
    this.category,
    this.status,
    this.sort = ExchangeSort.newest,
    this.view = ExchangeView.list,
  });

  final String search;
  final Neighborhood? neighborhood;
  final ExchangeCategory? category;
  final ExchangeStatus? status;
  final ExchangeSort sort;
  final ExchangeView view;

  String get normalizedSearch => search.trim().toLowerCase();

  bool matches(ExchangeListing listing) {
    final term = normalizedSearch;
    final searchable =
        '${listing.title} ${listing.description} ${listing.ownerDisplayName}'
            .toLowerCase();
    return (term.isEmpty || searchable.contains(term)) &&
        (neighborhood == null || listing.neighborhood == neighborhood) &&
        (category == null || listing.category == category) &&
        (status == null || listing.status == status);
  }

  List<ExchangeListing> apply(Iterable<ExchangeListing> source) {
    final result = source.where(matches).toList(growable: false);
    result.sort((left, right) {
      final comparison = switch (sort) {
        ExchangeSort.newest => right.createdAt.compareTo(left.createdAt),
        ExchangeSort.earliestPickup => left.availableWindow.order.compareTo(
          right.availableWindow.order,
        ),
        ExchangeSort.title => left.title.compareTo(right.title),
      };
      return comparison != 0 ? comparison : left.id.compareTo(right.id);
    });
    return result;
  }

  @override
  bool operator ==(Object other) {
    return other is ExchangeQuery &&
        other.search == search &&
        other.neighborhood == neighborhood &&
        other.category == category &&
        other.status == status &&
        other.sort == sort &&
        other.view == view;
  }

  @override
  int get hashCode =>
      Object.hash(search, neighborhood, category, status, sort, view);
}

class PublishDraft {
  const PublishDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.neighborhood,
    required this.handoffMethod,
    required this.availableWindow,
    required this.quantityText,
  });

  final String title;
  final String description;
  final ExchangeCategory category;
  final Neighborhood neighborhood;
  final HandoffMethod handoffMethod;
  final AvailableWindow availableWindow;
  final String quantityText;

  Map<String, String> validate() {
    final errors = <String, String>{};
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();
    final quantity = int.tryParse(quantityText.trim());
    if (normalizedTitle.isEmpty) {
      errors['title'] = '请填写资源名称。';
    } else if (normalizedTitle.characters.length > 40) {
      errors['title'] = '资源名称不能超过 40 个字符。';
    }
    if (normalizedDescription.characters.length > 240) {
      errors['description'] = '说明不能超过 240 个字符。';
    }
    if (quantity == null || quantity < 1 || quantity > 9) {
      errors['quantity'] = '数量必须是 1 到 9 的整数。';
    }
    return errors;
  }
}

const localUserId = 'local-neighbor';
const localUserDisplayName = '林澄';
