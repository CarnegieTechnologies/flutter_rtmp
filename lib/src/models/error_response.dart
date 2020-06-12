class ErrorStreamResponse {
  String code = "";
  String message = "";

  ErrorStreamResponse.fromData(Map data) {
    code = data['Code'] ?? false;
    message = data['Message'] ?? "";
  }
}