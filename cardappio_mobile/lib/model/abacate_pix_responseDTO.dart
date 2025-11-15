class AbacatePixResponseDTO {
  final String pixId;
  final String status;
  final String brCode; 
  final String brCodeBase64; 

  AbacatePixResponseDTO({
    required this.pixId,
    required this.status,
    required this.brCode,
    required this.brCodeBase64,
  });

  factory AbacatePixResponseDTO.fromJson(Map<String, dynamic> json) {
    return AbacatePixResponseDTO(
      pixId: json['pixId'] as String,
      status: json['status'] as String,
      brCode: json['brCode'] as String,
      brCodeBase64: json.containsKey('brCodeBase64') ? json['brCodeBase64'] as String : '',
    );
  }
}