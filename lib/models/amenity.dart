class Amenity {
  final int id;
  final String name;
  final String description;
  final String startTime;
  final String endTime;

  Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id:json['id'],
      name: json['name'],
      description: json['description'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  @override
  String toString() => name;
}
