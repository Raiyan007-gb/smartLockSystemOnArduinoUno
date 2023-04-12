import 'package:flutter/material.dart';

class GradientButtonIcon extends StatefulWidget {
  final Gradient backgroundGradient;
  final Widget child;
  final VoidCallback onPressed;

  const GradientButtonIcon({
    Key? key,
    required this.backgroundGradient,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
// ignore: library_private_types_in_public_api
  _GradientButtonIconState createState() => _GradientButtonIconState();
}

class _GradientButtonIconState extends State<GradientButtonIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ).merge(
            ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.7);
                  }
// ignore: null_check_always_fails
                  return null!;
                },
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.backgroundGradient.colors.first
                      .withOpacity(_animation.value),
                  widget.backgroundGradient.colors.last
                      .withOpacity(_animation.value),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundGradient.colors.last
                      .withOpacity(_animation.value),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
