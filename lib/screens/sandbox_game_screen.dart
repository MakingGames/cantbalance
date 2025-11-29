import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../game/sandbox_game.dart';
import '../game/sandbox_challenges.dart';
import '../services/dev_mode_service.dart';
import '../services/orientation_service.dart';
import '../utils/colors.dart';
import 'game_hud.dart';

/// Sandbox mode screen with challenge toggles
class SandboxGameScreen extends StatefulWidget {
  const SandboxGameScreen({super.key});

  @override
  State<SandboxGameScreen> createState() => _SandboxGameScreenState();
}

class _SandboxGameScreenState extends State<SandboxGameScreen> {
  late SandboxGame _game;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _showChallengePanel = false;
  SandboxChallenges _challenges = SandboxChallenges();

  @override
  void initState() {
    super.initState();
    _game = SandboxGame();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final tilt = OrientationService.instance.getAdjustedTilt(event.x, event.y);
      _game.updateBeamFromTilt(tilt);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _updateChallenges(SandboxChallenges newChallenges) {
    setState(() {
      _challenges = newChallenges;
    });
    _game.updateChallenges(newChallenges);
  }

  @override
  Widget build(BuildContext context) {
    return GameHUD(
      gameWidget: GameWidget(
        game: _game,
        backgroundBuilder: (context) => Container(
          color: GameColors.background,
        ),
      ),
      onBack: () => Navigator.of(context).pop(),
      showDevToggle: DevModeService.instance.isDevMode,
      isDevPanelOpen: _showChallengePanel,
      onDevToggle: () {
        setState(() {
          _showChallengePanel = !_showChallengePanel;
        });
      },
      devPanel: _SandboxChallengePanel(
        challenges: _challenges,
        onChallengesChanged: _updateChallenges,
      ),
      onDismissDevPanel: () {
        if (_showChallengePanel) {
          setState(() {
            _showChallengePanel = false;
          });
        }
      },
    );
  }
}

/// Challenge panel for sandbox mode
class _SandboxChallengePanel extends StatelessWidget {
  final SandboxChallenges challenges;
  final void Function(SandboxChallenges) onChallengesChanged;

  const _SandboxChallengePanel({
    required this.challenges,
    required this.onChallengesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameColors.beam.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'HAZARDS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: GameColors.beam.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          // Tilt Control with sliders
          _ChallengeToggle(
            label: 'Tilt Control',
            tooltip: 'Phone accelerometer controls beam',
            value: challenges.tiltControl,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(tiltControl: v)),
          ),
          if (challenges.tiltControl) ...[
            _ChallengeSlider(
              label: 'Strength',
              value: challenges.tiltStrength,
              min: SandboxChallenges.tiltStrengthMin,
              max: SandboxChallenges.tiltStrengthMax,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(tiltStrength: v)),
            ),
            _ChallengeSlider(
              label: 'Sensitivity',
              value: challenges.tiltSensitivity,
              min: SandboxChallenges.tiltSensitivityMin,
              max: SandboxChallenges.tiltSensitivityMax,
              decimals: 2,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(tiltSensitivity: v)),
            ),
            _ChallengeSlider(
              label: 'Damping',
              value: challenges.beamDamping,
              min: SandboxChallenges.beamDampingMin,
              max: SandboxChallenges.beamDampingMax,
              decimals: 1,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(beamDamping: v)),
            ),
            _SubToggle(
              label: 'Inverted',
              value: challenges.tiltInverted,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(tiltInverted: v)),
            ),
          ],
          // Wind with slider
          _ChallengeToggle(
            label: 'Wind Gusts',
            tooltip: 'Random wind pushes shapes',
            value: challenges.windGusts,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(windGusts: v)),
          ),
          if (challenges.windGusts)
            _ChallengeSlider(
              label: 'Wind Force',
              value: challenges.windStrength,
              min: SandboxChallenges.windStrengthMin,
              max: SandboxChallenges.windStrengthMax,
              decimals: 1,
              suffix: 'x',
              onChanged: (v) => onChallengesChanged(challenges.copyWith(windStrength: v)),
            ),
          // Gravity with slider
          _ChallengeToggle(
            label: 'Heavy Gravity',
            tooltip: 'Increased gravity',
            value: challenges.heavyGravity,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(heavyGravity: v)),
          ),
          if (challenges.heavyGravity)
            _ChallengeSlider(
              label: 'Gravity',
              value: challenges.gravityMultiplier,
              min: SandboxChallenges.gravityMin,
              max: SandboxChallenges.gravityMax,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(gravityMultiplier: v)),
            ),
          // Slippery beam with slider
          _ChallengeToggle(
            label: 'Slippery Beam',
            tooltip: 'Adjust beam friction',
            value: challenges.slipperyBeam,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(slipperyBeam: v)),
          ),
          if (challenges.slipperyBeam)
            _ChallengeSlider(
              label: 'Friction',
              value: challenges.beamFriction,
              min: SandboxChallenges.beamFrictionMin,
              max: SandboxChallenges.beamFrictionMax,
              decimals: 1,
              onChanged: (v) => onChallengesChanged(challenges.copyWith(beamFriction: v)),
            ),
          // Simple toggles (no sliders)
          _ChallengeToggle(
            label: 'Beam Instability',
            tooltip: 'Random torque nudges beam',
            value: challenges.beamInstability,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(beamInstability: v)),
          ),
          _ChallengeToggle(
            label: 'Shape Variety',
            tooltip: 'Spawn circles and triangles',
            value: challenges.shapeVariety,
            onChanged: (v) => onChallengesChanged(challenges.copyWith(shapeVariety: v)),
          ),
        ],
      ),
    );
  }
}

class _ChallengeSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final String suffix;
  final void Function(double) onChanged;

  const _ChallengeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.decimals = 0,
    this.suffix = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: GameColors.beam.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${value.toStringAsFixed(decimals)}$suffix',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: GameColors.beam.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: GameColors.beam.withValues(alpha: 0.6),
                inactiveTrackColor: GameColors.beam.withValues(alpha: 0.2),
                thumbColor: GameColors.beam,
                overlayColor: GameColors.beam.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubToggle extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _SubToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: value
                    ? GameColors.beam.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: value
                      ? GameColors.beam
                      : GameColors.beam.withValues(alpha: 0.4),
                  width: value ? 1.5 : 1,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 10,
                      color: GameColors.beam,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: value
                    ? GameColors.beam.withValues(alpha: 0.8)
                    : GameColors.beam.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeToggle extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool value;
  final void Function(bool) onChanged;

  const _ChallengeToggle({
    required this.label,
    required this.tooltip,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      textStyle: TextStyle(
        fontSize: 12,
        color: GameColors.background,
      ),
      decoration: BoxDecoration(
        color: GameColors.beam,
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value
                      ? GameColors.beam.withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: value
                        ? GameColors.beam
                        : GameColors.beam.withValues(alpha: 0.4),
                    width: value ? 2 : 1,
                  ),
                ),
                child: value
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: GameColors.beam,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: value
                      ? GameColors.beam
                      : GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
