import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class Fx {
  // Colors
  static const Color bg = Color(0xFF101010);
  static const Color surfaceBlack1 = Color(0xFF101010);
  static const Color text1 = Colors.white;
  static const Color text2 = Color(0xB3FFFFFF); // 70%
  static const Color text3 = Color(0x7AFFFFFF); // 48%
  static const Color hint = Color(0x3DFFFFFF); // 24%
  static const Color primaryAccent = Color(0xFF9196FF);
  static const Color secondaryAccent = Color(0xFF596FFF);
  static const Color glassStroke = Color(0x33FFFFFF);

  // Radii
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;

  // Typography helper (uses app theme where possible)
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

/// Glassy primary button used across the app.
class GlassPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const GlassPrimaryButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = enabled
        ? LinearGradient(
            colors: [
              Colors.white.withOpacity(.08),
              Colors.white.withOpacity(.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withOpacity(.04),
              Colors.white.withOpacity(.02),
            ],
          );
    final border = enabled
        ? Colors.white.withOpacity(.20)
        : Colors.white.withOpacity(.10);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: bg,
          borderRadius: BorderRadius.circular(Fx.r20),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.18),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: const Alignment(0, .4),
                    ),
                    borderRadius: BorderRadius.circular(Fx.r20),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: enabled
                        ? Colors.white
                        : Colors.white.withOpacity(.4),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.navigate_next,
                  size: 20,
                  color: enabled ? Colors.white : Colors.white.withOpacity(.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Top bar + squiggle ----------------
class TopBar extends StatelessWidget {
  /// progress fraction 0..1
  final double progressFraction;
  const TopBar({Key? key, this.progressFraction = 0.33}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          ContinuousWavyProgress(activeFraction: progressFraction),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class ContinuousWavyProgress extends StatelessWidget {
  final double activeFraction;
  const ContinuousWavyProgress({Key? key, required this.activeFraction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 8),
      painter: _ContinuousSquigglePainter(activeFraction: activeFraction),
    );
  }
}

class _ContinuousSquigglePainter extends CustomPainter {
  final double activeFraction;
  _ContinuousSquigglePainter({required this.activeFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final amp = size.height / 2.3;
    const cycles = 6.0;

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height / 2 +
          math.sin(x / size.width * cycles * math.pi * 2) * amp;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final activeWidth = (activeFraction.clamp(0.0, 1.0)) * size.width;
    final activeShader =
        const LinearGradient(
          colors: [Fx.primaryAccent, Fx.secondaryAccent],
        ).createShader(
          Rect.fromLTWH(0, 0, activeWidth == 0 ? 1 : activeWidth, size.height),
        );

    final inactiveShader =
        LinearGradient(
          colors: [
            Colors.white.withOpacity(.18),
            Colors.white.withOpacity(.18),
          ],
        ).createShader(
          Rect.fromLTWH(
            activeWidth,
            0,
            (size.width - activeWidth) == 0 ? 1 : (size.width - activeWidth),
            size.height,
          ),
        );

    final activePaint = Paint()
      ..shader = activeShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..shader = inactiveShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Draw active segment
    final activePath = Path();
    for (double x = 0; x <= activeWidth; x++) {
      final y =
          size.height / 2 +
          math.sin(x / size.width * cycles * math.pi * 2) * amp;
      if (x == 0) {
        activePath.moveTo(x, y);
      } else {
        activePath.lineTo(x, y);
      }
    }
    canvas.drawPath(activePath, activePaint);

    // Draw inactive segment
    final inactivePath = Path();
    for (double x = activeWidth; x <= size.width; x++) {
      final y =
          size.height / 2 +
          math.sin(x / size.width * cycles * math.pi * 2) * amp;
      if (x == activeWidth) {
        inactivePath.moveTo(x, y);
      } else {
        inactivePath.lineTo(x, y);
      }
    }
    canvas.drawPath(inactivePath, inactivePaint);
  }

  @override
  bool shouldRepaint(covariant _ContinuousSquigglePainter oldDelegate) =>
      oldDelegate.activeFraction != activeFraction;
}

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  final int maxLength;

  const GlassTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.focusNode,
    this.minLines = 4,
    this.maxLines = 6,
    this.maxLength = 600,
  }) : super(key: key);

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late FocusNode _internalFocus;
  FocusNode get _focus => widget.focusNode ?? _internalFocus;
  bool get _hasExternalFocusNode => widget.focusNode != null;

  @override
  void initState() {
    super.initState();
    _internalFocus = FocusNode();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant GlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      if (!_hasExternalFocusNode) {
        _internalFocus = _internalFocus; 
      }
      _focus.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    if (!_hasExternalFocusNode) {
      _internalFocus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focus.hasFocus
        ? Fx.primaryAccent.withOpacity(.55)
        : Colors.white.withOpacity(.18);

    return TextField(
      focusNode: _focus,
      controller: widget.controller,
      onChanged: widget.onChanged,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      style: const TextStyle(fontSize: 20, color: Colors.white, height: 1.3),
      cursorColor: Fx.primaryAccent,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hint,
        hintStyle: Fx.hintStyle,
        filled: true,
        fillColor: Colors.white.withOpacity(.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Fx.r20),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Fx.r20),
          borderSide: BorderSide(color: Fx.primaryAccent, width: 1.2),
        ),
      ),
    );
  }
}

/// Tilted stamp widget.
class TiltedStamp extends StatelessWidget {
  final double angleDeg;
  final bool selected;
  final Widget child;
  final VoidCallback? onTap;

  const TiltedStamp({
    Key? key,
    required this.angleDeg,
    required this.child,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final angle = (angleDeg * math.pi) / 180.0;
    final m = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateZ(angle);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: m,
        transformAlignment: Alignment.center,
        margin: EdgeInsets.only(
          top: selected ? 0 : 6,
          bottom: selected ? 6 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Fx.r12),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Fx.primaryAccent.withOpacity(.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Fx.r12),
          child: child,
        ),
      ),
    );
  }
}

/// Recording card that shows a waveform and basic controls.
class RecordingCard extends StatelessWidget {
  final RecorderController waveController;
  final String timerText;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  const RecordingCard({
    Key? key,
    required this.waveController,
    required this.timerText,
    required this.onCancel,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Fx.r20),
        border: Border.all(color: Fx.glassStroke),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.08),
            Colors.white.withOpacity(.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recording Audio...',
            style: TextStyle(
              color: Fx.text1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Fx.primaryAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Fx.primaryAccent.withOpacity(.35),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: AudioWaveforms(
                    enableGesture: false,
                    size: const Size(double.infinity, 52),
                    recorderController: waveController,
                    waveStyle: WaveStyle(
                      waveThickness: 3,
                      showMiddleLine: false,
                      extendWaveform: true,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ).createShader(const Rect.fromLTWH(0, 0, 260, 52)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                timerText,
                style: const TextStyle(
                  color: Fx.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassChipButton(
                  icon: Icons.close,
                  label: 'Cancel',
                  onTap: onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassPrimaryButton(label: 'Stop & Save', onTap: onStop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassChipButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Fx.r16),
          border: Border.all(color: Colors.white.withOpacity(.18)),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(.06),
              Colors.white.withOpacity(.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple media chip to show recorded audio/video with a delete action.
class MediaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onDelete;

  const MediaChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Fx.r20),
        border: Border.all(color: Fx.glassStroke),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.08),
            Colors.white.withOpacity(.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

/// NoteField keeps its own controller + focus behaviour (matches ExperienceScreen).
class NoteField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onFocusChanged;

  const NoteField({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.onFocusChanged,
  }) : super(key: key);

  @override
  State<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<NoteField> {
  late final TextEditingController _c;
  late final FocusNode _f;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.value);
    _f = FocusNode()
      ..addListener(() {
        setState(() {});
        widget.onFocusChanged?.call(_f.hasFocus);
      });
  }

  @override
  void didUpdateWidget(covariant NoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _c.text) {
      _c.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _f.hasFocus
        ? Fx.primaryAccent.withOpacity(.55)
        : Colors.white.withOpacity(.18);

    return TextField(
      focusNode: _f,
      controller: _c,
      onChanged: widget.onChanged,
      maxLength: 250,
      minLines: 4,
      maxLines: 6,
      style: const TextStyle(fontSize: 20, color: Colors.white, height: 1.3),
      cursorColor: Fx.primaryAccent,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hint,
        hintStyle: Fx.hintStyle,
        filled: true,
        fillColor: Colors.white.withOpacity(.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Fx.r20),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Fx.r20),
          borderSide: BorderSide(color: Fx.primaryAccent, width: 1.2),
        ),
      ),
    );
  }
}

class WavyBackgroundPattern extends StatelessWidget {
  final double angle;
  final Color color;

  const WavyBackgroundPattern({
    Key? key,
    this.angle = -0.40,
    this.color = const Color(0x1AFFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavyBgPainter(angle: angle, paintColor: color),
      size: Size.infinite,
    );
  }
}

class _WavyBgPainter extends CustomPainter {
  final double angle;
  final Color paintColor;

  _WavyBgPainter({required this.angle, required this.paintColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double extraCover = 220.0;
    final paint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const spacing = 82.0;
    const waveH = 16.0;
    final path = Path();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2);

    final startY = 120.0 - extraCover;
    final endY = size.height + extraCover;
    for (double y = startY; y < endY; y += spacing) {
      path.reset();
      for (double x = -200; x < size.width + 200; x += 28) {
        final up = ((x / 28).floor() % 2) == 0;
        final p1 = Offset(x, y + (up ? -waveH : waveH));
        final p2 = Offset(x + 28, y + (up ? waveH : -waveH));
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WavyBgPainter oldDelegate) => false;
}
