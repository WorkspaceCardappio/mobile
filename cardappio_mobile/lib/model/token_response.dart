class TokenResponse {
  final String accessToken;
  final int expiresIn;
  final int? refreshExpiresIn;
  final String? refreshToken;
  final String tokenType;
  final String? sessionState;
  final String? scope;
  final DateTime tokenReceivedAt;

  TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    this.refreshExpiresIn,
    this.refreshToken,
    required this.tokenType,
    this.sessionState,
    this.scope,
    DateTime? tokenReceivedAt,
  }) : tokenReceivedAt = tokenReceivedAt ?? DateTime.now();

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      refreshExpiresIn: json['refresh_expires_in'] as int?,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String,
      sessionState: json['session_state'] as String?,
      scope: json['scope'] as String?,
      tokenReceivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'session_state': sessionState,
      'scope': scope,
      'token_received_at': tokenReceivedAt.toIso8601String(),
    };
  }

  factory TokenResponse.fromJsonWithTimestamp(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      refreshExpiresIn: json['refresh_expires_in'] as int?,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String,
      sessionState: json['session_state'] as String?,
      scope: json['scope'] as String?,
      tokenReceivedAt: json['token_received_at'] != null
          ? DateTime.parse(json['token_received_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isExpired {
    final expirationTime = tokenReceivedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expirationTime);
  }

  bool get isAboutToExpire {
    final expirationTime = tokenReceivedAt.add(Duration(seconds: expiresIn));
    final timeUntilExpiration = expirationTime.difference(DateTime.now());
    return timeUntilExpiration.inMinutes < 5;
  }

  Duration get timeUntilExpiration {
    final expirationTime = tokenReceivedAt.add(Duration(seconds: expiresIn));
    return expirationTime.difference(DateTime.now());
  }
}