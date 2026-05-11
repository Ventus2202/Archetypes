import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../data/repositories/content_repository.dart';

enum ContentViewerType { mbtiType, mbtiFunction, mbtiDichotomy }

class ContentViewerScreen extends ConsumerWidget {
  final String contentKey;
  final ContentViewerType contentType;

  const ContentViewerScreen({
    super.key,
    required this.contentKey,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final repo = ref.read(contentRepositoryProvider);

    return Scaffold(
      body: FutureBuilder<MbtiContent>(
        future: repo.loadMbtiContent(locale.languageCode),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text(l10n.errorNotFound));
          }
          final content = snap.data!;
          Map<String, dynamic>? data;
          switch (contentType) {
            case ContentViewerType.mbtiType:
              data = repo.getTypeContent(content, contentKey);
            case ContentViewerType.mbtiFunction:
              data = repo.getFunctionContent(content, contentKey);
            case ContentViewerType.mbtiDichotomy:
              data = repo.getDichotomyContent(content, contentKey);
          }

          if (data == null) {
            return Center(child: Text(l10n.errorNotFound));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(data['title'] as String? ?? contentKey),
                expandedHeight: 140,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ContentBody(data: data, contentType: contentType, l10n: l10n),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  const _ContentBody({
    required this.data,
    required this.contentType,
    required this.l10n,
  });

  final Map<String, dynamic> data;
  final ContentViewerType contentType;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (contentType) {
      case ContentViewerType.mbtiType:
        return _MbtiTypeBody(data: data, l10n: l10n);
      case ContentViewerType.mbtiFunction:
        return _MbtiFunctionBody(data: data, l10n: l10n);
      case ContentViewerType.mbtiDichotomy:
        return _MbtiDichotomyBody(data: data, l10n: l10n);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    Expanded(child: Text(item)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MbtiTypeBody extends StatelessWidget {
  const _MbtiTypeBody({required this.data, required this.l10n});

  final Map<String, dynamic> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final descriptions = (data['description'] as List?)?.cast<String>() ?? [];
    final strengths = (data['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses = (data['weaknesses'] as List?)?.cast<String>() ?? [];
    final behaviors = (data['behavioral_traits'] as List?)?.cast<String>() ?? [];
    final stack = (data['stack'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['tagline'] != null)
          Text(
            '"${data['tagline']}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ...descriptions.map((d) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(d),
            )),
        if (stack.isNotEmpty)
          _Section(
            title: l10n.contentSectionStack,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stack.asMap().entries.map((e) {
                final labels = [
                  l10n.mbtiDominant,
                  l10n.mbtiAuxiliary,
                  l10n.mbtiTertiary,
                  l10n.mbtiInferior,
                ];
                return Chip(
                  label: Text('${e.value} (${labels[e.key]})'),
                );
              }).toList(),
            ),
          ),
        if (strengths.isNotEmpty)
          _Section(
            title: l10n.contentSectionStrengths,
            child: _BulletList(items: strengths),
          ),
        if (weaknesses.isNotEmpty)
          _Section(
            title: l10n.contentSectionWeaknesses,
            child: _BulletList(items: weaknesses),
          ),
        if (behaviors.isNotEmpty)
          _Section(
            title: l10n.contentSectionBehaviors,
            child: _BulletList(items: behaviors),
          ),
        if (data['in_relationships'] != null)
          _Section(
            title: l10n.contentSectionRelationships,
            child: Text(data['in_relationships'] as String),
          ),
        if (data['at_work'] != null)
          _Section(
            title: l10n.contentSectionWork,
            child: Text(data['at_work'] as String),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MbtiFunctionBody extends StatelessWidget {
  const _MbtiFunctionBody({required this.data, required this.l10n});

  final Map<String, dynamic> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final descriptions = (data['description'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['full_name'] != null)
          Text(
            data['full_name'] as String,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ...descriptions.map((d) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(d),
            )),
        if (data['as_dominant'] != null)
          _Section(
            title: l10n.mbtiDominant,
            child: Text(data['as_dominant'] as String),
          ),
        if (data['as_auxiliary'] != null)
          _Section(
            title: l10n.mbtiAuxiliary,
            child: Text(data['as_auxiliary'] as String),
          ),
        if (data['as_tertiary'] != null)
          _Section(
            title: l10n.mbtiTertiary,
            child: Text(data['as_tertiary'] as String),
          ),
        if (data['as_inferior'] != null)
          _Section(
            title: l10n.mbtiInferior,
            child: Text(data['as_inferior'] as String),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MbtiDichotomyBody extends StatelessWidget {
  const _MbtiDichotomyBody({required this.data, required this.l10n});

  final Map<String, dynamic> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final poles = data['poles'] as List?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['spectrum_note'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(data['spectrum_note'] as String),
          ),
        if (poles != null) ...[
          for (final pole in poles.cast<Map>()) ...[
            const SizedBox(height: 20),
            Text(
              pole['label'] as String? ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(pole['description'] as String? ?? ''),
            if (pole['behavioral_markers'] != null) ...[
              const SizedBox(height: 8),
              _BulletList(
                  items:
                      (pole['behavioral_markers'] as List).cast<String>()),
            ],
          ],
        ],
        if (data['common_myths'] != null) ...[
          const SizedBox(height: 24),
          Text('Miti comuni',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )),
          const SizedBox(height: 8),
          _BulletList(items: (data['common_myths'] as List).cast<String>()),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
