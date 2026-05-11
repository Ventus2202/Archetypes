import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/quiz/quiz_models.dart';
import '../../../domain/quiz/quiz_engine.dart';
import '../../../domain/personality_systems/mbti/mbti_types.dart';
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
    final questions = await ref.read(contentRepositoryProvider).loadQuizQuestions(locale, length);
    setState(() {
      _selectedLength = length;
      _questions = questions;
      _currentIndex = 0;
      _answers.clear();
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

    if (_isComplete) {
      return _buildResults(context, l10n);
    }

    return _buildQuestion(context, l10n);
  }

  Widget _buildLengthSelection(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mbtiSourceQuizShort)), // Or a generic title
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.onboardingChooseMethod,
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
                onTap: () => _startQuiz(QuizLength.long),
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
    final resultType = QuizEngine.calculateResult(_questions!, _answers);
    final breakdown = QuizEngine.calculateBreakdown(_questions!, _answers);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizResults)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.quizResultType(resultType.label),
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
              onPressed: () => _saveAndExit(resultType),
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

  Future<void> _saveAndExit(MbtiType type) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final personRepo = ref.read(personRepositoryProvider);

    int? targetPersonId = widget.personId;
    if (targetPersonId == null) {
      final self = await personRepo.getSelf();
      targetPersonId = self?.id;
    }

    if (targetPersonId != null) {
      final mbtiProfile = MbtiProfile.fromType(type);
      final existing = await profileRepo.getForPerson(targetPersonId);
      final mbti = existing.where((p) => p.system == PersonalitySystem.mbti).firstOrNull;

      await profileRepo.upsert(PersonalityProfile(
        id: mbti?.id ?? 0,
        personId: targetPersonId,
        system: PersonalitySystem.mbti,
        data: mbtiProfile.toJson(),
        confidence: 90,
        source: ProfileSource.quizMedium, // Could be more specific
        updatedAt: DateTime.now(),
      ));
      
      ref.invalidate(allPersonsProvider);
      ref.invalidate(personByIdProvider(targetPersonId));
    }

    if (mounted) {
      Navigator.of(context).pop(type);
    }
  }
}

class _LengthCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  const _LengthCard({required this.title, required this.desc, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
