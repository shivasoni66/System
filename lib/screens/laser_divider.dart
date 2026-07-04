import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class LaserDivider extends StatelessWidget {
  final double height;
  final double thickness;

  const LaserDivider({
    super.key,
    this.height = 16.0,
    this.thickness = 1.5,
  });

  Color _getThemePrimaryColor(int themeIdx) {
    switch (themeIdx) {
      case 1:
        return const Color(0xFF00B0FF); // Deep Ocean
      case 2:
        return const Color(0xFF18FFFF); // Electric Cyan
      case 3:
        return const Color(0xFF448AFF); // Sapphire Knight
      case 4:
        return const Color(0xFF80D8FF); // Neon Ice
      default:
        return const Color(0xFF00E5FF); // Midnight Cobalt
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final primaryColor = _getThemePrimaryColor(provider.activeThemeIndex);

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        height: thickness,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor,
              blurRadius: 6,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.0),
              primaryColor.withOpacity(0.3),
              primaryColor,
              primaryColor,
              primaryColor.withOpacity(0.3),
              primaryColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.15, 0.4, 0.6, 0.85, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
