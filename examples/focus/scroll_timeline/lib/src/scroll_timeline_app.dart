import 'package:flutter/material.dart';

import 'timeline_page.dart';
import 'timeline_theme.dart';

class ScrollTimelineApp extends StatelessWidget {
  const ScrollTimelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '长卷时间轴',
      theme: buildTimelineTheme(),
      home: const TimelinePage(),
    );
  }
}
