import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({
    required this.isModalLoading,
    required this.child,
    this.opacity = 0.5,
    this.color = Colors.black38,
    this.dismissible = false,
    Key? key,
  }) : super(key: key);

  final bool isModalLoading;
  final double opacity;
  final Color color;
  final bool dismissible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[child];
    if (isModalLoading) {
      final modal = [
        Opacity(
          opacity: opacity,
          child: ModalBarrier(dismissible: dismissible, color: color,),
        ),
        const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
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
  CommonLoadingDialog._();
  static CommonLoadingDialog instance = CommonLoadingDialog._();

  late BuildContext _context;

  Future<void> showDialog(BuildContext context) async {
    _context = context;
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.1),
      pageBuilder: (_, __, ___) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void closeDialog() {
    Navigator.pop(_context);
  }
}
