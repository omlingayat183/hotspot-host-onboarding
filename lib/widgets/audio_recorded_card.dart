import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Fx {
  // Colors
  static const Color bg = Color(0xFF101010);
  static const Color text1 = Colors.white;
  static const Color text2 = Color(0xB3FFFFFF); // 70%
  static const Color text3 = Color(0x7AFFFFFF); // 48%
  static const Color hint = Color(0x3DFFFFFF); // 24%
  static const Color primaryAccent = Color(0xFF9196FF);
  static const Color secondaryAccent = Color(0xFF596FFF);
  static const Color glassStroke = Color(0x33FFFFFF);

  // Radii
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;

  // Typography (kept small here)
  static TextStyle h1(BuildContext ctx) =>
      Theme.of(ctx).textTheme.displaySmall?.copyWith(
            color: text1,
            fontWeight: FontWeight.w700,
            fontSize: 34,
            height: 1.06,
            letterSpacing: -0.3,
          ) ??
      const TextStyle(
        color: text1,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        height: 1.06,
        letterSpacing: -0.3,
      );

  static const body = TextStyle(fontSize: 16, color: text1);
  static const bodyDim = TextStyle(fontSize: 16, color: text3);
  static const hintStyle = TextStyle(fontSize: 18, color: hint);
}

class AudioRecordedCard extends StatefulWidget {
  final String filePath; 
  final Future<void> Function() onDelete;
  final VoidCallback? onTap;

  const AudioRecordedCard({
    required this.filePath,
    required this.onDelete,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioRecordedCard> createState() => AudioRecordedCardState();
}

class AudioRecordedCardState extends State<AudioRecordedCard>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  bool _playing = false;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    try {
      await _player.setFilePath(widget.filePath);
      _duration = _player.duration ?? Duration.zero;
      _posSub = _player.positionStream.listen((p) {
        setState(() => _position = p);
      });
      _stateSub = _player.playerStateStream.listen((ps) {
        final playing = ps.playing;
        setState(() {
          _playing = playing;
          if (playing) {
            _animController.repeat(reverse: true);
          } else {
            _animController.stop();
          }
        });
      });
      setState(() {});
    } catch (e) {
      debugPrint('Audio load error: $e');
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _animController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_position >= (_duration - const Duration(milliseconds: 200))) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 14;
    const double playSize = 44;

    final bg = Colors.white.withOpacity(.03);
    final border = Colors.white.withOpacity(.06);

    final durationText = _duration > Duration.zero ? _format(_duration) : '--:--';
    final progress = _duration > Duration.zero
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Audio Recorded',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(durationText, style: TextStyle(color: Colors.white.withOpacity(.6))),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Fx.primaryAccent,
                onPressed: () async {
                  debugPrint('[AudioRecordedCard] delete pressed for ${widget.filePath}');
                  try {
                    if (_player.playing) {
                      await _player.stop();
                      debugPrint('[AudioRecordedCard] player stopped');
                    }
                  } catch (e, st) {
                    debugPrint('[AudioRecordedCard] error stopping player: $e\n$st');
                  }

                  try {
                    await _player.dispose();
                    debugPrint('[AudioRecordedCard] player disposed');
                  } catch (e, st) {
                    debugPrint('[AudioRecordedCard] error disposing player: $e\n$st');
                  }

                  try {
                    await widget.onDelete();
                    debugPrint('[AudioRecordedCard] onDelete() awaited and completed');
                    if (mounted) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Audio deleted')));
                    }
                  } catch (e, st) {
                    debugPrint('[AudioRecordedCard] onDelete threw: $e\n$st');
                    if (mounted) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Failed to delete audio')));
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: playSize,
                    height: playSize,
                    decoration: BoxDecoration(color: Fx.primaryAccent, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 22),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      _WaveformMock(barCount: 38, preferredBarWidth: 6, spacing: 6),
                      LayoutBuilder(builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: SizedBox(
                              width: w,
                              child: _WaveformMock(barCount: 38, preferredBarWidth: 6, spacing: 6, active: true, animation: _animController),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _WaveformMock extends StatelessWidget {
  final int barCount;
  final double preferredBarWidth;
  final double spacing;
  final bool active;
  final AnimationController? animation;

  const _WaveformMock({
    this.barCount = 38,
    this.preferredBarWidth = 6,
    this.spacing = 6,
    this.active = false,
    this.animation,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final totalSpacing = (barCount - 1) * spacing;

        final fudge = 1.5;
        final availForBars = (maxW - totalSpacing - fudge).clamp(
          0.0,
          double.infinity,
        );

        final responsiveBarWidth = barCount > 0
            ? (availForBars / barCount)
            : preferredBarWidth;

        final minBarWidth = 1.5;

        final barWidth = responsiveBarWidth.clamp(
          minBarWidth,
          preferredBarWidth,
        );

        final bars = List.generate(barCount, (i) {
          final base = (1 + (i % 7)) / 8.0;
          final alt = ((i * 37) % 100) / 100.0;
          return (base * 0.6 + alt * 0.4).clamp(0.12, 1.0);
        });

        return SizedBox(
          height: 52,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < bars.length; i++) ...[
                _WaveBar(
                  width: barWidth,
                  heightFactor: bars[i],
                  active: active,
                  animation: animation,
                  index: i,
                ),
                if (i != bars.length - 1) SizedBox(width: spacing),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WaveBar extends StatelessWidget {
  final double width;
  final double heightFactor;
  final bool active;
  final AnimationController? animation;
  final int index;

  const _WaveBar({
    required this.width,
    required this.heightFactor,
    required this.active,
    this.animation,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.white.withOpacity(.22);
    const maxBarHeight = 42.0;

    if (animation == null) {
      return Container(
        width: width,
        height: maxBarHeight * heightFactor,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
      );
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (_, __) {
        final t = (animation!.value + (index % 5) * 0.12) % 1.0;
        final animFactor =
            0.6 + (0.4 * (0.5 + 0.5 * math.sin((t * 2 * math.pi))));
        final h = (heightFactor * animFactor).clamp(0.12, 1.0);
        return Container(
          width: width,
          height: maxBarHeight * h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}