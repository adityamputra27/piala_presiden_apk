import 'package:timeago/timeago.dart' as timeago;

class NewsModel {
  final String id;
  final String seasonId;
  final String title;
  final String content;
  final String category;
  final String thumbnailUrl;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.seasonId,
    required this.title,
    required this.content,
    required this.category,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      seasonId: json['season_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season_id': seasonId,
      'title': title,
      'content': content,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String getTimeAgo() {
    return timeago.format(createdAt, locale: 'en');
  }
}
