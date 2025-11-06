class Ubicacion {
  String id;
  final double latitude;
  final double longitude;

  Ubicacion({
    this.id = '', 
    required this.latitude,
    required this.longitude
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}