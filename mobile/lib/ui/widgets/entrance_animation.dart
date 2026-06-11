import 'dart:async';

import 'package:flutter/material.dart';

/// Slide-up 8px + fade, 320ms, cubic(.22,1,.36,1), staggered via [delay].
/// Respects MediaQuery.disableAnimations.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    const curve = Cubic(0.22, 1.0, 0.36, 1.0);
    _opacity = CurvedAnimation(parent: _ctrl, curve: curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04), // ~8px for typical screen
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: curve));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _ctrl.value = 1.0;
        return;
      }
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
