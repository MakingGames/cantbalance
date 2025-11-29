import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/stacking_game.dart';
import '../game/stacking_physics.dart';
import '../game/shape_size.dart';
import '../game/shape_type.dart';
import '../services/dev_mode_service.dart';
import '../utils/colors.dart';
import 'game_hud.dart';
import 'shape_picker.dart';

/// Stacking mode screen - infinite vertical stacking
class StackingGameScreen extends StatefulWidget {
  const StackingGameScreen({super.key});

  @override
  State<StackingGameScreen> createState() => _StackingGameScreenState();
}

class _StackingGameScreenState extends State<StackingGameScreen> {
  late StackingGame _game;
  bool _showGameOver = false;
  int _score = 0;
  double _height = 0;
  ShapeSize _selectedShapeSize = ShapeSize.medium;
  GameShapeType _nextShapeType = GameShapeType.square;
  bool _showTestPanel = false;
  StackingPhysics _physics = StackingPhysics();

  @override
  void initState() {
    super.initState();
    _createNewGame();
  }

  void _createNewGame() {
    _game = StackingGame(
      onGameOver: (score) {
        HapticFeedback.mediumImpact();
        _safeSetState(() {
          _showGameOver = true;
          _score = score;
        });
      },
      onScoreChanged: (score) {
        _safeSetState(() {
          _score = score;
        });
      },
      onHeightChanged: (height) {
        _safeSetState(() {
          _height = height;
        });
      },
      onNextShapeChanged: (nextShape) {
        _safeSetState(() {
          _nextShapeType = nextShape;
        });
      },
      onShapePlaced: () {
        HapticFeedback.lightImpact();
      },
    );
  }

  /// Safe setState that defers to post-frame if called during build
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  void _onShapeSizeChanged(ShapeSize size) {
    setState(() {
      _selectedShapeSize = size;
    });
    _game.selectShapeSize(size);
  }

  void _updatePhysics(StackingPhysics newPhysics) {
    setState(() {
      _physics = newPhysics;
    });
    _game.updatePhysics(newPhysics);
  }

  void _restart() {
    setState(() {
      _showGameOver = false;
      _score = 0;
      _height = 0;
      _selectedShapeSize = ShapeSize.medium;
      _createNewGame();
    });
    // Re-apply physics settings to new game
    _game.updatePhysics(_physics);
  }

  @override
  Widget build(BuildContext context) {
    return GameHUD(
      gameWidget: GameWidget(
        key: ValueKey(_game.hashCode),
        game: _game,
        backgroundBuilder: (context) => Container(
          color: GameColors.background,
        ),
      ),
      onBack: () => Navigator.of(context).pop(),
      showDevToggle: DevModeService.instance.isDevMode,
      isDevPanelOpen: _showTestPanel,
      onDevToggle: () {
        setState(() {
          _showTestPanel = !_showTestPanel;
        });
      },
      devPanel: _PhysicsTestPanel(
        physics: _physics,
        onPhysicsChanged: _updatePhysics,
      ),
      onDismissDevPanel: () {
        if (_showTestPanel) {
          setState(() {
            _showTestPanel = false;
          });
        }
      },
      showHUD: !_showGameOver,
      centerContent: Column(
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: GameColors.beam.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          _NextShapePreview(shapeType: _nextShapeType),
        ],
      ),
      rightContent: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_height.toStringAsFixed(1)}m',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w200,
              letterSpacing: 4,
              color: GameColors.beam.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '$_score shapes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: GameColors.beam.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      bottomContent: ShapePicker(
        selectedSize: _selectedShapeSize,
        onSizeChanged: _onShapeSizeChanged,
      ),
      overlays: [
        if (_showGameOver)
          _StackingGameOverOverlay(
            score: _score,
            height: _height,
            onRestart: _restart,
            onMenu: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}

/// Test panel for physics settings
class _PhysicsTestPanel extends StatelessWidget {
  final StackingPhysics physics;
  final void Function(StackingPhysics) onPhysicsChanged;

  const _PhysicsTestPanel({
    required this.physics,
    required this.onPhysicsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'HELPERS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: GameColors.beam.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          _PhysicsToggle(
            label: 'High Friction',
            tooltip: 'Shapes grip each other better\n(friction: 2.0 vs 0.8)',
            value: physics.highFriction,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(highFriction: v)),
          ),
          _PhysicsToggle(
            label: 'High Damping',
            tooltip: 'Shapes settle faster, less sliding\n(linear: 2.0, angular: 3.0)',
            value: physics.highDamping,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(highDamping: v)),
          ),
          _PhysicsToggle(
            label: 'Magnetic',
            tooltip: 'Shapes attract when close\n(range: 1.5 units)',
            value: physics.magneticAttraction,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(magneticAttraction: v)),
          ),
          _PhysicsToggle(
            label: 'Sticky (Velcro)',
            tooltip: 'Very high friction for max grip\n(friction: 5.0)',
            value: physics.stickyContacts,
            onChanged: (v) => onPhysicsChanged(physics.copyWith(stickyContacts: v)),
          ),
        ],
      ),
    );
  }
}

class _PhysicsToggle extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool value;
  final void Function(bool) onChanged;

  const _PhysicsToggle({
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

class _StackingGameOverOverlay extends StatelessWidget {
  final int score;
  final double height;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _StackingGameOverOverlay({
    required this.score,
    required this.height,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TOWER COLLAPSED',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '${height.toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 4,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score SHAPES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.home,
                    label: 'MENU',
                    onTap: onMenu,
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.refresh,
                    label: 'RETRY',
                    onTap: onRestart,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? GameColors.beam.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isPrimary
                ? GameColors.beam
                : GameColors.beam.withValues(alpha: 0.4),
            width: isPrimary ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? GameColors.beam
                  : GameColors.beam.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
                color: isPrimary
                    ? GameColors.beam
                    : GameColors.beam.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview widget for the next shape in stacking mode
class _NextShapePreview extends StatelessWidget {
  final GameShapeType shapeType;

  const _NextShapePreview({required this.shapeType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: GameColors.beam.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20, 20),
          painter: _ShapePreviewPainter(shapeType: shapeType),
        ),
      ),
    );
  }
}

class _ShapePreviewPainter extends CustomPainter {
  final GameShapeType shapeType;

  _ShapePreviewPainter({required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.shapeMedium
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final halfSize = size.width / 2 - 2;

    switch (shapeType) {
      case GameShapeType.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: halfSize * 1.6, height: halfSize * 1.6),
            const Radius.circular(2),
          ),
          paint,
        );
      case GameShapeType.circle:
        canvas.drawCircle(center, halfSize * 0.85, paint);
      case GameShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - halfSize * 0.9)
          ..lineTo(center.dx - halfSize * 0.9, center.dy + halfSize * 0.7)
          ..lineTo(center.dx + halfSize * 0.9, center.dy + halfSize * 0.7)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ShapePreviewPainter oldDelegate) {
    return oldDelegate.shapeType != shapeType;
  }
}
