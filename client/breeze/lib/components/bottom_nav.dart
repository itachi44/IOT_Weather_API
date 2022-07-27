import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

const double minHeight = 80;
const double iconStartSize = 44;
const double iconEndSize = 120;
const double iconStartMarginTop = 36;
const double iconEndMarginTop = 80;
const double iconsVerticalSpacing = 24;
const double iconsHorizontalSpacing = 16;

//afficher les points qu'il a
class BottomNav extends StatefulWidget {
  final bool openBottomNavBar;

  const BottomNav({Key key, this.openBottomNavBar = false}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  AnimationController _controller;

  double get maxHeight => MediaQuery.of(context).size.height;
  double get headerTopMargin =>
      lerp(20, 20 + MediaQuery.of(context).padding.top);
  double get headerFontSize => lerp(14, 24);
  double get itemBorderRadius => lerp(8, 24);
  double get iconLeftBorderRadius => itemBorderRadius;
  double get iconRightBorderRadius => lerp(8, 0);
  double get iconSize => lerp(iconStartSize, iconEndSize);

  double iconTopMargin(int index) =>
      lerp(iconStartMarginTop,
          iconEndMarginTop + index * (iconsVerticalSpacing + iconEndSize)) +
      headerTopMargin;

  double iconLeftMargin(int index) =>
      lerp(index * (iconsHorizontalSpacing + iconStartSize), 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    if (widget.openBottomNavBar == true) {
      _toggle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value);

  Widget _buildSheetHeader({double fontSize, double topMargin}) {
    return Positioned(
      top: topMargin,
      child: Text(
        'Vos accomplissements de la journée.',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize * 1.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeight, maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              decoration: const BoxDecoration(
                color: Color(0xff00a8ff),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: MediaQuery.of(context).size.width / 1.4,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height / 23.2,
                    child: InkWell(
                      onTap: _toggle,
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height / 29,
                      ),
                    ),
                  ),
                  _buildSheetHeader(
                    fontSize: headerFontSize,
                    topMargin: headerTopMargin,
                  ),
                  _buildExpandedEventItem(
                    topMargin: iconTopMargin(0),
                    leftMargin: iconLeftMargin(0),
                    height: iconSize,
                    isVisible: _controller.status == AnimationStatus.completed,
                    borderRadius: itemBorderRadius,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedEventItem(
      {double topMargin,
      double leftMargin,
      double height,
      bool isVisible,
      double borderRadius}) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height / 2.7,
          left: leftMargin,
          right: 0,
          // height: 85,
          child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child: Center(
                child: FadeInUp(
                    from: 30,
                    delay: Duration(milliseconds: 800),
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "vous n'avez rien réalisé pour le moment",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
              )),
        ),
      ],
    );
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(velocity: isOpen ? -2 : 2);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }
}
