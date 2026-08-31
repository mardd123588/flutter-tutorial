import 'package:flutter/services.dart';

abstract interface class ResourceShareService {
  Future<void> copyLink(String link);
}

class ClipboardResourceShareService implements ResourceShareService {
  const ClipboardResourceShareService();

  @override
  Future<void> copyLink(String link) {
    return Clipboard.setData(ClipboardData(text: link));
  }
}
