class StreamResponseEvent {
  String code = "";
  String message = "";

  StreamResponseEvent.fromData(Map data) {
    code = data['Code'] ?? false;
    message = data['Message'] ?? "";
  }
}