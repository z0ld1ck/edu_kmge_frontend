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

class _EditViewState extends State<_EditView> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.brand,
              indicatorColor: AppColors.brand,
              tabs: const [
                Tab(text: 'Основное'),
                Tab(text: 'Уроки'),
                Tab(text: 'Тест'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _MetaTab(onSaved: () => _tabs.animateTo(1)),
                ctrl.courseId == null
                    ? _lockNotice()
                    : const _LessonsTab(),
                ctrl.courseId == null
                    ? _lockNotice()
                    : const _QuizTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockNotice() => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
          'Сначала сохраните основные данные курса на вкладке «Основное».',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Сохранено')));
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
                  decoration:
                  const InputDecoration(labelText: 'Название курса')),
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
                            labelText: 'Направление (напр. Промбезопасность)')),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _passScore,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Проходной балл, %'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _published,
                activeThumbColor: AppColors.brand,
                title: const Text('Опубликован'),
                subtitle: const Text('Виден студентам в каталоге'),
                onChanged: (v) => setState(() => _published = v),
              ),
              SwitchListTile(
                value: _certificate,
                activeThumbColor: AppColors.brand,
                title: const Text('Выдавать сертификат'),
                subtitle: const Text('PDF-сертификат при сдаче теста'),
                onChanged: (v) => setState(() => _certificate = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
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
    final ctrl = context.watch<CourseEditController>();
    final lessons = ctrl.course?.lessons ?? const <Lesson>[];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Уроков: ${lessons.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      backgroundColor: AppColors.brand.withOpacity(0.1),
                      child: Text('${i + 1}',
                          style: const TextStyle(color: AppColors.brand)),
                    ),
                    title: Text(lessons[i].title),
                    subtitle: Text(lessons[i].content,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _edit(context, lesson: lessons[i]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.redAccent),
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
  late final _content =
  TextEditingController(text: widget.lesson?.content ?? '');
  late final _video =
  TextEditingController(text: widget.lesson?.videoUrl ?? '');
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    final ctrl = context.read<CourseEditController>();
    final video = _video.text.trim().isEmpty ? null : _video.text.trim();
    try {
      if (widget.lesson == null) {
        await ctrl.addLesson(
            title: _title.text.trim(),
            content: _content.text.trim(),
            videoUrl: video);
      } else {
        await ctrl.updateLesson(widget.lesson!.id,
            title: _title.text.trim(),
            content: _content.text.trim(),
            videoUrl: video);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lesson == null ? 'Новый урок' : 'Редактировать урок'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Заголовок')),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                maxLines: 8,
                decoration: const InputDecoration(
                    labelText: 'Содержание урока', alignLabelWithHint: true),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _video,
                  decoration: const InputDecoration(
                      labelText: 'Ссылка на видео (необязательно)')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
            onPressed: _busy ? null : _save, child: const Text('Сохранить')),
      ],
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
  final List<int> _correct = []; // индекс правильного ответа по каждому вопросу
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
          _questions.add(QuestionDraft(
            text: q.text,
            answers: q.answers.map((a) => AnswerDraft(text: a.text)).toList(),
          ));
          _correct.add(0);
        }
        _info = 'Внимание: правильные ответы сервер не отдаёт — '
            'отметьте их заново перед сохранением.';
      }
      _loading = false;
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionDraft(
          answers: [AnswerDraft(), AnswerDraft(), AnswerDraft(), AnswerDraft()]));
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
              onPressed: () => Navigator.pop(c), child: const Text('Отмена')),
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
      final generated =
      await context.read<CourseEditController>().generateQuizAI(num);
      setState(() {
        for (final q in generated) {
          final correctIdx = q.answers.indexWhere((a) => a.isCorrect);
          _questions.add(q);
          _correct.add(correctIdx < 0 ? 0 : correctIdx);
        }
        _info = 'Сгенерировано ${generated.length} вопросов. Проверьте и сохраните.';
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
    // Применяем выбранные правильные ответы к черновикам.
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _aiGenerate,
                icon: const Icon(Icons.auto_awesome, color: AppColors.brand),
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
            child: Text(_info!,
                style: const TextStyle(color: AppColors.brand, fontSize: 13)),
          ),
        if (_busy) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _questions.isEmpty
              ? const Center(
              child: Text(
                  'Добавьте вопросы вручную или сгенерируйте через AI'))
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
                  backgroundColor: AppColors.brand.withOpacity(0.1),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: AppColors.brand, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: q.text)
                      ..selection = TextSelection.collapsed(offset: q.text.length),
                    onChanged: (v) => q.text = v,
                    decoration: const InputDecoration(
                        hintText: 'Текст вопроса', isDense: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => setState(() {
                    _questions.removeAt(index);
                    _correct.removeAt(index);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Отметьте правильный вариант:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            for (var a = 0; a < q.answers.length; a++)
              Row(
                children: [
                  Radio<int>(
                    value: a,
                    groupValue: _correct[index],
                    activeColor: AppColors.brand,
                    onChanged: (v) => setState(() => _correct[index] = v!),
                  ),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: q.answers[a].text)
                        ..selection = TextSelection.collapsed(
                            offset: q.answers[a].text.length),
                      onChanged: (v) => q.answers[a].text = v,
                      decoration: InputDecoration(
                          hintText: 'Вариант ${a + 1}', isDense: true),
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
