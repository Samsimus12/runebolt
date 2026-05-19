import 'dart:async';

import 'package:flutter/material.dart';

import '../game/novabolt_game.dart';

class CountdownOverlay extends StatefulWidget {
  final NovaboltGame game;
  const CountdownOverlay({super.key, required this.game});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _count = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_count == 1) {
        timer.cancel();
        widget.game.overlays.remove('Countdown');
        widget.game.resumeEngine();
      } else {
        setState(() => _count--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GET READY',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                '$_count',
                key: ValueKey(_count),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 16)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
