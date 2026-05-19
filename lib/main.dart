import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ads/ad_manager.dart';
import 'audio/audio_manager.dart';
import 'coins/coin_manager.dart';
import 'game/novabolt_game.dart';
import 'stats/stats_manager.dart';
import 'screens/countdown_overlay.dart';
import 'screens/game_controls_overlay.dart';
import 'screens/game_over_screen.dart';
import 'screens/level_up_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const NovaboltApp());
}

class NovaboltApp extends StatefulWidget {
  const NovaboltApp({super.key});

  @override
  State<NovaboltApp> createState() => _NovaboltAppState();
}

class _NovaboltAppState extends State<NovaboltApp> {
  bool _loaded = false;
  bool _inGame = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    await AdManager.instance.init();
    await CoinManager.instance.init();
    await AudioManager.instance.init();
    await StatsManager.instance.init();
    AudioManager.instance.playMenu();
    if (mounted) setState(() => _loaded = true);
  }

  void _startGame() {
    AudioManager.instance.playGame();
    setState(() => _inGame = true);
  }

  void _returnToMenu() {
    AdManager.instance.showInterstitialAd(onDismissed: () {
      setState(() => _inGame = false);
      AudioManager.instance.playMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _loaded
            ? (_inGame
                ? _buildGame()
                : MainMenuScreen(key: const ValueKey('menu'), onPlay: _startGame))
            : const LoadingScreen(key: ValueKey('loading')),
      ),
    );
  }

  Widget _buildGame() {
    return GameWidget<NovaboltGame>.controlled(
      gameFactory: NovaboltGame.new,
      initialActiveOverlays: const ['GameControls'],
      overlayBuilderMap: {
        'GameControls': (context, game) =>
            GameControlsOverlay(game: game, onMenu: _returnToMenu),
        'GameOver': (context, game) =>
            GameOverScreen(game: game, onMenu: _returnToMenu),
        'LevelUp': (context, game) => LevelUpScreen(game: game),
        'Countdown': (context, game) => CountdownOverlay(game: game),
      },
    );
  }
}
