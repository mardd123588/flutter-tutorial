import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_repository.dart';
import '../domain/exchange_models.dart';
import '../state/exchange_providers.dart';
import 'exchange_components.dart';
import 'exchange_theme.dart';

class ExchangePublishPage extends ConsumerStatefulWidget {
  const ExchangePublishPage({super.key});

  @override
  ConsumerState<ExchangePublishPage> createState() =>
      _ExchangePublishPageState();
}

class _ExchangePublishPageState extends ConsumerState<ExchangePublishPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _errorFocusNode = FocusNode();
  var _category = ExchangeCategory.tools;
  var _neighborhood = Neighborhood.qinghe;
  var _handoffMethod = HandoffMethod.locker;
  var _availableWindow = AvailableWindow.values.first;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _errorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishListingProvider);
    return Scaffold(
      body: Column(
        children: [
          ExchangeHeader(showBack: true, onBack: () => context.go('/exchange')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Material(
                      color: exchangePaper,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '贴一张新的资源公告',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 10),
                            const Text('发布后会进入详情页。记录只保存在当前浏览器，不会同步给其他人。'),
                            if (state.failure != null) ...[
                              const SizedBox(height: 22),
                              Focus(
                                key: const ValueKey(
                                  'publish-error-summary-focus',
                                ),
                                focusNode: _errorFocusNode,
                                child: Semantics(
                                  liveRegion: true,
                                  label: _errorSummary(state),
                                  child: Material(
                                    key: const ValueKey(
                                      'publish-error-summary',
                                    ),
                                    color: const Color(0xFFFFE8E3),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Text(
                                        _errorSummary(state),
                                        style: const TextStyle(
                                          color: exchangeError,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumns = constraints.maxWidth >= 720;
                                if (!twoColumns) return _formFields(state);
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _primaryFields(state)),
                                    const SizedBox(width: 18),
                                    Expanded(child: _handoffFields(state)),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Material(
                              color: exchangeGreenSoft,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.storage_outlined,
                                      color: exchangeGreen,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '发布、认领和恢复演示数据都只修改当前浏览器的 Drift 数据库。不要填写真实住址或个人联系方式。',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () => context.go('/exchange'),
                                  child: const Text('取消'),
                                ),
                                FilledButton.icon(
                                  key: const ValueKey('submit-listing'),
                                  onPressed: state.isSubmitting
                                      ? null
                                      : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: exchangeRust,
                                  ),
                                  icon: state.isSubmitting
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.push_pin_outlined),
                                  label: Text(
                                    state.isSubmitting ? '正在发布' : '发布到当前浏览器',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formFields(PublishListingState state) {
    return Column(
      children: [
        _primaryFields(state),
        const SizedBox(height: 16),
        _handoffFields(state),
      ],
    );
  }

  Widget _primaryFields(PublishListingState state) {
    return Column(
      children: [
        TextField(
          key: const ValueKey('title-field'),
          controller: _titleController,
          maxLength: 40,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '资源名称',
            hintText: '例如：折叠野餐桌',
            errorText: state.fieldErrors['title'],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('description-field'),
          controller: _descriptionController,
          maxLength: 240,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: '说明',
            hintText: '写清适用范围、配件和交接前需要注意的事。',
            errorText: state.fieldErrors['description'],
          ),
        ),
      ],
    );
  }

  Widget _handoffFields(PublishListingState state) {
    return Column(
      children: [
        DropdownButtonFormField<ExchangeCategory>(
          key: const ValueKey('publish-category'),
          initialValue: _category,
          decoration: const InputDecoration(labelText: '类别'),
          items: ExchangeCategory.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _category = value);
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<Neighborhood>(
          key: const ValueKey('publish-neighborhood'),
          initialValue: _neighborhood,
          decoration: const InputDecoration(labelText: '片区'),
          items: Neighborhood.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _neighborhood = value);
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<HandoffMethod>(
          key: const ValueKey('publish-handoff'),
          initialValue: _handoffMethod,
          decoration: const InputDecoration(labelText: '交接方式'),
          items: HandoffMethod.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _handoffMethod = value);
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<AvailableWindow>(
          key: const ValueKey('publish-window'),
          initialValue: _availableWindow,
          decoration: const InputDecoration(labelText: '可取时段'),
          items: AvailableWindow.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _availableWindow = value);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('quantity-field'),
          controller: _quantityController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: '可认领数量',
            helperText: '1 到 9 份；每次认领一份。',
            errorText: state.fieldErrors['quantity'],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final draft = PublishDraft(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      neighborhood: _neighborhood,
      handoffMethod: _handoffMethod,
      availableWindow: _availableWindow,
      quantityText: _quantityController.text,
    );
    final result = await ref
        .read(publishListingProvider.notifier)
        .submit(draft);
    if (!mounted || result == null) return;
    switch (result) {
      case ExchangeSuccess<ExchangeListing>(:final value):
        context.go('/listings/${value.id}');
      case ExchangeFailureResult<ExchangeListing>():
        _errorFocusNode.requestFocus();
    }
  }
}

String _errorSummary(PublishListingState state) {
  if (state.fieldErrors.isNotEmpty) {
    return '请修正 ${state.fieldErrors.length} 个字段：${state.fieldErrors.values.join('；')}';
  }
  return switch (state.failure) {
    ExchangeStorageFailure() => '发布没有写入本地数据库，请保留内容并重试。',
    ExchangeFixtureFailure() => '演示数据尚未准备好，请返回列表重试。',
    _ => '发布没有完成，请重试。',
  };
}
