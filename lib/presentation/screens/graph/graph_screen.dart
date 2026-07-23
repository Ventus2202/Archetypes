import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:graphview/GraphView.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/relationship.dart';
import '../../../domain/personality_systems/mbti/mbti_types.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/affinity/cognitive_function_affinity.dart';
import '../../../data/repositories/group_repository.dart';
import '../../providers/person_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';
import '../person_detail/person_detail_screen.dart';
import '../person_edit/person_edit_screen.dart';

enum GraphViewMode { free, cluster, timeline }

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  GraphViewMode _mode = GraphViewMode.free;
  final Set<int> _selectedGroups = {};
  final Set<MbtiType> _selectedTypes = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final personsAsync = ref.watch(allPersonsProvider);
    final groupsAsync = ref.watch(allGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.graphTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const PersonEditScreen(personId: null)),
            ),
            tooltip: l10n.personAddNew,
          ),
        ],
      ),
      body: Column(
        children: [
          _ModeSelector(
            mode: _mode,
            onModeChanged: (m) => setState(() => _mode = m),
            l10n: l10n,
          ),
          _FilterBar(
            groupsAsync: groupsAsync,
            selectedGroups: _selectedGroups,
            selectedTypes: _selectedTypes,
            onGroupToggle: (id) => setState(() {
              if (_selectedGroups.contains(id)) {
                _selectedGroups.remove(id);
              } else {
                _selectedGroups.add(id);
              }
            }),
            onTypeToggle: (t) => setState(() {
              if (_selectedTypes.contains(t)) {
                _selectedTypes.remove(t);
              } else {
                _selectedTypes.add(t);
              }
            }),
          ),
          Expanded(
            child: personsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.errorGeneric)),
              data: (persons) {
                if (persons.isEmpty) {
                  return _EmptyGraphView(l10n: l10n);
                }
                return _GraphBody(
                  persons: persons,
                  mode: _mode,
                  filterGroups: _selectedGroups,
                  filterTypes: _selectedTypes,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.groupsAsync,
    required this.selectedGroups,
    required this.selectedTypes,
    required this.onGroupToggle,
    required this.onTypeToggle,
  });

  final AsyncValue<List<Group>> groupsAsync;
  final Set<int> selectedGroups;
  final Set<MbtiType> selectedTypes;
  final ValueChanged<int> onGroupToggle;
  final ValueChanged<MbtiType> onTypeToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          groupsAsync.when(
            data: (groups) => Row(
              children: groups.map((g) {
                final sel = selectedGroups.contains(g.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(g.name),
                    selected: sel,
                    onSelected: (_) => onGroupToggle(g.id),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
          const VerticalDivider(width: 24, indent: 8, endIndent: 8),
          ...MbtiType.values.take(16).map((t) {
             final sel = selectedTypes.contains(t);
             return Padding(
               padding: const EdgeInsets.only(right: 8),
               child: FilterChip(
                 label: Text(t.label),
                 selected: sel,
                 onSelected: (_) => onTypeToggle(t),
                 visualDensity: VisualDensity.compact,
                 labelStyle: const TextStyle(fontSize: 11),
               ),
             );
          }),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector(
      {required this.mode, required this.onModeChanged, required this.l10n});

  final GraphViewMode mode;
  final ValueChanged<GraphViewMode> onModeChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<GraphViewMode>(
        segments: [
          ButtonSegment(
              value: GraphViewMode.free,
              icon: const Icon(Icons.scatter_plot_outlined, size: 16),
              label: Text(l10n.graphModeFree)),
          ButtonSegment(
              value: GraphViewMode.cluster,
              icon: const Icon(Icons.bubble_chart_outlined, size: 16),
              label: Text(l10n.graphModeCluster)),
          ButtonSegment(
              value: GraphViewMode.timeline,
              icon: const Icon(Icons.timeline_outlined, size: 16),
              label: Text(l10n.graphModeTimeline)),
        ],
        selected: {mode},
        onSelectionChanged: (s) => onModeChanged(s.first),
      ),
    );
  }
}

class _EmptyGraphView extends StatelessWidget {
  const _EmptyGraphView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.graphNoConnections,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GraphBody extends ConsumerStatefulWidget {
  const _GraphBody({
    required this.persons,
    required this.mode,
    required this.filterGroups,
    required this.filterTypes,
  });

  final List<Person> persons;
  final GraphViewMode mode;
  final Set<int> filterGroups;
  final Set<MbtiType> filterTypes;

  @override
  ConsumerState<_GraphBody> createState() => _GraphBodyState();
}

class _GraphBodyState extends ConsumerState<_GraphBody> {
  Graph _graph = Graph()..isTree = false;
  final FruchtermanReingoldAlgorithm _algorithm = FruchtermanReingoldAlgorithm(
    FruchtermanReingoldConfiguration(iterations: 1000, repulsionRate: 0.5),
  );
  Map<int, MbtiProfile?> _profiles = {};
  Map<int, List<int>> _personGroups = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(_GraphBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.persons != widget.persons ||
        oldWidget.filterGroups != widget.filterGroups ||
        oldWidget.filterTypes != widget.filterTypes) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final groupRepo = ref.read(groupRepositoryProvider);
    
    final Map<int, MbtiProfile?> profiles = {};
    final Map<int, List<int>> personGroups = {};

    for (final person in widget.persons) {
      final profileEntries = await profileRepo.getForPerson(person.id);
      final mbtiEntry = profileEntries
          .where((p) => p.system.name == 'mbti')
          .firstOrNull;
      if (mbtiEntry != null) {
        try {
          profiles[person.id] = MbtiProfile.fromJson(
              Map<String, dynamic>.from(mbtiEntry.data));
        } catch (_) {
          profiles[person.id] = null;
        }
      }

      final groups = await groupRepo.getForPerson(person.id);
      personGroups[person.id] = groups.map((g) => g.id).toList();
    }

    if (mounted) {
      setState(() {
        _profiles = profiles;
        _personGroups = personGroups;
      });
      _buildGraph();
    }
  }

  Future<void> _buildGraph() async {
    final relRepo = ref.read(relationshipRepositoryProvider);
    final relationships = await relRepo.watchAll().first;

    final graph = Graph()..isTree = false;

    final filteredPersons = widget.persons.where((p) {
      final groups = _personGroups[p.id] ?? [];
      final profile = _profiles[p.id];
      
      bool matchesGroup = widget.filterGroups.isEmpty || 
          groups.any((id) => widget.filterGroups.contains(id));
      
      bool matchesType = widget.filterTypes.isEmpty ||
          (profile != null && widget.filterTypes.contains(profile.type));
      
      return matchesGroup && matchesType;
    }).toList();

    for (final person in filteredPersons) {
      graph.addNode(Node.Id(person.id));
    }

    final personIds = filteredPersons.map((p) => p.id).toSet();
    for (final rel in relationships) {
      if (personIds.contains(rel.personAId) &&
          personIds.contains(rel.personBId)) {
        graph.addEdge(
          Node.Id(rel.personAId),
          Node.Id(rel.personBId),
          paint: Paint()
            ..color = _relationColor(rel.kind)
            ..strokeWidth = _edgeWidth(rel),
        );
      }
    }

    if (mounted) setState(() => _graph = graph);
  }

  Color _relationColor(RelationshipKind kind) {
    final cs = Theme.of(context).colorScheme;
    return switch (kind) {
      RelationshipKind.romantic => Colors.pink,
      RelationshipKind.family => Colors.orange,
      RelationshipKind.friendship => cs.primary,
      RelationshipKind.professional => Colors.teal,
      RelationshipKind.conflict => Colors.red,
      _ => cs.outlineVariant,
    };
  }

  double _edgeWidth(Relationship rel) {
    final profileA = _profiles[rel.personAId];
    final profileB = _profiles[rel.personBId];
    if (profileA != null && profileB != null) {
      final affinity =
          CognitiveFunctionAffinity.calculate(profileA, profileB);
      return 1.0 + (affinity.score / 100) * 4.0;
    }
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    if (_graph.nodes.isEmpty && widget.persons.isNotEmpty) {
      return Center(child: Text(AppLocalizations.of(context).errorNotFound));
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(400),
      minScale: 0.1,
      maxScale: 3.0,
      child: GraphView(
        graph: _graph,
        algorithm: _algorithm,
        paint: Paint()
          ..color = Theme.of(context).colorScheme.outlineVariant.withAlpha(50)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          final id = node.key?.value as int?;
          if (id == null) return const SizedBox.shrink();
          final person =
              widget.persons.firstWhere((p) => p.id == id);
          return _PersonNode(
            person: person,
            profile: _profiles[id],
          );
        },
      ),
    );
  }
}

class _PersonNode extends ConsumerWidget {
  const _PersonNode({required this.person, this.profile});

  final Person person;
  final MbtiProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelf = person.isSelf;
    final size = isSelf ? 72.0 : 58.0;
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    final nodeColor = profile != null
        ? AppTheme.mbtiTypeColor(profile!.type.label, brightness)
        : (isSelf ? cs.primary : cs.secondaryContainer);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => PersonDetailScreen(personId: person.id)),
      ),
      onLongPress: () => _showQuickMenu(context, ref),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor.withAlpha(40),
              border: Border.all(
                color: nodeColor,
                width: isSelf ? 3 : 2,
              ),
              image: person.avatarBytes != null
                  ? DecorationImage(
                      image: MemoryImage(person.avatarBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: person.avatarBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        person.displayName.characters.first.toUpperCase(),
                        style: TextStyle(
                          fontSize: isSelf ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: nodeColor,
                        ),
                      ),
                      if (profile != null)
                        Text(
                          profile!.type.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: nodeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: Text(
              person.displayName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isSelf ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(person.displayName),
              subtitle: profile != null ? Text(profile!.type.label) : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: Text(l10n.actionLearnMore),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PersonDetailScreen(personId: person.id)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.actionEdit),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PersonEditScreen(personId: person.id)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
