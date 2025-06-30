class SeasonModel {
  final String id;
  final String name;

  SeasonModel({required this.id, required this.name});

  factory SeasonModel.fromJson(Map<String, dynamic> json) =>
      SeasonModel(id: json['id'], name: json['name']);
}
