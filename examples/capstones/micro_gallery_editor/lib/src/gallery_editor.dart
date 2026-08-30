import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_gallery_editor/src/gallery_data.dart';

const _wallBlue = Color(0xFF153A8A);
const _deepBlue = Color(0xFF0A1E4B);
const _labelPaper = Color(0xFFF3E9D0);
const _brass = Color(0xFFD8B55B);
const _coral = Color(0xFFFF6F61);
const _ink = Color(0xFF172039);
const _quietInk = Color(0xFF596078);

class MicroGalleryEditorApp extends StatelessWidget {
  const MicroGalleryEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _wallBlue,
      brightness: Brightness.light,
      surface: _labelPaper,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '小型展览编辑器',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _deepBlue,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _wallBlue,
          selectionColor: Color(0x66D8B55B),
          selectionHandleColor: _wallBlue,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFBF1),
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF9C937F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: _wallBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFFB42318), width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _wallBlue,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            side: const BorderSide(color: _ink),
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
      home: const MicroGalleryEditorPage(),
    );
  }
}

class _SaveExhibitIntent extends Intent {
  const _SaveExhibitIntent();
}

class _NewExhibitIntent extends Intent {
  const _NewExhibitIntent();
}

// #region keyboard-shortcuts
const _editorShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveExhibitIntent(),
  SingleActivator(LogicalKeyboardKey.keyS, meta: true): _SaveExhibitIntent(),
  SingleActivator(LogicalKeyboardKey.keyN, control: true): _NewExhibitIntent(),
  SingleActivator(LogicalKeyboardKey.keyN, meta: true): _NewExhibitIntent(),
};
// #endregion keyboard-shortcuts

class MicroGalleryEditorPage extends StatefulWidget {
  const MicroGalleryEditorPage({super.key});

  @override
  State<MicroGalleryEditorPage> createState() => _MicroGalleryEditorPageState();
}

// #region input-lifecycle
class _MicroGalleryEditorPageState extends State<MicroGalleryEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode(debugLabel: '展品标题');
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _yearController;
  late final TextEditingController _mediumController;
  late final TextEditingController _noteController;

  final List<Exhibit> _exhibits = List.of(seedExhibits);
  String? _selectedId = seedExhibits.first.id;
  String _query = '';
  bool _showValidation = false;
  String _status = '已载入 3 件展品';
  int _nextId = 4;

  @override
  void initState() {
    super.initState();
    final exhibit = seedExhibits.first;
    _titleController = TextEditingController(text: exhibit.title);
    _artistController = TextEditingController(text: exhibit.artist);
    _yearController = TextEditingController(text: exhibit.year.toString());
    _mediumController = TextEditingController(text: exhibit.medium);
    _noteController = TextEditingController(text: exhibit.note);
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _mediumController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  // #endregion input-lifecycle

  void _writeControllers(Exhibit exhibit) {
    _titleController.text = exhibit.title;
    _artistController.text = exhibit.artist;
    _yearController.text = exhibit.year.toString();
    _mediumController.text = exhibit.medium;
    _noteController.text = exhibit.note;
  }

  void _selectExhibit(Exhibit exhibit) {
    setState(() {
      _selectedId = exhibit.id;
      _showValidation = false;
      _status = '正在编辑“${exhibit.title}”';
      _writeControllers(exhibit);
    });
  }

  void _beginNewExhibit() {
    setState(() {
      _selectedId = null;
      _showValidation = false;
      _status = '正在新建展品';
      _titleController.clear();
      _artistController.clear();
      _yearController.clear();
      _mediumController.clear();
      _noteController.clear();
    });
    _titleFocus.requestFocus();
  }

  // #region form-submit
  void _saveExhibit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _showValidation = true;
        _status = '请先修正表单中的问题';
      });
      return;
    }

    final title = _titleController.text.trim();
    final exhibit = Exhibit(
      id: _selectedId ?? 'work-${_nextId.toString().padLeft(2, '0')}',
      title: title,
      artist: _artistController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      medium: _mediumController.text.trim(),
      note: _noteController.text.trim(),
    );

    setState(() {
      final index = _exhibits.indexWhere((item) => item.id == _selectedId);
      if (index == -1) {
        _exhibits.add(exhibit);
        _nextId += 1;
        _status = '已新增“$title”';
      } else {
        _exhibits[index] = exhibit;
        _status = '已保存“$title”';
      }
      _selectedId = exhibit.id;
      _showValidation = false;
    });
  }
  // #endregion form-submit

  void _deleteSelected() {
    final index = _exhibits.indexWhere((item) => item.id == _selectedId);
    if (index == -1) return;

    final removedTitle = _exhibits[index].title;
    setState(() {
      _exhibits.removeAt(index);
      if (_exhibits.isEmpty) {
        _selectedId = null;
        _titleController.clear();
        _artistController.clear();
        _yearController.clear();
        _mediumController.clear();
        _noteController.clear();
      } else {
        final nextIndex = index >= _exhibits.length
            ? _exhibits.length - 1
            : index;
        final next = _exhibits[nextIndex];
        _selectedId = next.id;
        _writeControllers(next);
      }
      _status = '已删除“$removedTitle”';
    });
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleExhibits = normalizedQuery.isEmpty
        ? _exhibits
        : _exhibits
              .where((exhibit) {
                return exhibit.title.toLowerCase().contains(normalizedQuery) ||
                    exhibit.artist.toLowerCase().contains(normalizedQuery) ||
                    exhibit.medium.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);

    return Shortcuts(
      shortcuts: _editorShortcuts,
      child: Actions(
        actions: {
          _SaveExhibitIntent: CallbackAction<_SaveExhibitIntent>(
            onInvoke: (_) {
              _saveExhibit();
              return null;
            },
          ),
          _NewExhibitIntent: CallbackAction<_NewExhibitIntent>(
            onInvoke: (_) {
              _beginNewExhibit();
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          child: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(wide ? 28 : 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GalleryHeader(
                          onNew: _beginNewExhibit,
                          onSave: _saveExhibit,
                        ),
                        const SizedBox(height: 20),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _GalleryWall(
                                  exhibits: visibleExhibits,
                                  selectedId: _selectedId,
                                  onSelect: _selectExhibit,
                                  query: _query,
                                  onQueryChanged: (value) {
                                    setState(() => _query = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 420,
                                child: _EditorLedger(
                                  formKey: _formKey,
                                  titleFocus: _titleFocus,
                                  titleController: _titleController,
                                  artistController: _artistController,
                                  yearController: _yearController,
                                  mediumController: _mediumController,
                                  noteController: _noteController,
                                  showValidation: _showValidation,
                                  canDelete: _selectedId != null,
                                  onSave: _saveExhibit,
                                  onDelete: _deleteSelected,
                                  status: _status,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _GalleryWall(
                            exhibits: visibleExhibits,
                            selectedId: _selectedId,
                            onSelect: _selectExhibit,
                            query: _query,
                            onQueryChanged: (value) {
                              setState(() => _query = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _EditorLedger(
                            formKey: _formKey,
                            titleFocus: _titleFocus,
                            titleController: _titleController,
                            artistController: _artistController,
                            yearController: _yearController,
                            mediumController: _mediumController,
                            noteController: _noteController,
                            showValidation: _showValidation,
                            canDelete: _selectedId != null,
                            onSave: _saveExhibit,
                            onDelete: _deleteSelected,
                            status: _status,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({required this.onNew, required this.onSave});

  final VoidCallback onNew;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '小型展览编辑器',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '选择展签后修改资料，或从空白展签开始。',
                style: TextStyle(color: Color(0xFFC7D5FF), fontSize: 16),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: onNew,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _brass),
              ),
              child: const Text('新建 · Ctrl+N'),
            ),
            FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: _coral,
                foregroundColor: _ink,
              ),
              child: const Text('保存 · Ctrl+S'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GalleryWall extends StatelessWidget {
  const _GalleryWall({
    required this.exhibits,
    required this.selectedId,
    required this.onSelect,
    required this.query,
    required this.onQueryChanged,
  });

  final List<Exhibit> exhibits;
  final String? selectedId;
  final ValueChanged<Exhibit> onSelect;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 460),
      color: _wallBlue,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              const Text(
                '展墙 01',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                query.trim().isEmpty
                    ? '${exhibits.length} 件展品'
                    : '${exhibits.length} 件匹配',
                style: const TextStyle(color: Color(0xFFC7D5FF)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _brass, thickness: 3),
          const SizedBox(height: 18),
          TextField(
            key: const Key('filter-field'),
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              labelText: '筛选展品',
              hintText: '标题、艺术家或材料',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 22),
          if (exhibits.isEmpty)
            _EmptyWall(queryActive: query.trim().isNotEmpty)
          else
            Wrap(
              spacing: 16,
              runSpacing: 18,
              children: [
                for (var index = 0; index < exhibits.length; index += 1)
                  SizedBox(
                    width: index.isEven ? 226 : 246,
                    child: _ExhibitLabel(
                      index: index + 1,
                      exhibit: exhibits[index],
                      selected: exhibits[index].id == selectedId,
                      onTap: () => onSelect(exhibits[index]),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyWall extends StatelessWidget {
  const _EmptyWall({required this.queryActive});

  final bool queryActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border.all(color: _brass)),
      child: Text(
        queryActive ? '没有匹配的展品。修改筛选词后再试。' : '展墙暂时为空。使用“新建”添加第一件展品。',
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }
}

// #region exhibit-label-api
class _ExhibitLabel extends StatelessWidget {
  const _ExhibitLabel({
    required this.index,
    required this.exhibit,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final Exhibit exhibit;
  final bool selected;
  final VoidCallback onTap;
  // #endregion exhibit-label-api

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '展品 ${exhibit.title}，${exhibit.artist}，${exhibit.year} 年',
      child: Material(
        color: _labelPaper,
        shape: Border.all(
          color: selected ? _coral : _brass,
          width: selected ? 4 : 1,
        ),
        child: InkWell(
          onTap: onTap,
          focusColor: _coral.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: _wallBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      exhibit.year.toString(),
                      style: const TextStyle(color: _quietInk),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  exhibit.title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(exhibit.artist, style: const TextStyle(color: _quietInk)),
                const SizedBox(height: 22),
                Text(
                  exhibit.medium,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorLedger extends StatelessWidget {
  const _EditorLedger({
    required this.formKey,
    required this.titleFocus,
    required this.titleController,
    required this.artistController,
    required this.yearController,
    required this.mediumController,
    required this.noteController,
    required this.showValidation,
    required this.canDelete,
    required this.onSave,
    required this.onDelete,
    required this.status,
  });

  final GlobalKey<FormState> formKey;
  final FocusNode titleFocus;
  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController yearController;
  final TextEditingController mediumController;
  final TextEditingController noteController;
  final bool showValidation;
  final bool canDelete;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _labelPaper,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '展签资料',
              style: TextStyle(
                color: _ink,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            const Text('保存后，左侧展墙立即使用这组资料。', style: TextStyle(color: _quietInk)),
            const SizedBox(height: 24),
            // #region form-fields
            TextFormField(
              key: const Key('title-field'),
              focusNode: titleFocus,
              controller: titleController,
              decoration: const InputDecoration(labelText: '标题'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(value, fieldName: '标题'),
              autovalidateMode: showValidation
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('artist-field'),
              controller: artistController,
              decoration: const InputDecoration(labelText: '艺术家'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(value, fieldName: '艺术家'),
              autovalidateMode: showValidation
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            // #endregion form-fields
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('year-field'),
              controller: yearController,
              decoration: const InputDecoration(labelText: '年份'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: validateYear,
              autovalidateMode: showValidation
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('medium-field'),
              controller: mediumController,
              decoration: const InputDecoration(labelText: '材料'),
              textInputAction: TextInputAction.next,
              validator: (value) => validateRequired(value, fieldName: '材料'),
              autovalidateMode: showValidation
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('note-field'),
              controller: noteController,
              decoration: const InputDecoration(labelText: '说明'),
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: (value) => validateRequired(value, fieldName: '说明'),
              autovalidateMode: showValidation
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: onSave, child: const Text('保存展签')),
                OutlinedButton(
                  onPressed: canDelete ? onDelete : null,
                  child: const Text('删除展签'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // #region semantic-status
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('editor-status'),
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFFFD5CD),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // #endregion semantic-status
          ],
        ),
      ),
    );
  }
}
