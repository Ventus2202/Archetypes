import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/team/team_models.dart';
import '../../domain/team/team_optimizer.dart';
import '../../domain/entities/person.dart';
import '../../domain/personality_systems/mbti/mbti_profile.dart';
import 'database_provider.dart';

class TeamOptimizerState {
  final Set<int> selectedPersonIds;
  final TeamObjective objective;
  final int teamSize;
  final List<TeamComposition>? results;
  final bool isLoading;

  const TeamOptimizerState({
    this.selectedPersonIds = const {},
    this.objective = TeamObjective.creative,
    this.teamSize = 3,
    this.results,
    this.isLoading = false,
  });

  TeamOptimizerState copyWith({
    Set<int>? selectedPersonIds,
    TeamObjective? objective,
    int? teamSize,
    List<TeamComposition>? results,
    bool? isLoading,
    bool clearResults = false,
  }) {
    return TeamOptimizerState(
      selectedPersonIds: selectedPersonIds ?? this.selectedPersonIds,
      objective: objective ?? this.objective,
      teamSize: teamSize ?? this.teamSize,
      results: clearResults ? null : (results ?? this.results),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TeamOptimizerNotifier extends Notifier<TeamOptimizerState> {
  @override
  TeamOptimizerState build() => const TeamOptimizerState();

  void togglePerson(int id) {
    final current = state.selectedPersonIds;
    final updated = Set<int>.from(current);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedPersonIds: updated, clearResults: true);
  }

  void setObjective(TeamObjective objective) {
    state = state.copyWith(objective: objective, clearResults: true);
  }

  void setTeamSize(int size) {
    state = state.copyWith(teamSize: size, clearResults: true);
  }

  Future<void> calculate() async {
    if (state.selectedPersonIds.length < state.teamSize) return;

    state = state.copyWith(isLoading: true);

    final candidates = <({Person person, MbtiProfile profile})>[];
    final personRepo = ref.read(personRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    for (final id in state.selectedPersonIds) {
      final person = await personRepo.getById(id);
      if (person != null) {
        final profiles = await profileRepo.getForPerson(id);
        final mbtiRaw = profiles.where((p) => p.system.name == 'mbti').firstOrNull;
        if (mbtiRaw != null) {
          try {
            final mbtiProfile = MbtiProfile.fromJson(Map<String, dynamic>.from(mbtiRaw.data));
            candidates.add((person: person, profile: mbtiProfile));
          } catch (_) {}
        }
      }
    }

    // Optimization is sync but could be heavy.
    final results = TeamOptimizer.findBest(
      candidates: candidates,
      objective: state.objective,
      teamSize: state.teamSize,
    );

    state = state.copyWith(isLoading: false, results: results);
  }
}

final teamOptimizerProvider = NotifierProvider<TeamOptimizerNotifier, TeamOptimizerState>(
  TeamOptimizerNotifier.new,
);
