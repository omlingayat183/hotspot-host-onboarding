import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotspot_host_onboarding/widgets/shared_ui_widgets.dart';
import '../../state/experience_providers.dart';
import '../onboarding/onboarding_question_screen.dart' hide Fx;

class ExperienceScreen extends ConsumerStatefulWidget {
  const ExperienceScreen({super.key});

  @override
  ConsumerState<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends ConsumerState<ExperienceScreen> {
  final _scroll = ScrollController();
  final _titleKey = GlobalKey();
  bool _noteFocused = false;

  @override
  Widget build(BuildContext context) {
    final experiences = ref.watch(experiencesProvider);
    final sel = ref.watch(experienceSelectionProvider);

    final bottomPad =
        20.0 +
        MediaQuery.of(context).viewPadding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Fx.surfaceBlack1,
      body: SafeArea(
        child: Stack(
          children: [
            const WavyBackgroundPattern(angle: -0.40, color: Color(0x0AFFFFFF)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const TopBar(progressFraction: 0.33),

                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '01',
                    style: TextStyle(
                      color: Colors.white12,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .3,
                      height: 1.4,
                    ),
                  ),
                ),

                Padding(
                  key: _titleKey,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: _noteFocused
                        ? Fx.h1(context).copyWith(fontSize: 15)
                        : Fx.h1(context),
                    child: Text(
                      'What kind of experiences do you want to host?',
                      maxLines: _noteFocused ? 1 : 3,
                      overflow: _noteFocused
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 172,
                          child: experiences.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(
                              child: Text('Failed to load: $e', style: Fx.body),
                            ),
                            data: (items) {
                              final sorted = [...items]
                                ..sort((a, b) {
                                  final aSel = sel.selectedIds.contains(a.id);
                                  final bSel = sel.selectedIds.contains(b.id);
                                  if (aSel == bSel) return 0;
                                  return aSel ? -1 : 1;
                                });

                              return ListView.separated(
                                controller: _scroll,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: sorted.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (_, i) {
                                  final exp = sorted[i];
                                  final selected = sel.selectedIds.contains(
                                    exp.id,
                                  );
                                  final angleDeg = [
                                    -6.0,
                                    3.5,
                                    -4.5,
                                    5.5,
                                    -3.0,
                                    2.2,
                                  ][i % 6];

                                  return SizedBox(
                                    width: 156,
                                    child: TiltedStamp(
                                      angleDeg: angleDeg,
                                      selected: selected,
                                      onTap: () {
                                        ref
                                            .read(
                                              experienceSelectionProvider
                                                  .notifier,
                                            )
                                            .toggle(exp.id);
                                        _scroll.animateTo(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 350,
                                          ),
                                          curve: Curves.easeOutCubic,
                                        );
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ColorFiltered(
                                            colorFilter: selected
                                                ? const ColorFilter.mode(
                                                    Colors.transparent,
                                                    BlendMode.dst,
                                                  )
                                                : const ColorFilter.matrix([
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    1,
                                                    0,
                                                  ]),
                                            child: Image.network(
                                              exp.imageUrl ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: Colors.black26,
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(.18),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: NoteField(
                            value: sel.note,
                            hint: '/ Describe your perfect hotspot',
                            onFocusChanged: (v) {
                              setState(() => _noteFocused = v);
                            },
                            onChanged: (v) => ref
                                .read(experienceSelectionProvider.notifier)
                                .setNote(v),
                          ),
                        ),

                        SizedBox(
                          height: 8 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    20 + MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: GlassPrimaryButton(
                    label: 'Next',
                    enabled: true,
                    onTap: () {
                      debugPrint('Selected IDs: ${sel.selectedIds.toList()}');
                      debugPrint('Note (<=250): ${sel.note}');

                      final items = experiences.asData?.value;
                      if (items == null || sel.selectedIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select at least one experience',
                            ),
                          ),
                        );
                        return;
                      }
                      final firstSelectedId = sel.selectedIds.first;
                      final selectedExp = items.firstWhere(
                        (e) => e.id == firstSelectedId,
                        orElse: () => items.first,
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OnboardingQuestionScreen(
                            selectedExperience: selectedExp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
