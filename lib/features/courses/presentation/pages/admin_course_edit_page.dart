import 'dart:typed_data';
import 'dart:html' as html;
import '../../../../core/widgets/markdown_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/quiz_draft.dart';
import '../controllers/course_edit_controller.dart';
import '../../../../core/widgets/markdown_view.dart';

class AdminCourseEditPage extends StatelessWidget {
  final int? courseId; // null => создание
  const AdminCourseEditPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final c = sl<CourseEditController>();
        if (courseId != null) c.load(courseId!);
        return c;
      },
      child: _EditView(isNew: courseId == null),
    );
  }
}

class _EditView extends StatefulWidget {
  final bool isNew;

  const _EditView({required this.isNew});

  @override
  State<_EditView> createState() => _EditViewState();
}

class _EditViewState extends State<_EditView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ctrl = context.watch<CourseEditController>();
    return AppShell(
      title: ctrl.courseId == null ? 'Новый курс' : 'Редактирование курса',
      current: '/admin',
      actions: [
        IconButton(
          tooltip: 'К дашборду',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ],
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : Column(
              children: [
                Material(
                  color: t.surface,
                  child: TabBar(
                    controller: _tabs,
                    labelColor: t.accentInk,
                    unselectedLabelColor: t.muted,
                    indicatorColor: t.accent,
                    tabs: const [
                      Tab(text: 'Основное'),
                      Tab(text: 'Уроки'),
                      Tab(text: 'Тест'),
                    ],
                  ),
                ),
                Divider(height: 1, color: t.border),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _MetaTab(onSaved: () => _tabs.animateTo(1)),
                      ctrl.courseId == null
                          ? _lockNotice(context)
                          : const _LessonsTab(),
                      ctrl.courseId == null
                          ? _lockNotice(context)
                          : const _QuizTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _lockNotice(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Сначала сохраните основные данные курса на вкладке «Основное».',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.tokens.muted),
      ),
    ),
  );
}

// ---------- Вкладка «Основное» ----------
class _MetaTab extends StatefulWidget {
  final VoidCallback onSaved;

  const _MetaTab({required this.onSaved});

  @override
  State<_MetaTab> createState() => _MetaTabState();
}

class _MetaTabState extends State<_MetaTab> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _category = TextEditingController(text: 'Общее');
  final _passScore = TextEditingController(text: '80');
  bool _published = false;
  bool _certificate = true;
  bool _busy = false;
  bool _preview = false;
  String? _error;
  bool _initialized = false;

  void _syncFrom(CourseDetail c) {
    _title.text = c.title;
    _desc.text = c.description;
    _category.text = c.category;
    _passScore.text = '${c.passScore}';
    _published = c.isPublished;
    _certificate = c.certificateEnabled;
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Укажите название курса');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<CourseEditController>().saveMeta(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        category: _category.text.trim().isEmpty
            ? 'Общее'
            : _category.text.trim(),
        passScore: int.tryParse(_passScore.text) ?? 80,
        certificateEnabled: _certificate,
        isPublished: _published,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Сохранено')));
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final course = context.watch<CourseEditController>().course;
    if (!_initialized && course != null) {
      _syncFrom(course);
      _initialized = true;
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Название курса'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _category,
                      decoration: const InputDecoration(
                        labelText: 'Направление (напр. Промбезопасность)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _passScore,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Проходной балл, %',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _published,
                title: const Text('Опубликован'),
                subtitle: const Text('Виден студентам в каталоге'),
                onChanged: (v) => setState(() => _published = v),
              ),
              SwitchListTile(
                value: _certificate,
                title: const Text('Выдавать сертификат'),
                subtitle: const Text('PDF-сертификат при сдаче теста'),
                onChanged: (v) => setState(() => _certificate = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: t.danger)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Вкладка «Уроки» ----------
class _LessonsTab extends StatelessWidget {
  const _LessonsTab();

  Future<void> _edit(BuildContext context, {Lesson? lesson}) async {
    final ctrl = context.read<CourseEditController>();
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: ctrl,
        child: _LessonFormDialog(lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ctrl = context.watch<CourseEditController>();
    final lessons = ctrl.course?.lessons ?? const <Lesson>[];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Уроков: ${lessons.length}',
                style: TextStyle(fontWeight: FontWeight.bold, color: t.text),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.add),
                label: const Text('Добавить урок'),
              ),
            ],
          ),
        ),
        Expanded(
          child: lessons.isEmpty
              ? const Center(child: Text('Уроков пока нет'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (var i = 0; i < lessons.length; i++)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.accentSoft,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(color: t.accent),
                            ),
                          ),
                          title: Text(lessons[i].title),
                          subtitle: Text(
                            lessons[i].content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () =>
                                    _edit(context, lesson: lessons[i]),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: t.danger,
                                ),
                                onPressed: () =>
                                    ctrl.deleteLesson(lessons[i].id),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LessonFormDialog extends StatefulWidget {
  final Lesson? lesson;

  const _LessonFormDialog({this.lesson});

  @override
  State<_LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<_LessonFormDialog> {
  late final _title = TextEditingController(text: widget.lesson?.title ?? '');
  late final _content = TextEditingController(
    text: widget.lesson?.content ?? '',
  );
  late final _video = TextEditingController(
    text: widget.lesson?.videoUrl ?? '',
  );
  late List<LessonMaterial> _materials = List.of(
    widget.lesson?.materials ?? const <LessonMaterial>[],
  );
  bool _busy = false;
  bool _preview = false;

  int? get _lessonId => widget.lesson?.id;


  void _wrap(String token) {
    final text = _content.text;
    final sel = _content.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = text.substring(start, end);
    final replaced = '$token$selected$token';
    _content.value = TextEditingValue(
      text: text.replaceRange(start, end, replaced),
      selection: TextSelection.collapsed(offset: start + replaced.length),
    );
    setState(() {});
  }

  void _prefixLine(String prefix) {
    final text = _content.text;
    final sel = _content.selection;
    final pos = sel.isValid ? sel.start : text.length;
    var lineStart = pos > 0 ? text.lastIndexOf('\n', pos - 1) : -1;
    lineStart = lineStart < 0 ? 0 : lineStart + 1;
    _content.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: pos + prefix.length),
    );
    setState(() {});
  }

  void _insert(String snippet) {
    final text = _content.text;
    final sel = _content.selection;
    final pos = sel.isValid ? sel.start : text.length;
    _content.value = TextEditingValue(
      text: text.replaceRange(pos, pos, snippet),
      selection: TextSelection.collapsed(offset: pos + snippet.length),
    );
    setState(() {});
  }
  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _video.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final ctrl = context.read<CourseEditController>();
    final video = _video.text.trim().isEmpty ? null : _video.text.trim();
    try {
      if (widget.lesson == null) {
        await ctrl.addLesson(
          title: _title.text.trim(),
          content: _content.text.trim(),
          videoUrl: video,
        );
      } else {
        // Материалы не отправляем — ими управляют отдельные кнопки.
        await ctrl.updateLesson(
          widget.lesson!.id,
          title: _title.text.trim(),
          content: _content.text.trim(),
          videoUrl: video,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAndUpload() async {
    // Важно: input должен быть в DOM, иначе в вебе событие change не срабатывает.
    final input = html.FileUploadInputElement()
      ..accept = '.pdf,application/pdf'
      ..style.display = 'none';
    html.document.body?.append(input);
    input.click();
    await input.onChange.first;
    final files = input.files;
    input.remove();
    if (files == null || files.isEmpty) return;
    final f = files.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(f);
    await reader.onLoadEnd.first;
    final result = reader.result;
    final Uint8List bytes = result is ByteBuffer
        ? result.asUint8List()
        : result as Uint8List;

    setState(() => _busy = true);
    try {
      final lesson = await context.read<CourseEditController>().uploadMaterial(
        _lessonId!,
        bytes: bytes,
        filename: f.name,
        title: f.name,
      );
      setState(() => _materials = List.of(lesson.materials));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addLinkDialog() async {
    final titleC = TextEditingController();
    final urlC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ссылка на материал'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlC,
                decoration: const InputDecoration(
                  labelText: 'Ссылка (URL)',
                  prefixIcon: Icon(Icons.link, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (ok != true || urlC.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final lesson = await context.read<CourseEditController>().addMaterialLink(
        _lessonId!,
        title: titleC.text.trim(),
        url: urlC.text.trim(),
      );
      setState(() => _materials = List.of(lesson.materials));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteMaterial(LessonMaterial m) async {
    if (m.id == null) return;
    setState(() => _busy = true);
    try {
      final lesson = await context.read<CourseEditController>().deleteMaterial(
        _lessonId!,
        m.id!,
      );
      setState(() => _materials = List.of(lesson.materials));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isNew = widget.lesson == null;
    return AlertDialog(
      title: Text(isNew ? 'Новый урок' : 'Редактировать урок'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Заголовок'),
              ),
              const SizedBox(height: 12),
              _contentEditor(context),
              const SizedBox(height: 12),
              TextField(
                controller: _video,
                decoration: const InputDecoration(
                  labelText: 'Ссылка на видео (необязательно)',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 18, color: t.muted),
                  const SizedBox(width: 6),
                  Text(
                    'Материалы',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: t.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isNew)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Сначала сохраните урок — после этого можно будет '
                    'загрузить PDF или добавить ссылки.',
                    style: TextStyle(color: t.muted, fontSize: 13),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _pickAndUpload,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Загрузить PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _addLinkDialog,
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Добавить ссылку'),
                      ),
                    ),
                  ],
                ),
                if (_busy) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                const SizedBox(height: 10),
                if (_materials.isEmpty)
                  Text('Материалов пока нет', style: TextStyle(color: t.faint))
                else
                  for (final m in _materials) _materialTile(context, m),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Widget _contentEditor(BuildContext context) {
    final t = context.tokens;
    Widget btn(IconData icon, String tip, VoidCallback onTap) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18),
      onPressed: _preview ? null : onTap,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Содержание урока (Markdown)',
                style: TextStyle(color: t.muted, fontSize: 13)),
            const Spacer(),
            SizedBox(
              height: 32,
              child: SegmentedButton<bool>(
                style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                segments: const [
                  ButtonSegment(value: false, label: Text('Редактор')),
                  ButtonSegment(value: true, label: Text('Предпросмотр')),
                ],
                selected: {_preview},
                onSelectionChanged: (s) => setState(() => _preview = s.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              if (!_preview)
                Row(
                  children: [
                    btn(Icons.title, 'Заголовок', () => _prefixLine('## ')),
                    btn(Icons.format_bold, 'Жирный', () => _wrap('**')),
                    btn(Icons.format_italic, 'Курсив', () => _wrap('_')),
                    btn(Icons.format_list_bulleted, 'Список',
                            () => _prefixLine('- ')),
                    btn(Icons.link, 'Ссылка',
                            () => _insert('[текст](https://)')),
                    btn(Icons.image_outlined, 'Картинка',
                            () => _insert('![подпись](https://ссылка.png)')),
                  ],
                ),
              if (!_preview) Divider(height: 1, color: t.border),
              Padding(
                padding: const EdgeInsets.all(12),
                child: _preview
                    ? ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 120),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _content.text.trim().isEmpty
                        ? Text('Пусто', style: TextStyle(color: t.faint))
                        : MarkdownView(_content.text, selectable: false),
                  ),
                )
                    : TextField(
                  controller: _content,
                  maxLines: 10,
                  minLines: 6,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText:
                    '## Заголовок, **жирный**, - списки, ![](url)',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _materialTile(BuildContext context, LessonMaterial m) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            m.file ? Icons.picture_as_pdf_outlined : Icons.link,
            size: 20,
            color: m.file ? t.accent : t.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title.isEmpty ? m.url : m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
                ),
                Text(
                  m.file ? 'PDF · загружен' : 'внешняя ссылка',
                  style: TextStyle(color: t.faint, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: Icon(Icons.delete_outline, size: 20, color: t.danger),
            onPressed: _busy ? null : () => _deleteMaterial(m),
          ),
        ],
      ),
    );
  }
}

// ---------- Вкладка «Тест» ----------
class _QuizTab extends StatefulWidget {
  const _QuizTab();

  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> {
  final List<QuestionDraft> _questions = [];
  final List<int> _correct = [];
  bool _loading = true;
  bool _busy = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quiz = await context.read<CourseEditController>().loadQuiz();
    setState(() {
      _questions.clear();
      _correct.clear();
      if (quiz != null) {
        for (final q in quiz.questions) {
          _questions.add(
            QuestionDraft(
              text: q.text,
              answers: q.answers.map((a) => AnswerDraft(text: a.text)).toList(),
            ),
          );
          _correct.add(0);
        }
        _info =
            'Внимание: правильные ответы сервер не отдаёт — '
            'отметьте их заново перед сохранением.';
      }
      _loading = false;
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionDraft(
          answers: [AnswerDraft(), AnswerDraft(), AnswerDraft(), AnswerDraft()],
        ),
      );
      _correct.add(0);
    });
  }

  Future<void> _aiGenerate() async {
    final numController = TextEditingController(text: '5');
    final num = await showDialog<int>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('AI-генерация теста'),
        content: TextField(
          controller: numController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Количество вопросов'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(c, int.tryParse(numController.text) ?? 5),
            child: const Text('Сгенерировать'),
          ),
        ],
      ),
    );
    if (num == null) return;
    setState(() {
      _busy = true;
      _info = 'Генерация вопросов…';
    });
    try {
      final generated = await context
          .read<CourseEditController>()
          .generateQuizAI(num);
      setState(() {
        for (final q in generated) {
          final correctIdx = q.answers.indexWhere((a) => a.isCorrect);
          _questions.add(q);
          _correct.add(correctIdx < 0 ? 0 : correctIdx);
        }
        _info =
            'Сгенерировано ${generated.length} вопросов. Проверьте и сохраните.';
      });
    } catch (e) {
      setState(() => _info = 'Ошибка AI: ${e.toString()}');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _info = null;
    });
    for (var i = 0; i < _questions.length; i++) {
      for (var a = 0; a < _questions[i].answers.length; a++) {
        _questions[i].answers[a].isCorrect = a == _correct[i];
      }
    }
    try {
      await context.read<CourseEditController>().saveQuiz(_questions);
      setState(() => _info = 'Тест сохранён ✓');
    } catch (e) {
      setState(() => _info = 'Ошибка: ${e.toString()}');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _aiGenerate,
                icon: Icon(Icons.auto_awesome, color: t.accent),
                label: const Text('Сгенерировать AI'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Вопрос'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _busy || _questions.isEmpty ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить тест'),
              ),
            ],
          ),
        ),
        if (_info != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _info!,
              style: TextStyle(color: t.accent, fontSize: 13),
            ),
          ),
        if (_busy) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _questions.isEmpty
              ? const Center(
                  child: Text(
                    'Добавьте вопросы вручную или сгенерируйте через AI',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (c, i) => _questionEditor(i),
                ),
        ),
      ],
    );
  }

  Widget _questionEditor(int index) {
    final t = context.tokens;
    final q = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: t.accentSoft,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: t.accent, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: q.text)
                      ..selection = TextSelection.collapsed(
                        offset: q.text.length,
                      ),
                    onChanged: (v) => q.text = v,
                    decoration: const InputDecoration(
                      hintText: 'Текст вопроса',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: t.danger, size: 20),
                  onPressed: () => setState(() {
                    _questions.removeAt(index);
                    _correct.removeAt(index);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Отметьте правильный вариант:',
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
            for (var a = 0; a < q.answers.length; a++)
              Row(
                children: [
                  Radio<int>(
                    value: a,
                    groupValue: _correct[index],
                    activeColor: t.accent,
                    onChanged: (v) => setState(() => _correct[index] = v!),
                  ),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: q.answers[a].text)
                        ..selection = TextSelection.collapsed(
                          offset: q.answers[a].text.length,
                        ),
                      onChanged: (v) => q.answers[a].text = v,
                      decoration: InputDecoration(
                        hintText: 'Вариант ${a + 1}',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
