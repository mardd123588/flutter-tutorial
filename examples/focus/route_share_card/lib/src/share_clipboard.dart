import 'package:flutter/services.dart';

abstract interface class ShareClipboard {
  Future<void> copy(String text);
}

class SystemShareClipboard implements ShareClipboard {
  const SystemShareClipboard();

  @override
  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
