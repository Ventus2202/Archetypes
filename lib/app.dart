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
      error: (error, _) => const HomeShell(),
      data: (onboarded) =>
          onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
