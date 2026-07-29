import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/quiz/quiz_models.dart';
import '../../../domain/quiz/quiz_engine.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../providers/database_provider.dart';
import '../../providers/person_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int? personId;

  const QuizScreen({super.key, this.personId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  QuizLength? _selectedLength;
  List<QuizQuestion>? _questions;
  final Map<String, int> _answers = {};
  int _currentIndex = 0;
  bool _isComplete = false;

  Future<void> _startQuiz(QuizLength length) async {
    final locale = Localizations.localeOf(context).languageCode;
    // `loadQuizQuestions` throws on a missing or malformed asset (the repository
    // propagates failures); an empty list is the state `build` already knows how
    // to render as an error, so funnel both into it.
    List<QuizQuestion> questions;
    try {
      questions = await ref.read(contentRepositoryProvider).loadQuizQuestions(locale, length);
    } catch (_) {
      questions = const [];
    }
    if (!mounted) return;
    setState(() {
      _selectedLength = length;
      _questions = questions;
      _currentIndex = 0;
      _answers.clear();
      // Without this, a retake after "cancel" on the results page lands straight
      // back on the results with no answers (a fake ENFP at minimum confidence).
      _isComplete = false;
    });
  }

  void _submitAnswer(int value) {
    if (_questions == null) return;
    final q = _questions![_currentIndex];
    setState(() {
      _answers[q.id] = value;
      if (_currentIndex < _questions!.length - 1) {
        _currentIndex++;
      } else {
        _isComplete = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_selectedLength == null) {
      return _buildLengthSelection(context, l10n);
    }

    if (_questions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // An empty list means the questions could not be loaded (asset missing from
    // the bundle, malformed JSON, a file that never downloaded on the PWA — see
    // `_startQuiz`). Without this branch `_buildQuestion` indexes an empty list
    // and the user gets a red screen with no way back, since `_selectedLength`
    // is already set.
    if (_questions!.isEmpty) {
      return _buildLoadError(context, l10n);
    }

    if (_isComplete) {
      return _buildResults(context, l10n);
    }

    return _buildQuestion(context, l10n);
  }

  Widget _buildLengthSelection(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizChooseLengthAppBar)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.quizChooseLengthTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _LengthCard(
                title: l10n.quizShort,
                desc: l10n.quizShortDesc,
                icon: Icons.timer_outlined,
                onTap: () => _startQuiz(QuizLength.short),
              ),
              const SizedBox(height: 16),
              _LengthCard(
                title: l10n.quizMedium,
                desc: l10n.quizMediumDesc,
                icon: Icons.access_time,
                onTap: () => _startQuiz(QuizLength.medium),
              ),
              const SizedBox(height: 16),
              _LengthCard(
                title: l10n.quizLong,
                desc: l10n.quizLongDesc,
                icon: Icons.hourglass_full,
                // 20 items per axis against the short test's 4: a single odd
                // answer moves the result far less, so the type it reports is
                // the most reliable one the quiz can give. Note this is *not*
                // a higher `confidence` — that metric is normalized per axis,
                // so a consistent responder tops it out on any length.
                badge: l10n.quizMostAccurate,
                onTap: () => _startQuiz(QuizLength.long),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizChooseLengthAppBar)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.quizLoadError,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // Back to the length choice: the other two files may well load.
                onPressed: () => setState(() {
                  _selectedLength = null;
                  _questions = null;
                }),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.actionBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, AppLocalizations l10n) {
    final q = _questions![_currentIndex];
    final progress = (_currentIndex + 1) / _questions!.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizQuestion(_currentIndex + 1, _questions!.length)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              q.text,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.quizDisagree, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                Text(l10n.quizAgree, style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final value = index + 1;
                return InkWell(
                  onTap: () => _submitAnswer(value),
                  child: Container(
                    width: 48 + (value == 3 ? 0 : (value - 3).abs() * 8).toDouble(),
                    height: 48 + (value == 3 ? 0 : (value - 3).abs() * 8).toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: value > 3 ? Colors.green : (value < 3 ? Theme.of(context).colorScheme.error : Colors.grey),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ),
            const Spacer(),
            if (_currentIndex > 0)
              TextButton.icon(
                onPressed: () => setState(() => _currentIndex--),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.actionPrevious),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, AppLocalizations l10n) {
    final result =
        QuizEngine.evaluate(_questions!, _answers, _selectedLength!);
    final breakdown = result.breakdown;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizResults)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.quizResultType(result.type.label),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _AxisResult(label: l10n.mbtiDichotomyIE, value: breakdown['IE'] ?? 0.5, left: 'I', right: 'E'),
            const SizedBox(height: 16),
            _AxisResult(label: l10n.mbtiDichotomyNS, value: breakdown['NS'] ?? 0.5, left: 'S', right: 'N'),
            const SizedBox(height: 16),
            _AxisResult(label: l10n.mbtiDichotomyTF, value: breakdown['TF'] ?? 0.5, left: 'T', right: 'F'),
            const SizedBox(height: 16),
            _AxisResult(label: l10n.mbtiDichotomyJP, value: breakdown['JP'] ?? 0.5, left: 'J', right: 'P'),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => _saveAndExit(result),
              icon: const Icon(Icons.check),
              label: Text(l10n.actionSave),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _selectedLength = null),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndExit(QuizResult result) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final personRepo = ref.read(personRepositoryProvider);

    int? targetPersonId = widget.personId;
    if (targetPersonId == null) {
      final self = await personRepo.getSelf();
      targetPersonId = self?.id;
    }

    if (targetPersonId != null) {
      final mbtiProfile = MbtiProfile.fromType(result.type);
      final existing = await profileRepo.getForPerson(targetPersonId);
      final mbti = existing.where((p) => p.system == PersonalitySystem.mbti).firstOrNull;

      await profileRepo.upsert(PersonalityProfile(
        id: mbti?.id ?? 0,
        personId: targetPersonId,
        system: PersonalitySystem.mbti,
        data: mbtiProfile.toJson(),
        confidence: result.confidence,
        source: result.source,
        updatedAt: DateTime.now(),
      ));

      ref.invalidate(allPersonsProvider);
      ref.invalidate(personByIdProvider(targetPersonId));
    }

    if (mounted) {
      // During onboarding no self person exists yet, so nothing was saved here:
      // the caller persists the profile from this result.
      Navigator.of(context).pop(result);
    }
  }
}

class _LengthCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  /// Optional label rendered next to the title (e.g. "Most accurate").
  final String? badge;

  const _LengthCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 32, color: cs.primary),
        title: Row(
          children: [
            Flexible(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(desc),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _AxisResult extends StatelessWidget {
  final String label;
  final double value; // 0..1
  final String left;
  final String right;

  const _AxisResult({required this.label, required this.value, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(left, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
