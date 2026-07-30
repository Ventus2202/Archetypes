import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/team/team_models.dart';
import '../../providers/team_provider.dart';
import '../../providers/person_provider.dart';
import '../../theme/app_theme.dart';

class TeamBuilderScreen extends ConsumerWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(teamOptimizerProvider);
    final notifier = ref.read(teamOptimizerProvider.notifier);
    final personsAsync = ref.watch(allPersonsProvider);
    final contentAsync = ref.watch(teamObjectivesContentProvider(
      Localizations.localeOf(context).languageCode,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTeamBuilder),
      ),
      body: Column(
        children: [
          _ConfigurationPanel(
            state: state,
            notifier: notifier,
            content: contentAsync,
          ),
          const Divider(height: 1),
          Expanded(
            child: state.results != null
                ? _ResultsList(
                    results: state.results!,
                    objective: state.objective,
                    content: contentAsync.valueOrNull,
                  )
                : personsAsync.when(
                    data: (persons) => _CandidateList(persons: persons, state: state, notifier: notifier),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text(l10n.errorGeneric)),
                  ),
          ),
        ],
      ),
      floatingActionButton: state.results == null && state.selectedPersonIds.length >= state.teamSize
          ? FloatingActionButton.extended(
              onPressed: state.isLoading ? null : () => notifier.calculate(),
              icon: state.isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.psychology),
              label: Text(l10n.actionCalculate),
            )
          : null,
    );
  }
}

class _ConfigurationPanel extends StatelessWidget {
  final TeamOptimizerState state;
  final TeamOptimizerNotifier notifier;
  final AsyncValue<TeamObjectivesContent> content;

  const _ConfigurationPanel({
    required this.state,
    required this.notifier,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: cs.surfaceContainerHighest.withAlpha(100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.teamDisclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.teamObjectiveLabel,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TeamObjective>(
                      value: state.objective,
                      isExpanded: true,
                      items: TeamObjective.values.map((obj) {
                        return DropdownMenuItem(
                          value: obj,
                          child: Text(_objectiveTitle(l10n, obj)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) notifier.setObjective(val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.teamSizeLabel, style: Theme.of(context).textTheme.bodySmall),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: state.teamSize > 2 ? () => notifier.setTeamSize(state.teamSize - 1) : null,
                      ),
                      Text('${state.teamSize}', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: state.teamSize < 6 ? () => notifier.setTeamSize(state.teamSize + 1) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          _ObjectiveDescription(objective: state.objective, content: content),
          if (state.results != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: Text(l10n.teamEditSelection),
                onPressed: () => notifier.setObjective(state.objective), // Just to clear results
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// What the selected objective is about, from `team_objectives.json`. The
/// objective *names* come from the ARB instead, so a missing asset degrades this
/// block alone and never leaves the dropdown unlabelled.
class _ObjectiveDescription extends StatelessWidget {
  final TeamObjective objective;
  final AsyncValue<TeamObjectivesContent> content;

  const _ObjectiveDescription({required this.objective, required this.content});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall;

    return content.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          AppLocalizations.of(context).errorNotFound,
          style: style?.copyWith(color: cs.error),
        ),
      ),
      data: (textContent) {
        final description = _objectiveField(textContent, objective, 'description');
        if (description == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            description,
            style: style?.copyWith(color: cs.onSurfaceVariant),
          ),
        );
      },
    );
  }
}

class _CandidateList extends StatelessWidget {
  /// Typed, not `List<dynamic>`: with a dynamic receiver `displayName.characters`
  /// below is a dynamic invocation of an extension method, which the analyzer
  /// cannot see and which throws `NoSuchMethodError` at runtime — the candidate
  /// list crashed for every non-empty list of people.
  final List<Person> persons;
  final TeamOptimizerState state;
  final TeamOptimizerNotifier notifier;

  const _CandidateList({required this.persons, required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.teamSelectCandidates(state.selectedPersonIds.length, state.teamSize),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: persons.length,
            itemBuilder: (ctx, i) {
              final p = persons[i];
              final isSelected = state.selectedPersonIds.contains(p.id);
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) => notifier.togglePerson(p.id),
                title: Text(p.displayName),
                subtitle: p.nickname != null && p.nickname != p.name ? Text(p.name) : null,
                secondary: CircleAvatar(
                  child: Text(p.displayName.characters.first.toUpperCase()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<TeamComposition> results;
  final TeamObjective objective;

  /// Null while the asset is loading or if it failed: the labels then fall back
  /// to the raw engine keys, the way the career and relationship screens do.
  /// The configuration panel above is what reports the failure.
  final TeamObjectivesContent? content;

  const _ResultsList({
    required this.results,
    required this.objective,
    required this.content,
  });

  String _label(Map<String, dynamic>? section, String key) =>
      section?[key] as String? ?? key;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Center(child: Text(l10n.teamNoResults));
    }

    final textContent = content;
    final idealProfile = textContent == null
        ? null
        : _objectiveField(textContent, objective, 'ideal_profile');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      // The ideal profile of the objective heads the list: it is the yardstick
      // the proposed teams are being measured against.
      itemCount: results.length + (idealProfile == null ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        if (idealProfile != null && index == 0) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.flag_outlined, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idealProfile,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          );
        }
        final i = idealProfile == null ? index : index - 1;
        final comp = results[i];

        return Card(
          elevation: i == 0 ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: i == 0 ? BorderSide(color: cs.primary, width: 2) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i == 0) ...[
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(l10n.teamBestMatch, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${comp.overallScore.round()}/100', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                ] else ...[
                  Row(
                    children: [
                      Text('${l10n.teamAlternative} $i', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('${comp.overallScore.round()}/100', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                Text(l10n.teamMembers, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(comp.members.length, (idx) {
                    final m = comp.members[idx];
                    final p = comp.profiles[idx];
                    final color = AppTheme.mbtiTypeColor(p.type.label, Theme.of(context).brightness);

                    return Chip(
                      avatar: CircleAvatar(backgroundColor: color.withAlpha(50), child: Text(p.type.label, style: TextStyle(fontSize: 10, color: color))),
                      label: Text(m.displayName),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                if (comp.strengths.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.contentSectionStrengths, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comp.strengths
                        .map((s) => _label(textContent?.strengths, s))
                        .join('\n'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                ],

                if (comp.blindSpots.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cs.error, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.contentSectionWeaknesses, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.error)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comp.blindSpots
                        .map((s) => _label(textContent?.blindSpots, s))
                        .join('\n'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The objective names live in the ARB, not in `team_objectives.json`: they label
/// a control, and the dropdown has to be usable even if the content asset is
/// broken. The switch is exhaustive, so a new objective cannot ship unnamed.
String _objectiveTitle(AppLocalizations l10n, TeamObjective objective) =>
    switch (objective) {
      TeamObjective.creative => l10n.teamObjCreative,
      TeamObjective.execution => l10n.teamObjExecution,
      TeamObjective.crisis => l10n.teamObjCrisis,
      TeamObjective.innovation => l10n.teamObjInnovation,
      TeamObjective.support => l10n.teamObjSupport,
      TeamObjective.strategy => l10n.teamObjStrategy,
    };

String? _objectiveField(
  TeamObjectivesContent content,
  TeamObjective objective,
  String field,
) {
  final entry = content.objectives[objective.name] as Map<String, dynamic>?;
  return entry?[field] as String?;
}
