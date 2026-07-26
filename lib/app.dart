import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/person_provider.dart';
import 'presentation/home_shell.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

class ArchetypesApp extends ConsumerWidget {
  const ArchetypesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Archetypes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardedAsync = ref.watch(hasOnboardedProvider);

    return onboardedAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // A real failure of getSelf() (e.g. DB error) must not silently drop the
      // user into the HomeShell as if onboarding were complete: surface it with
      // a retry that re-runs the provider.
      error: (error, _) => _GateError(
        error: error,
        onRetry: () => ref.invalidate(hasOnboardedProvider),
      ),
      data: (onboarded) =>
          onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}

class _GateError extends StatelessWidget {
  const _GateError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.errorGeneric,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
