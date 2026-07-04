import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/hud_components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _chosenClass = 'Self Improver';

  final List<String> _classes = [
    'Self Improver',
    'Scholar',
    'Warrior',
    'Code Architect',
    'Willpower Specialist',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    const primaryColor = Color(0xFF00D2FF); // Neon Cyan

    return BlueprintBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassHudCard(
              borderColor: primaryColor,
              padding: const EdgeInsets.all(24.0),
              cornerRadius: 12.0,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Glowing HUD Scan Circle
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 38,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SYSTEM ENLISTMENT PROTOCOL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'IDENTIFICATION MATRIX REQUIRED FOR CORE OPERATIONS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // User Name Field
                    TextFormField(
                      style: GoogleFonts.exo2(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'ENTER PLAYER ID / NAME',
                        labelStyle: GoogleFonts.orbitron(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                        prefixIcon: const Icon(Icons.person, color: primaryColor, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.2), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: primaryColor, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Identification required.';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters.';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value!.trim(),
                    ),
                    const SizedBox(height: 20),

                    // Class Dropdown
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF0A0F24),
                      value: _chosenClass,
                      decoration: InputDecoration(
                        labelText: 'SELECT SPECIALIZATION CLASS',
                        labelStyle: GoogleFonts.orbitron(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                        prefixIcon: const Icon(Icons.shield_moon_outlined, color: primaryColor, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.2), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      items: _classes.map((cls) {
                        return DropdownMenuItem(
                          value: cls,
                          child: Text(
                            cls.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _chosenClass = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 28),

                    // Action Button
                    HudButton(
                      label: 'INITIALIZE SYSTEM PROTOCOL',
                      color: primaryColor,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          
                          // Initialize profile
                          provider.initializePlayerProfile(_name, _chosenClass);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
