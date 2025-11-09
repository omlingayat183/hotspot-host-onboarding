// lib/state/experience_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/services/experience_service.dart';
import '../data/models/experience.dart';

final experienceServiceProvider = Provider((ref) => ExperienceService());

final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  return ref.read(experienceServiceProvider).getExperiences();
});

// Holds selected ids + the 250-char note
class ExperienceSelectionState {
  final Set<int> selectedIds;
  final String note;
  const ExperienceSelectionState({this.selectedIds = const {}, this.note = ''});

  ExperienceSelectionState copyWith({Set<int>? selectedIds, String? note}) =>
      ExperienceSelectionState(
        selectedIds: selectedIds ?? this.selectedIds,
        note: note ?? this.note,
      );
}

final experienceSelectionProvider =
    StateNotifierProvider<ExperienceSelectionNotifier, ExperienceSelectionState>(
        (ref) => ExperienceSelectionNotifier());

class ExperienceSelectionNotifier extends StateNotifier<ExperienceSelectionState> {
  ExperienceSelectionNotifier() : super(const ExperienceSelectionState());

  void toggle(int id) {
    final set = {...state.selectedIds};
    if (set.contains(id)) set.remove(id); else set.add(id);
    state = state.copyWith(selectedIds: set);
  }

  void setNote(String v) {
    state = state.copyWith(note: v);
  }

  void clear() => state = const ExperienceSelectionState();
}
