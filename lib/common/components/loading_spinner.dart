import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Widget progressIndicator;
  final Offset? offset;
  final bool dismissible;
  final Widget child;

  LoadingSpinner({
    required this.inAsyncCall,
    required this.child,
    this.opacity = 0.3,
    this.color = Colors.black12,
    this.progressIndicator = const CircularProgressIndicator(),
    this.offset,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      if (offset == null)
        layOutProgressIndicator = Center(child: progressIndicator);
      else {
        layOutProgressIndicator = Positioned(
          child: progressIndicator,
          left: offset!.dx,
          top: offset!.dy,
        );
      }
      final modal = [
        new Opacity(
          // child: ModalBarrier(dismissible: dismissible),
          child: ModalBarrier(dismissible: dismissible, color: color),
          opacity: opacity,
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return Stack(
      children: widgetList,
    );
  }
}
