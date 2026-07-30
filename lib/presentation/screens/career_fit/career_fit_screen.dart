import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/career/career_fit.dart';
import '../../providers/career_provider.dart';
import '../../providers/database_provider.dart';

class CareerFitScreen extends ConsumerStatefulWidget {
  final PersonalityProfile profile;

  const CareerFitScreen({super.key, required this.profile});

  @override
  ConsumerState<CareerFitScreen> createState() => _CareerFitScreenState();
}

class _CareerFitScreenState extends ConsumerState<CareerFitScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final results = ref.watch(careerFitProvider(widget.profile));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careerFitTitle),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: cs.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.careerDisclaimer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: ref.read(contentRepositoryProvider).loadCareerRolesContent(Localizations.localeOf(context).languageCode),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                // A broken asset used to arrive here as empty content, so the
                // list rendered with raw role keys and no descriptions; with
                // `!snap.hasData` it would now spin forever instead.
                if (snap.hasError || snap.data == null) {
                  return Center(child: Text(l10n.errorNotFound));
                }

                final textContent = snap.data!;

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final res = results[i];
                    // Typed, so the three reads below are static calls: on a
                    // raw `dynamic` they would compile even when wrong (see
                    // `avoid_dynamic_calls` in `analysis_options.yaml`).
                    final roleData =
                        textContent.roles[res.role.id] as Map<String, dynamic>? ??
                            const {};


                    return _CareerRoleTile(
                      result: res,
                      title: roleData['title'] as String? ?? res.role.titleKey,
                      description: roleData['description'] as String? ?? '',
                      whyFit: roleData['why_fit'] as String? ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerRoleTile extends StatefulWidget {
  final CareerFitResult result;
  final String title;
  final String description;
  final String whyFit;

  const _CareerRoleTile({
    required this.result,
    required this.title,
    required this.description,
    required this.whyFit,
  });

  @override
  State<_CareerRoleTile> createState() => _CareerRoleTileState();
}

class _CareerRoleTileState extends State<_CareerRoleTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = widget.result.score.round();
    
    Color scoreColor;
    if (score >= 75) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = cs.error;
    }

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$score',
                    style: TextStyle(fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: cs.onSurfaceVariant),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 16),
              Text(widget.description),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.whyFit,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

