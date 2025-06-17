import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingElements extends StatefulWidget {
  const FloatingElements({Key? key}) : super(key: key);

  @override
  State<FloatingElements> createState() => _FloatingElementsState();
}

class _FloatingElementsState extends State<FloatingElements> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Offset> _positions = [];
  final List<Color> _colors = [];
  final List<double> _sizes = [];
  final int _count = 15;

  @override
  void initState() {
    super.initState();
    
    final random = math.Random();
    _controllers = List.generate(
      _count,
      (index) => AnimationController(
        duration: Duration(seconds: random.nextInt(10) + 10),
        vsync: this,
      )..repeat(reverse: true),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    for (int i = 0; i < _count; i++) {
      _positions.add(Offset(
        random.nextDouble() * 400 - 200,
        random.nextDouble() * 400 - 200,
      ));
      
      _colors.add(Color.fromRGBO(
        random.nextInt(100) + 155,
        random.nextInt(100) + 155,
        255,
        0.2 + random.nextDouble() * 0.3,
      ));
      
      _sizes.add(10 + random.nextDouble() * 20);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: List.generate(_count, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final value = _animations[index].value;
              final position = _positions[index];
              
              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + position.dx + (math.sin(value * math.pi * 2) * 20),
                bottom: position.dy + (math.cos(value * math.pi * 2) * 20),
                child: Opacity(
                  opacity: 0.2 + (value * 0.5),
                  child: Container(
                    width: _sizes[index],
                    height: _sizes[index],
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
} 