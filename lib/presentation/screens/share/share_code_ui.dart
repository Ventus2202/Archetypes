import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/person.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_types.dart';
import '../../../domain/sharing/share_code.dart';
import '../../providers/database_provider.dart';

/// Groups a 24-char code into blocks of 4 for readability.
String formatShareCode(String code) {
  final buf = StringBuffer();
  for (var i = 0; i < code.length; i += 4) {
    if (i > 0) buf.write(' ');
    buf.write(code.substring(i, (i + 4).clamp(0, code.length)));
  }
  return buf.toString();
}

/// Builds the 24-char code for an MBTI profile, generating and persisting a
/// stable [PersonalityProfile.shareId] on first use. Returns null if the
/// profile has no recognizable MBTI type.
Future<String?> ensureShareCode(WidgetRef ref, PersonalityProfile profile) async {
  final type = MbtiType.fromLabel(profile.data['type'] as String? ?? '');
  if (type == null) return null;

  if (profile.shareId != null) {
    final id = ShareCode.parseIdHex(profile.shareId!);
    if (id != null) {
      return ShareCode(
        system: profile.system,
        type: type,
        confidence: profile.confidence,
        source: profile.source,
        id: id,
      ).encode();
    }
  }

  final code = ShareCode.generate(
    system: profile.system,
    type: type,
    confidence: profile.confidence,
    source: profile.source,
  );
  await ref.read(profileRepositoryProvider).upsert(
        profile.copyWith(shareId: code.idHex),
      );
  return code.encode();
}

/// Opens the bottom sheet that lets the user share their profile code.
Future<void> showShareCodeSheet(
  BuildContext context,
  WidgetRef ref,
  Person person,
  PersonalityProfile profile,
) async {
  final code = await ensureShareCode(ref, profile);
  if (!context.mounted) return;
  if (code == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profilo non condivisibile')),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _ShareCodeSheet(personName: person.displayName, code: code),
  );
}

class _ShareCodeSheet extends StatelessWidget {
  const _ShareCodeSheet({required this.personName, required this.code});

  final String personName;
  final String code;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Condividi il profilo di $personName',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Chi riceve questo codice lo inserisce nella propria mappa.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          const SizedBox(height: 20),
          SelectableText(
            formatShareCode(code),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copia'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Codice copiato')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Condividi'),
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(text: 'Il mio profilo Archetypes: $code'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opens the dialog that imports a profile from a 24-char code into the map.
Future<void> showImportCodeDialog(BuildContext context, WidgetRef ref) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _ImportCodeDialog(ref: ref),
  );
}

class _ImportCodeDialog extends StatefulWidget {
  const _ImportCodeDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_ImportCodeDialog> createState() => _ImportCodeDialogState();
}

class _ImportCodeDialogState extends State<_ImportCodeDialog> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  ShareCode? _decoded;
  bool _saving = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() => _decoded = ShareCode.decode(value));
  }

  bool get _canAdd =>
      _decoded != null &&
      _decoded!.system == PersonalitySystem.mbti &&
      _nameCtrl.text.trim().isNotEmpty &&
      !_saving;

  Future<void> _add() async {
    final code = _decoded;
    if (code == null) return;
    setState(() => _saving = true);

    final profileRepo = widget.ref.read(profileRepositoryProvider);
    final personRepo = widget.ref.read(personRepositoryProvider);
    final data = MbtiProfile.fromType(code.type).toJson();

    final existing = await profileRepo.getByShareId(code.idHex);
    String message;
    if (existing != null) {
      await profileRepo.upsert(existing.copyWith(
        data: data,
        confidence: code.confidence,
        source: code.source,
        updatedAt: DateTime.now(),
      ));
      message = 'Profilo già presente: aggiornato';
    } else {
      final personId = await personRepo.insert(Person(
        id: 0,
        name: _nameCtrl.text.trim(),
        role: PersonRole.acquaintance,
        isSelf: false,
        createdAt: DateTime.now(),
      ));
      await profileRepo.upsert(PersonalityProfile(
        id: 0,
        personId: personId,
        system: code.system,
        data: data,
        confidence: code.confidence,
        source: code.source,
        updatedAt: DateTime.now(),
        shareId: code.idHex,
      ));
      message = '${_nameCtrl.text.trim()} aggiunto alla mappa';
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final decoded = _decoded;
    final isMbti = decoded?.system == PersonalitySystem.mbti;

    return AlertDialog(
      title: const Text('Inserisci codice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Codice a 24 caratteri',
                border: OutlineInputBorder(),
              ),
              onChanged: _onCodeChanged,
            ),
            const SizedBox(height: 12),
            if (_codeCtrl.text.trim().isNotEmpty)
              if (decoded == null)
                Text('Codice non valido',
                    style: TextStyle(color: cs.error))
              else if (!isMbti)
                Text('Sistema non supportato',
                    style: TextStyle(color: cs.error))
              else
                Text(
                  'Profilo ${decoded.type.label} · confidenza ${decoded.confidence}%',
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome della persona',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _canAdd ? _add : null,
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}
