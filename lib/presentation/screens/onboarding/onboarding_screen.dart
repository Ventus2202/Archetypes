import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_types.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../providers/database_provider.dart';
import '../../providers/person_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  int _page = 0;
  String _method = 'manual';
  MbtiType? _selectedType;
  final Map<String, double> _dichotomies = {'ie': 0, 'ns': 0, 'tf': 0, 'jp': 0};
  bool _saving = false;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_page == 0 && _nameCtrl.text.trim().isEmpty) {
      _nameFocus.requestFocus();
      return;
    }
    if (_page < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      _save();
    }
  }

  void _goBack() {
    if (_page > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _page--);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final personRepo = ref.read(personRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final personId = await personRepo.insert(Person(
      id: 0,
      name: _nameCtrl.text.trim(),
      role: PersonRole.other,
      isSelf: true,
      createdAt: DateTime.now(),
    ));

    MbtiProfile? profile;
    if (_method == 'manual' && _selectedType != null) {
      profile = MbtiProfile.fromType(_selectedType!);
    } else if (_method == 'granular') {
      final derived = _deriveTypeFromDichotomies();
      profile = MbtiProfile.fromType(derived);
    }

    if (profile != null) {
      await profileRepo.upsert(PersonalityProfile(
        id: 0,
        personId: personId,
        system: PersonalitySystem.mbti,
        data: profile.toJson(),
        confidence: 80,
        source: _method == 'manual' ? ProfileSource.manual : ProfileSource.granular,
        updatedAt: DateTime.now(),
      ));
    }

    ref.invalidate(hasOnboardedProvider);
    ref.invalidate(selfPersonProvider);
    ref.invalidate(allPersonsProvider);
  }

  MbtiType _deriveTypeFromDichotomies() {
    final i = _dichotomies['ie']! < 0;
    final n = _dichotomies['ns']! > 0;
    final t = _dichotomies['tf']! > 0;
    final j = _dichotomies['jp']! > 0;
    final code =
        '${i ? 'i' : 'e'}${n ? 'n' : 's'}${t ? 't' : 'f'}${j ? 'j' : 'p'}';
    return MbtiType.fromLabel(code) ?? MbtiType.intj;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(cs),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(
                    nameCtrl: _nameCtrl,
                    focusNode: _nameFocus,
                    l10n: l10n,
                  ),
                  _MethodPage(
                    selectedMethod: _method,
                    onMethodSelected: (m) => setState(() => _method = m),
                    l10n: l10n,
                  ),
                  _method == 'granular'
                      ? _GranularPage(
                          dichotomies: _dichotomies,
                          onChanged: (key, val) =>
                              setState(() => _dichotomies[key] = val),
                          l10n: l10n,
                        )
                      : _TypeGridPage(
                          selectedType: _selectedType,
                          onTypeSelected: (t) =>
                              setState(() => _selectedType = t),
                          l10n: l10n,
                        ),
                ],
              ),
            ),
            _buildBottomBar(l10n, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalPages, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= _page ? cs.primary : cs.surfaceContainerHighest,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n, ColorScheme cs) {
    final isLast = _page == _totalPages - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_page > 0) ...[
            OutlinedButton(
              onPressed: _goBack,
              child: Text(l10n.actionBack),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _goNext,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLast ? l10n.onboardingComplete : l10n.actionNext),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.nameCtrl,
    required this.focusNode,
    required this.l10n,
  });

  final TextEditingController nameCtrl;
  final FocusNode focusNode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 48),
          Text(l10n.onboardingYourName,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: nameCtrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: l10n.onboardingNameHint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class _MethodPage extends StatelessWidget {
  const _MethodPage({
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.l10n,
  });

  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(l10n.onboardingChooseMethod,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          _MethodCard(
            method: 'manual',
            selected: selectedMethod == 'manual',
            title: l10n.onboardingMethodManual,
            description: l10n.onboardingMethodManualDesc,
            icon: Icons.style_outlined,
            onTap: onMethodSelected,
          ),
          const SizedBox(height: 12),
          _MethodCard(
            method: 'test',
            selected: selectedMethod == 'test',
            title: l10n.onboardingMethodTest,
            description: l10n.onboardingMethodTestDesc,
            icon: Icons.quiz_outlined,
            onTap: onMethodSelected,
          ),
          const SizedBox(height: 12),
          _MethodCard(
            method: 'granular',
            selected: selectedMethod == 'granular',
            title: l10n.onboardingMethodGranular,
            description: l10n.onboardingMethodGranularDesc,
            icon: Icons.tune_outlined,
            onTap: onMethodSelected,
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.selected,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String method;
  final bool selected;
  final String title;
  final String description;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onTap(method),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected ? cs.primaryContainer.withAlpha(60) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? cs.primary : cs.onSurfaceVariant, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: selected ? cs.primary : null,
                            fontWeight: FontWeight.bold,
                          )),
                  Text(description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _TypeGridPage extends StatelessWidget {
  const _TypeGridPage({
    required this.selectedType,
    required this.onTypeSelected,
    required this.l10n,
  });

  final MbtiType? selectedType;
  final ValueChanged<MbtiType> onTypeSelected;
  final AppLocalizations l10n;

  static const _allTypes = [
    MbtiType.intj, MbtiType.intp, MbtiType.entj, MbtiType.entp,
    MbtiType.infj, MbtiType.infp, MbtiType.enfj, MbtiType.enfp,
    MbtiType.istj, MbtiType.istp, MbtiType.estj, MbtiType.estp,
    MbtiType.isfj, MbtiType.isfp, MbtiType.esfj, MbtiType.esfp,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Text(l10n.onboardingSelectType,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: _allTypes.length,
            itemBuilder: (ctx, i) {
              final t = _allTypes[i];
              final sel = t == selectedType;
              return InkWell(
                onTap: () => onTypeSelected(t),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? cs.primary : cs.outlineVariant,
                      width: sel ? 2 : 1,
                    ),
                    color: sel ? cs.primaryContainer : cs.surfaceContainerLow,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sel ? cs.primary : cs.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _GranularPage extends StatelessWidget {
  const _GranularPage({
    required this.dichotomies,
    required this.onChanged,
    required this.l10n,
  });

  final Map<String, double> dichotomies;
  final void Function(String, double) onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.mbtiGranularTitle,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          _DichotomySlider(
            label: l10n.mbtiDichotomyIE,
            leftLabel: 'I',
            rightLabel: 'E',
            value: dichotomies['ie']!,
            onChanged: (v) => onChanged('ie', v),
          ),
          _DichotomySlider(
            label: l10n.mbtiDichotomyNS,
            leftLabel: 'N',
            rightLabel: 'S',
            value: dichotomies['ns']!,
            onChanged: (v) => onChanged('ns', v),
          ),
          _DichotomySlider(
            label: l10n.mbtiDichotomyTF,
            leftLabel: 'T',
            rightLabel: 'F',
            value: dichotomies['tf']!,
            onChanged: (v) => onChanged('tf', v),
          ),
          _DichotomySlider(
            label: l10n.mbtiDichotomyJP,
            leftLabel: 'J',
            rightLabel: 'P',
            value: dichotomies['jp']!,
            onChanged: (v) => onChanged('jp', v),
          ),
        ],
      ),
    );
  }
}

class _DichotomySlider extends StatelessWidget {
  const _DichotomySlider({
    required this.label,
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String leftLabel;
  final String rightLabel;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(leftLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value < 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                )),
            Expanded(
              child: Slider(
                value: value,
                min: -100,
                max: 100,
                divisions: 20,
                onChanged: onChanged,
              ),
            ),
            Text(rightLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value > 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                )),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
