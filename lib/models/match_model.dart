import 'package:piala_presiden_apk/models/team_model.dart';

class MatchModel {
  final String id;
  final String seasonId;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final DateTime matchTime;
  final String status;
  final String location;
  final DateTime createdAt;
  final String stage;
  final TeamModel? teamAObj;
  final TeamModel? teamBObj;
  final String? highlightLink;
  final String? liveLink;

  MatchModel({
    required this.id,
    required this.seasonId,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.matchTime,
    required this.status,
    required this.location,
    required this.createdAt,
    required this.stage,
    this.teamAObj,
    this.teamBObj,
    this.highlightLink = "",
    this.liveLink = "",
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      seasonId: json['season_id'] as String,
      teamA: json['team_a'] as String,
      teamB: json['team_b'] as String,
      scoreA:
          json['score_a'] is int
              ? json['score_a']
              : int.tryParse(json['score_a'].toString()) ?? 0,
      scoreB:
          json['score_b'] is int
              ? json['score_b']
              : int.tryParse(json['score_b'].toString()) ?? 0,
      matchTime: DateTime.parse(json['match_time']),
      status: json['status'] as String? ?? '',
      location: json['location'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at']),
      stage: json['stage'] as String? ?? '',
      teamAObj:
          json['team_a_team'] != null
              ? TeamModel.fromJson(json['team_a_team'] as Map<String, dynamic>)
              : null,
      teamBObj:
          json['team_b_team'] != null
              ? TeamModel.fromJson(json['team_b_team'] as Map<String, dynamic>)
              : null,
      highlightLink: json['highlight_link'],
      liveLink: json['live_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season_id': seasonId,
      'team_a': teamA,
      'team_b': teamB,
      'score_a': scoreA,
      'score_b': scoreB,
      'match_time': matchTime.toIso8601String(),
      'status': status,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'stage': stage,
      // Kalau mau passing object-nya juga (bisa opsional)
      'team_a_team': teamAObj?.toJson(),
      'team_b_team': teamBObj?.toJson(),
      'highlight_link': highlightLink,
      'live_link': liveLink,
    };
  }
}
