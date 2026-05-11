import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/affinity/cognitive_function_affinity.dart';
import '../../../domain/affinity/relationship_dynamics.dart';
import '../../providers/person_provider.dart';
import '../../providers/database_provider.dart';
import '../../../data/repositories/content_repository.dart';
import '../../theme/app_theme.dart';
import '../person_edit/person_edit_screen.dart';
import '../content_viewer/content_viewer_screen.dart';

class PersonDetailScreen extends ConsumerWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final personAsync = ref.watch(personByIdProvider(personId));

    return personAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(l10n.errorGeneric))),
      data: (person) {
        if (person == null) {
          return Scaffold(body: Center(child: Text(l10n.errorNotFound)));
        }
        return _PersonDetailContent(person: person);
      },
    );
  }
}

class _PersonDetailContent extends ConsumerStatefulWidget {
  const _PersonDetailContent({required this.person});

  final Person person;

  @override
  ConsumerState<_PersonDetailContent> createState() =>
      _PersonDetailContentState();
}

class _PersonDetailContentState
    extends ConsumerState<_PersonDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = widget.person;
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<List<PersonalityProfile>>(
      future: ref.read(profileRepositoryProvider).getForPerson(person.id),
      builder: (ctx, profileSnap) {
        final profiles = profileSnap.data ?? [];
        final mbtiProfile = _getMbtiProfile(profiles);
        final nodeColor = mbtiProfile != null
            ? AppTheme.mbtiTypeColor(mbtiProfile.type.label, brightness)
            : cs.primary;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                actions: [
                  if (!person.isSelf)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                PersonEditScreen(personId: person.id)),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          nodeColor.withAlpha(30),
                          nodeColor.withAlpha(10),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: nodeColor.withAlpha(40),
                          child: Text(
                            person.displayName.characters.first.toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: nodeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          person.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (person.nickname != null &&
                            person.nickname != person.name)
                          Text(
                            person.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (mbtiProfile != null) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ContentViewerScreen(
                                  contentKey: mbtiProfile.type.label,
                                  contentType: ContentViewerType.mbtiType,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: nodeColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: nodeColor.withAlpha(80)),
                              ),
                              child: Text(
                                mbtiProfile.type.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: nodeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabCtrl,
                  tabs: [
                    Tab(text: l10n.tabPersonality),
                    Tab(text: l10n.tabNotes),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                _PersonalityTab(
                    person: person, mbtiProfile: mbtiProfile),
                _NotesTab(person: person),
              ],
            ),
          ),
        );
      },
    );
  }

  MbtiProfile? _getMbtiProfile(List<PersonalityProfile> profiles) {
    final mbti =
        profiles.where((p) => p.system == PersonalitySystem.mbti).firstOrNull;
    if (mbti == null) return null;
    try {
      return MbtiProfile.fromJson(Map<String, dynamic>.from(mbti.data));
    } catch (_) {
      return null;
    }
  }
}

class _PersonalityTab extends ConsumerWidget {
  const _PersonalityTab({required this.person, this.mbtiProfile});

  final Person person;
  final MbtiProfile? mbtiProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (mbtiProfile == null) {
      return Center(child: Text(l10n.affinityNoProfile));
    }

    return FutureBuilder<({AffinityResult affinity, RelationshipReport report, RelationshipDynamicsContent textContent})?>(
      future: _computeAffinityWithSelf(ref, mbtiProfile!, context),
      builder: (ctx, affinitySnap) {
        final data = affinitySnap.data;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FunctionStackCard(profile: mbtiProfile!),
            const SizedBox(height: 12),
            if (data != null && !person.isSelf) ...[
              _AffinityCard(affinity: data.affinity, personName: person.displayName),
              const SizedBox(height: 12),
              _DynamicsReportCard(report: data.report, textContent: data.textContent),
            ],
          ],
        );
      },
    );
  }

  Future<({AffinityResult affinity, RelationshipReport report, RelationshipDynamicsContent textContent})?> _computeAffinityWithSelf(
      WidgetRef ref, MbtiProfile profile, BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    final self = await ref.read(personRepositoryProvider).getSelf();
    if (self == null) return null;
    final selfProfiles =
        await ref.read(profileRepositoryProvider).getForPerson(self.id);
    final selfMbti =
        selfProfiles.where((p) => p.system.name == 'mbti').firstOrNull;
    if (selfMbti == null) return null;
    try {
      final selfProfile =
          MbtiProfile.fromJson(Map<String, dynamic>.from(selfMbti.data));
      final affinity = CognitiveFunctionAffinity.calculate(selfProfile, profile);
      final report = RelationshipDynamics.analyze(selfProfile, profile);
      
      final textContent = await ref.read(contentRepositoryProvider).loadDynamicsContent(locale);

      return (affinity: affinity, report: report, textContent: textContent);
    } catch (_) {
      return null;
    }
  }
}

class _FunctionStackCard extends StatelessWidget {
  const _FunctionStackCard({required this.profile});

  final MbtiProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final posLabels = [
      l10n.mbtiDominant,
      l10n.mbtiAuxiliary,
      l10n.mbtiTertiary,
      l10n.mbtiInferior,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contentSectionStack,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            ...profile.stack.asMap().entries.map((e) {
              final funcColor =
                  AppTheme.mbtiTypeColor(e.value.label, brightness);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: funcColor.withAlpha(30),
                        border: Border.all(color: funcColor.withAlpha(80)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e.value.label,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: funcColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(posLabels[e.key],
                            style: Theme.of(context).textTheme.labelMedium),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ContentViewerScreen(
                                contentKey: e.value.label,
                                contentType: ContentViewerType.mbtiFunction,
                              ),
                            ),
                          ),
                          child: Text(
                            e.value.label,
                            style: TextStyle(
                              color: funcColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AffinityCard extends StatelessWidget {
  const _AffinityCard(
      {required this.affinity, required this.personName});

  final AffinityResult affinity;
  final String personName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final score = affinity.score.round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.affinityWith(personName),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: cs.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: affinity.score / 100,
                        strokeWidth: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _affinityColor(cs, affinity.score),
                        ),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _affinityLabel(l10n, affinity.score),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: _affinityColor(cs, affinity.score),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.affinityScore(score),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (affinity.factors.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              Text(
                l10n.affinityBreakdown,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              ...affinity.factors.take(4).map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(f.functionA.label,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text(' ↔ '),
                        Text(f.functionB.label,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          '+${(f.contribution * 20).round()}',
                          style: TextStyle(
                            color: cs.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color _affinityColor(ColorScheme cs, double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return cs.primary;
  }

  String _affinityLabel(AppLocalizations l10n, double score) {
    if (score >= 75) return l10n.affinityHigh;
    if (score >= 50) return l10n.affinityMedium;
    return l10n.affinityLow;
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (person.notes?.isNotEmpty == true)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(person.notes!),
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                'Nessuna nota',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        if (person.firstMetDate != null)
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Prima volta'),
            subtitle: Text(
              '${person.firstMetDate!.day}/${person.firstMetDate!.month}/${person.firstMetDate!.year}',
            ),
          ),
      ],
    );
  }
}

class _DynamicsReportCard extends StatelessWidget {
  const _DynamicsReportCard({
    required this.report,
    required this.textContent,
  });

  final RelationshipReport report;
  final RelationshipDynamicsContent textContent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.frictionPoints.isNotEmpty) ...[
              Text(
                l10n.reportFrictionPoints,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.error),
              ),
              const SizedBox(height: 8),
              ...report.frictionPoints.map((f) => _buildItem(
                    icon: Icons.warning_amber_rounded,
                    iconColor: cs.error,
                    title: textContent.frictions[f.titleKey.replaceAll('_title', '')]?['title'] ?? f.titleKey,
                    desc: textContent.frictions[f.titleKey.replaceAll('_title', '')]?['description'] ?? f.descriptionKey,
                    context: context,
                  )),
              const Divider(height: 24),
            ],
            
            if (report.mutualGrowthAreas.isNotEmpty) ...[
              Text(
                l10n.reportGrowthAreas,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.green),
              ),
              const SizedBox(height: 8),
              ...report.mutualGrowthAreas.map((g) => _buildItem(
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                    title: textContent.growths[g.titleKey.replaceAll('_title', '')]?['title'] ?? g.titleKey,
                    desc: textContent.growths[g.titleKey.replaceAll('_title', '')]?['description'] ?? g.descriptionKey,
                    context: context,
                  )),
              const Divider(height: 24),
            ],

            if (report.communicationTips.isNotEmpty) ...[
              Text(
                l10n.reportCommunication,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.primary),
              ),
              const SizedBox(height: 8),
              ...report.communicationTips.map((c) => _buildItem(
                    icon: Icons.chat_bubble_outline,
                    iconColor: cs.primary,
                    title: textContent.communications[c.titleKey.replaceAll('_title', '')]?['title'] ?? c.titleKey,
                    desc: textContent.communications[c.titleKey.replaceAll('_title', '')]?['description'] ?? c.descriptionKey,
                    context: context,
                  )),
              const Divider(height: 24),
            ],

            Text(
              l10n.reportAxisAnalysis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.secondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAxis(l10n.axisIE, report.axisAnalysis.ieStatus, l10n, cs)),
                Expanded(child: _buildAxis(l10n.axisNS, report.axisAnalysis.nsStatus, l10n, cs)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildAxis(l10n.axisTF, report.axisAnalysis.tfStatus, l10n, cs)),
                Expanded(child: _buildAxis(l10n.axisJP, report.axisAnalysis.jpStatus, l10n, cs)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxis(String label, AxisStatus status, AppLocalizations l10n, ColorScheme cs) {
    final statusText = switch (status) {
      AxisStatus.aligned => l10n.reportAxisAligned,
      AxisStatus.complementary => l10n.reportAxisComplementary,
      AxisStatus.tension => l10n.reportAxisTension,
    };
    final color = switch (status) {
      AxisStatus.aligned => Colors.green,
      AxisStatus.complementary => cs.primary,
      AxisStatus.tension => cs.error,
    };
    final icon = switch (status) {
      AxisStatus.aligned => Icons.check_circle_outline,
      AxisStatus.complementary => Icons.sync_alt,
      AxisStatus.tension => Icons.bolt,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(statusText, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ],
    );
  }
}
