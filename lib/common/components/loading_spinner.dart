import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({
    required this.inAsyncCall,
    required this.child,
    this.opacity = 0.3,
    this.color = Colors.black38,
    this.progressIndicator = const CircularProgressIndicator(),
    this.offset,
    this.dismissible = false,
  });

  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Widget progressIndicator;
  final Offset? offset;
  final bool dismissible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[]..add(child);
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

/// [ModalBarrier] と [CircularProgressIndicator] を表示する Widget。
/// ロード中に使う。
Widget loadingSpinner({
  required Widget child,
  required bool isLoading,
}) {
  final modalBarrierList = [child];
  final barrier = [
    ModalBarrier(
      dismissible: false,
      color: Colors.black.withOpacity(0.1),
    ),
    const Center(
      child: CircularProgressIndicator(),
    ),
  ];

  if (isLoading) {
    modalBarrierList.addAll(barrier);
  }

  return Stack(
    children: modalBarrierList,
  );
}

/// 共通のローディングクラス
class CommonLoadingDialog {
  // CommonLoadingDialogクラスのシングルトン化 //
  CommonLoadingDialog._();
  static CommonLoadingDialog instance = CommonLoadingDialog._();
  //                                       //
  late BuildContext childContext;

  // factory CommonLoadingDialog() => _instance;
  // CommonLoadingDialog._internal();
  //
  // static final CommonLoadingDialog _instance
  //     = CommonLoadingDialog._internal();

  void showDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.1),
      pageBuilder: (BuildContext childContext, Animation animation,
          Animation secondaryAnimation) {
        this.childContext = childContext;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void closeDialog() {
    Navigator.pop(childContext);
  }
}
