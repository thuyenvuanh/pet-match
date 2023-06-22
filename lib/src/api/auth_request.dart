class AuthorizationRequest {
  String? idTokenString;
  String? fcmToken;

  AuthorizationRequest({
    this.idTokenString,
    this.fcmToken,
  });

  AuthorizationRequest.fromJson(Map<String, dynamic> json) {
    idTokenString = json['idTokenString'];
    fcmToken = json['fcmToken'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['idTokenString'] = idTokenString;
    data['fcmToken'] = fcmToken;
    return data;
  }
}
