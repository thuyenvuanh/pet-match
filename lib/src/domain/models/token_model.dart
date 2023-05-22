class AuthorizationToken {
  String? accessToken;
  String? refreshToken;

  AuthorizationToken({required this.accessToken, required this.refreshToken});

  AuthorizationToken.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
