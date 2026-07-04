import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders a tactical HUD blueprint grid with an animated radar scanning bar.
class BlueprintBackground extends StatefulWidget {
  final Widget child;

  const BlueprintBackground({super.key, required this.child});

  @override
  State<BlueprintBackground> createState() => _BlueprintBackgroundState();
}

class _BlueprintBackgroundState extends State<BlueprintBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweepController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BlueprintPainter(sweepProgress: _sweepController.value),
          child: widget.child,
        );
      },
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final double sweepProgress;

  _BlueprintPainter({required this.sweepProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF121B3A).withOpacity(0.18)
      ..strokeWidth = 0.8;

    final accentPaint = Paint()
      ..color = const Color(0xFF00D2FF).withOpacity(0.08)
      ..strokeWidth = 1.0;

    // 1. Draw Grid Lines
    const double gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Corner Crosshairs (Tech UI markings)
    final double margin = 16.0;
    final double lineLength = 12.0;

    // Top-Left Crosshair
    canvas.drawLine(Offset(margin, margin), Offset(margin + lineLength, margin), accentPaint);
    canvas.drawLine(Offset(margin, margin), Offset(margin, margin + lineLength), accentPaint);

    // Top-Right Crosshair
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - lineLength, margin), accentPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + lineLength), accentPaint);

    // Bottom-Left Crosshair
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + lineLength, size.height - margin), accentPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - lineLength), accentPaint);

    // Bottom-Right Crosshair
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - lineLength, size.height - margin), accentPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - lineLength), accentPaint);

    // 3. Animated Radar Scanning Bar
    final double scanY = size.height * sweepProgress;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D2FF).withOpacity(0.0),
          const Color(0xFF00D2FF).withOpacity(0.15),
          const Color(0xFF00D2FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 60));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 30, size.width, 60), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress;
  }
}

/// A high-tech glassmorphic card container with frosted-glass blur and glowing cyan borders.
class GlassHudCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? borderColor;
  final double borderWidth;
  final double cornerRadius;
  final bool drawTechAccents;

  const GlassHudCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.cornerRadius = 8.0,
    this.drawTechAccents = true,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorderColor = borderColor ?? const Color(0xFF00D2FF);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: drawTechAccents ? _CardCornerAccentsPainter(color: activeBorderColor, radius: cornerRadius) : null,
            child: Container(
              padding: padding ?? const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A142C).withOpacity(0.75),
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(
                  color: activeBorderColor.withOpacity(0.35),
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeBorderColor.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardCornerAccentsPainter extends CustomPainter {
  final Color color;
  final double radius;

  _CardCornerAccentsPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double accentLen = 8.0;

    // Draw little outer angle brackets on corners to give high-tech feeling
    // Top-Left Corner
    Path tlPath = Path()
      ..moveTo(0, accentLen)
      ..lineTo(0, 0)
      ..lineTo(accentLen, 0);
    canvas.drawPath(tlPath, accentPaint);

    // Top-Right Corner
    Path trPath = Path()
      ..moveTo(size.width - accentLen, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, accentLen);
    canvas.drawPath(trPath, accentPaint);

    // Bottom-Left Corner
    Path blPath = Path()
      ..moveTo(0, size.height - accentLen)
      ..lineTo(0, size.height)
      ..lineTo(accentLen, size.height);
    canvas.drawPath(blPath, accentPaint);

    // Bottom-Right Corner
    Path brPath = Path()
      ..moveTo(size.width - accentLen, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - accentLen);
    canvas.drawPath(brPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _CardCornerAccentsPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

/// A rectangular interactive HUD console button with scaling animations and glowing outlines.
class HudButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool isSecondary;

  const HudButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.isSecondary = false,
  });

  @override
  State<HudButton> createState() => _HudButtonState();
}

class _HudButtonState extends State<HudButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? const Color(0xFF00D2FF);
    final textStyle = GoogleFonts.orbitron(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
      color: widget.isSecondary ? baseColor : Colors.black,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) {
          _animController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _animController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: widget.isSecondary
                  ? Colors.transparent
                  : (_isHovered ? baseColor : baseColor.withOpacity(0.85)),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: baseColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(_isHovered ? 0.35 : 0.15),
                  blurRadius: _isHovered ? 12 : 6,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 14,
                    color: widget.isSecondary ? baseColor : Colors.black,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label.toUpperCase(),
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An animated diagnostic style progress bar with glowing neon segments.
class HudProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String valueText;
  final Color? color;
  final double height;

  const HudProgressBar({
    super.key,
    required this.progress,
    required this.label,
    required this.valueText,
    this.color,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFF00D2FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              valueText,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: height + 4,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: activeColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double fillWidth = totalWidth * progress.clamp(0.0, 1.0);

              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          activeColor.withOpacity(0.7),
                          activeColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
