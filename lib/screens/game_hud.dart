import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

/// Universal game HUD that provides consistent layout across all game screens.
///
/// Features:
/// - Back button (always present, top-left)
/// - Optional dev mode toggle and panel (below back button)
/// - Optional left-side indicators (wind, timer, etc.)
/// - Optional right-side content (score, next shape, etc.)
/// - Bottom content slot (shape picker, etc.)
/// - Tap-outside-to-dismiss for dev panels
class GameHUD extends StatelessWidget {
  /// The Flame game widget to display
  final Widget gameWidget;

  /// Called when back button is pressed
  final VoidCallback onBack;

  /// Whether to show the dev mode toggle button
  final bool showDevToggle;

  /// Whether the dev panel is currently visible
  final bool isDevPanelOpen;

  /// Called when dev toggle is pressed
  final VoidCallback? onDevToggle;

  /// The dev panel widget to show when open
  final Widget? devPanel;

  /// Called when tapping outside the dev panel (to dismiss)
  final VoidCallback? onDismissDevPanel;

  /// Left-side indicators (wind, hazards, etc.) - shown below dev panel or back button
  final List<Widget> leftIndicators;

  /// Right-side content (score, height, next shape, etc.)
  final Widget? rightContent;

  /// Center content (level info, etc.)
  final Widget? centerContent;

  /// Bottom content (shape picker, etc.)
  final Widget? bottomContent;

  /// Whether to show the HUD elements (false during game over, etc.)
  final bool showHUD;

  /// Overlay widgets (game over screen, level complete, etc.)
  final List<Widget> overlays;

  const GameHUD({
    super.key,
    required this.gameWidget,
    required this.onBack,
    this.showDevToggle = false,
    this.isDevPanelOpen = false,
    this.onDevToggle,
    this.devPanel,
    this.onDismissDevPanel,
    this.leftIndicators = const [],
    this.rightContent,
    this.centerContent,
    this.bottomContent,
    this.showHUD = true,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Game widget with tap-outside-to-dismiss
          GestureDetector(
            onTap: isDevPanelOpen ? onDismissDevPanel : null,
            behavior: HitTestBehavior.translucent,
            child: gameWidget,
          ),

          // HUD elements
          if (showHUD) ...[
            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: back button, dev toggle, indicators
                    _LeftColumn(
                      onBack: onBack,
                      showDevToggle: showDevToggle,
                      isDevPanelOpen: isDevPanelOpen,
                      onDevToggle: onDevToggle,
                      devPanel: devPanel,
                      indicators: leftIndicators,
                    ),

                    // Center content (IgnorePointer to allow taps through to game)
                    if (centerContent != null)
                      Expanded(
                        child: Center(
                          child: IgnorePointer(child: centerContent),
                        ),
                      )
                    else
                      const Spacer(),

                    // Right side content (IgnorePointer to allow taps through to game)
                    if (rightContent != null)
                      IgnorePointer(child: rightContent!),
                  ],
                ),
              ),
            ),

            // Bottom content
            if (bottomContent != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: bottomContent,
                  ),
                ),
              ),
          ],

          // Overlays (game over, level complete, etc.)
          ...overlays,
        ],
      ),
    );
  }
}

/// Left column containing back button, dev toggle, dev panel, and indicators
class _LeftColumn extends StatelessWidget {
  final VoidCallback onBack;
  final bool showDevToggle;
  final bool isDevPanelOpen;
  final VoidCallback? onDevToggle;
  final Widget? devPanel;
  final List<Widget> indicators;

  const _LeftColumn({
    required this.onBack,
    required this.showDevToggle,
    required this.isDevPanelOpen,
    this.onDevToggle,
    this.devPanel,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back button
        IconButton(
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_back,
            color: GameColors.beam.withValues(alpha: 0.6),
            size: 28,
          ),
        ),

        // Dev mode toggle button
        if (showDevToggle)
          IconButton(
            onPressed: onDevToggle,
            icon: Icon(
              isDevPanelOpen ? Icons.science : Icons.science_outlined,
              color: isDevPanelOpen
                  ? GameColors.beam
                  : GameColors.beam.withValues(alpha: 0.4),
              size: 24,
            ),
          ),

        // Dev panel (appears below toggle)
        if (isDevPanelOpen && devPanel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: devPanel,
          ),

        // Left-side indicators (wind, timer, etc.)
        if (indicators.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...indicators.map((indicator) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: indicator,
              )),
        ],
      ],
    );
  }
}

/// Helper widget for creating a standard game screen with GameHUD
class GameScreen<T extends FlameGame> extends StatelessWidget {
  final T game;
  final VoidCallback onBack;
  final bool showDevToggle;
  final bool isDevPanelOpen;
  final VoidCallback? onDevToggle;
  final Widget? devPanel;
  final VoidCallback? onDismissDevPanel;
  final List<Widget> leftIndicators;
  final Widget? rightContent;
  final Widget? centerContent;
  final Widget? bottomContent;
  final bool showHUD;
  final List<Widget> overlays;
  final Color? backgroundColor;

  const GameScreen({
    super.key,
    required this.game,
    required this.onBack,
    this.showDevToggle = false,
    this.isDevPanelOpen = false,
    this.onDevToggle,
    this.devPanel,
    this.onDismissDevPanel,
    this.leftIndicators = const [],
    this.rightContent,
    this.centerContent,
    this.bottomContent,
    this.showHUD = true,
    this.overlays = const [],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GameHUD(
      gameWidget: GameWidget(
        game: game,
        backgroundBuilder: (context) => Container(
          color: backgroundColor ?? GameColors.background,
        ),
      ),
      onBack: onBack,
      showDevToggle: showDevToggle,
      isDevPanelOpen: isDevPanelOpen,
      onDevToggle: onDevToggle,
      devPanel: devPanel,
      onDismissDevPanel: onDismissDevPanel,
      leftIndicators: leftIndicators,
      rightContent: rightContent,
      centerContent: centerContent,
      bottomContent: bottomContent,
      showHUD: showHUD,
      overlays: overlays,
    );
  }
}
