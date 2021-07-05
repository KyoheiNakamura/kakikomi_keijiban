extension ExceptionExt on Exception {
  String messageToString() {
    var message = toString();
    if (toString().contains('Exception: ')) {
      message = toString().replaceFirst('Exception: ', '');
    }
    return message;
  }
}
