import 'package:piala_presiden_apk/models/match_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StandingService {
  final SupabaseClient client;
  StandingService({required this.client});

  Future<List<Map<String, dynamic>>> getStandingsBySeason(
    String seasonId,
  ) async {
    final data = await client
        .from('standings')
        .select('*, teams(name, logo_url)')
        .eq('season_id', seasonId)
        .order('group_name', ascending: true)
        .order('points', ascending: false)
        .order('goals_for', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, List<MatchModel>>> getKnockoutMatches(
    String seasonId,
  ) async {
    final stages = ['semifinal', 'third_place', 'final'];
    final Map<String, List<MatchModel>> result = {};
    for (final stage in stages) {
      final matches = await client
          .from('matches')
          .select()
          .eq('season_id', seasonId)
          .eq('stage', stage)
          .order('match_time');

      result[stage] =
          (matches as List).map((m) => MatchModel.fromJson(m)).toList();
    }

    return result;
  }
}
