import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/entities/person.dart';
import '../../providers/person_provider.dart';
import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';
import '../person_detail/person_detail_screen.dart';
import '../person_edit/person_edit_screen.dart';

class PeopleListScreen extends ConsumerStatefulWidget {
  const PeopleListScreen({super.key});

  @override
  ConsumerState<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends ConsumerState<PeopleListScreen> {
  String _search = '';
  bool _searchActive = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final personsAsync = ref.watch(allPersonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searchActive
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.actionSearch,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _search = v),
              )
            : Text(l10n.navPeople),
        actions: [
          IconButton(
            icon: Icon(_searchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchActive = !_searchActive;
                if (!_searchActive) {
                  _search = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
        ],
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric)),
        data: (persons) {
          final filtered = persons
              .where((p) => !p.isSelf)
              .where((p) => _search.isEmpty ||
                  p.displayName
                      .toLowerCase()
                      .contains(_search.toLowerCase()))
              .toList();

          if (filtered.isEmpty && _search.isEmpty) {
            return _EmptyPeopleView(l10n: l10n);
          }

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'Nessun risultato per "$_search"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }

          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 76),
            itemBuilder: (ctx, i) => _PersonTile(person: filtered[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const PersonEditScreen(personId: null)),
        ),
        tooltip: l10n.personAddNew,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _PersonTile extends ConsumerWidget {
  const _PersonTile({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;

    return FutureBuilder<String?>(
      future: _getMbtiType(ref),
      builder: (ctx, snap) {
        final mbtiType = snap.data;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _Avatar(person: person, mbtiType: mbtiType),
          title: Text(
            person.displayName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Row(
            children: [
              _RoleChip(role: person.role),
              if (mbtiType != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.mbtiTypeColor(mbtiType, brightness)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mbtiType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mbtiTypeColor(mbtiType, brightness),
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => PersonDetailScreen(personId: person.id)),
          ),
        );
      },
    );
  }

  Future<String?> _getMbtiType(WidgetRef ref) async {
    final profiles =
        await ref.read(profileRepositoryProvider).getForPerson(person.id);
    final mbti = profiles.where((p) => p.system.name == 'mbti').firstOrNull;
    if (mbti == null) return null;
    return (mbti.data['type'] as String?);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, this.mbtiType});

  final Person person;
  final String? mbtiType;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = mbtiType != null
        ? AppTheme.mbtiTypeColor(mbtiType!, brightness)
        : Theme.of(context).colorScheme.secondaryContainer;

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withAlpha(40),
      child: Text(
        person.displayName.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final PersonRole role;

  @override
  Widget build(BuildContext context) {
    return Text(
      _roleLabel(context, role),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  String _roleLabel(BuildContext context, PersonRole role) {
    final l10n = AppLocalizations.of(context);
    return switch (role) {
      PersonRole.family => l10n.roleFamily,
      PersonRole.friend => l10n.roleFriend,
      PersonRole.partner => l10n.rolePartner,
      PersonRole.colleague => l10n.roleColleague,
      PersonRole.acquaintance => l10n.roleAcquaintance,
      PersonRole.other => l10n.roleOther,
    };
  }
}

class _EmptyPeopleView extends StatelessWidget {
  const _EmptyPeopleView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyPeopleList,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyPeopleListAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
