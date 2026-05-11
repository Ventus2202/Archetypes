import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_types.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/sharing/shared_profile.dart';
import '../../providers/person_provider.dart';
import '../../providers/database_provider.dart';

class PersonEditScreen extends ConsumerStatefulWidget {
  final int? personId;
  final SharedProfile? sharedProfile;

  const PersonEditScreen({super.key, this.personId, this.sharedProfile});

  @override
  ConsumerState<PersonEditScreen> createState() => _PersonEditScreenState();
}

class _PersonEditScreenState extends ConsumerState<PersonEditScreen> {
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  PersonRole _role = PersonRole.friend;
  MbtiType? _mbtiType;
  int _mbtiConfidence = 80;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.personId != null) {
      _loadExisting();
    } else if (widget.sharedProfile != null) {
      _loadFromShared();
    }
  }

  void _loadFromShared() {
    final sp = widget.sharedProfile!;
    _nameCtrl.text = sp.name;
    _mbtiType = sp.type;
    _mbtiConfidence = sp.confidence;
  }

  Future<void> _loadExisting() async {
    final personRepo = ref.read(personRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final person = await personRepo.getById(widget.personId!);
    if (person == null || !mounted) return;

    _nameCtrl.text = person.name;
    _nicknameCtrl.text = person.nickname ?? '';
    _notesCtrl.text = person.notes ?? '';
    _role = person.role;

    final profiles = await profileRepo.getForPerson(person.id);
    final mbti =
        profiles.where((p) => p.system == PersonalitySystem.mbti).firstOrNull;
    if (mbti != null) {
      try {
        final profile =
            MbtiProfile.fromJson(Map<String, dynamic>.from(mbti.data));
        _mbtiType = profile.type;
        _mbtiConfidence = mbti.confidence;
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_loading) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Inserisci un nome')));
      return;
    }

    setState(() => _loading = true);
    final personRepo = ref.read(personRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    int personId;
    if (widget.personId == null) {
      personId = await personRepo.insert(Person(
        id: 0,
        name: _nameCtrl.text.trim(),
        nickname: _nicknameCtrl.text.trim().isEmpty
            ? null
            : _nicknameCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        role: _role,
        isSelf: false,
        createdAt: DateTime.now(),
      ));
    } else {
      personId = widget.personId!;
      final existing = await personRepo.getById(personId);
      if (existing != null) {
        await personRepo.update(existing.copyWith(
          name: _nameCtrl.text.trim(),
          nickname: _nicknameCtrl.text.trim().isEmpty
              ? null
              : _nicknameCtrl.text.trim(),
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          role: _role,
        ));
      }
    }

    if (_mbtiType != null) {
      final profile = MbtiProfile.fromType(_mbtiType!);
      final existingProfiles =
          await profileRepo.getForPerson(personId);
      final existingMbti = existingProfiles
          .where((p) => p.system == PersonalitySystem.mbti)
          .firstOrNull;

      await profileRepo.upsert(PersonalityProfile(
        id: existingMbti?.id ?? 0,
        personId: personId,
        system: PersonalitySystem.mbti,
        data: profile.toJson(),
        confidence: _mbtiConfidence,
        source: ProfileSource.manual,
        updatedAt: DateTime.now(),
      ));
    }

    ref.invalidate(allPersonsProvider);
    ref.invalidate(personByIdProvider(personId));

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirmDeleteAction),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(personRepositoryProvider).delete(widget.personId!);
      ref.invalidate(allPersonsProvider);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst || false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.personId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? l10n.personEditTitle : l10n.personAddNew),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: _delete,
            ),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: l10n.personName),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.personName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameCtrl,
            decoration: InputDecoration(
              labelText: l10n.personNickname,
              prefixIcon: const Icon(Icons.label_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l10n.personRole),
          _RoleSelector(
            selected: _role,
            onChanged: (r) => setState(() => _role = r),
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l10n.mbtiTypeLabel),
          _TypeSelector(
            selected: _mbtiType,
            onChanged: (t) => setState(() => _mbtiType = t),
          ),
          if (_mbtiType != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.mbtiConfidenceHint(_mbtiConfidence),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Slider(
              value: _mbtiConfidence.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$_mbtiConfidence%',
              onChanged: (v) => setState(() => _mbtiConfidence = v.round()),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(label: l10n.personNotes),
          TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: l10n.personNotes,
              prefixIcon: const Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final PersonRole selected;
  final ValueChanged<PersonRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = PersonRole.values;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: roles.map((r) {
        final sel = r == selected;
        return FilterChip(
          label: Text(_roleLabel(l10n, r)),
          selected: sel,
          onSelected: (_) => onChanged(r),
        );
      }).toList(),
    );
  }

  String _roleLabel(AppLocalizations l10n, PersonRole role) => switch (role) {
        PersonRole.family => l10n.roleFamily,
        PersonRole.friend => l10n.roleFriend,
        PersonRole.partner => l10n.rolePartner,
        PersonRole.colleague => l10n.roleColleague,
        PersonRole.acquaintance => l10n.roleAcquaintance,
        PersonRole.other => l10n.roleOther,
      };
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final MbtiType? selected;
  final ValueChanged<MbtiType?> onChanged;

  static const _allTypes = [
    MbtiType.intj, MbtiType.intp, MbtiType.entj, MbtiType.entp,
    MbtiType.infj, MbtiType.infp, MbtiType.enfj, MbtiType.enfp,
    MbtiType.istj, MbtiType.istp, MbtiType.estj, MbtiType.estp,
    MbtiType.isfj, MbtiType.isfp, MbtiType.esfj, MbtiType.esfp,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _allTypes.map((t) {
        final sel = t == selected;
        return FilterChip(
          label: Text(t.label),
          selected: sel,
          onSelected: (_) => onChanged(sel ? null : t),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: sel ? null : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }).toList(),
    );
  }
}
