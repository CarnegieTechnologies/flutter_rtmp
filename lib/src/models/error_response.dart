class StreamResponseEvent {
  String code = "";
  String message = "";

  StreamResponseEvent.fromData(Map data) {
    code = data['Code'] ?? false as String;
    message = data['Message'] ?? "";
  }
}