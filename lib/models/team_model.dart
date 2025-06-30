class TeamModel {
  final String id;
  final String name;
  final String logoUrl;
  final String coach;
  final String groupName;
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.coach,
    required this.groupName,
    required this.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String? ?? '',
      coach: json['coach'] as String? ?? '',
      groupName: json['group_name'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'coach': coach,
      'group_name': groupName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
