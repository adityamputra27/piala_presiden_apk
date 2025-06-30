import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:piala_presiden_apk/models/news_model.dart';

class NewsService {
  final SupabaseClient client;

  NewsService({required this.client});

  Future<List<NewsModel>> fetchNewsLastWeek() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final result = await client
        .from('news')
        .select()
        .gte('created_at', weekAgo.toIso8601String())
        .lte('created_at', now.toIso8601String())
        .order('created_at', ascending: false);

    return (result as List)
        .map((n) => NewsModel.fromJson(n as Map<String, dynamic>))
        .toList();
  }
}
