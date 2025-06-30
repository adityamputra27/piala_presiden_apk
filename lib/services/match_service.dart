import 'package:piala_presiden_apk/models/match_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchService {
  final SupabaseClient client;

  MatchService({required this.client});

  // Ambil 2 pertandingan yang status-nya live (status = 'ongoing')
  Future<List<MatchModel>> getLiveMatches(
    String seasonId, {
    int limit = 2,
  }) async {
    final data = await client
        .from('matches')
        .select('*, team_a_team:team_a(*), team_b_team:team_b(*)')
        .eq('season_id', seasonId)
        .eq('status', 'ongoing')
        .order('match_time', ascending: true)
        .limit(limit);

    return (data as List)
        .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  // Ambil 2 pertandingan mendatang (status = 'upcoming' atau waktu match lebih dari sekarang)
  Future<List<MatchModel>> getUpcomingMatches(
    String seasonId, {
    int limit = 2,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final data = await client
        .from('matches')
        .select('*, team_a_team:team_a(*), team_b_team:team_b(*)')
        .eq('season_id', seasonId)
        // Filter upcoming, bisa berdasarkan status = 'upcoming'
        .eq('status', 'upcoming')
        // Atau filter waktu match di masa depan (lebih fleksibel)
        .gte('match_time', nowIso)
        .order('match_time', ascending: true)
        .limit(limit);

    return (data as List)
        .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Stream<List<MatchModel>> watchAllMatches(String seasonId) {
    return client
        .from('matches')
        .stream(primaryKey: ['id'])
        .inFilter('season_id', [seasonId])
        .order('match_time', ascending: true)
        .map((data) {
          return data.map((m) => MatchModel.fromJson(m)).toList();
        });
  }

  /// Stream realtime live matches untuk season tertentu
  Stream<List<MatchModel>> watchLiveMatches(String seasonId) {
    return client
        .from('matches')
        .stream(primaryKey: ['id'])
        .inFilter('status', ['ongoing'])
        .order('match_time')
        .limit(2)
        .map((data) {
          // filter manual by season_id
          final filtered =
              (data as List).where((m) => m['season_id'] == seasonId).toList();

          // mapping ke model, atau bisa enrich di sini
          return filtered
              .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
              .toList();
        });
  }

  // Helper untuk fetch live matches awal
  Future<List<MatchModel>> _fetchLiveMatches(String seasonId) async {
    final data = await client
        .from('matches')
        .select('*, team_a_team:team_a(*), team_b_team:team_b(*)')
        .eq('season_id', seasonId)
        .eq('status', 'ongoing')
        .order('match_time', ascending: true)
        .limit(2);

    return (data as List)
        .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Stream<MatchModel> getMatchStream(int matchId) {
    return client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .limit(1)
        .map((event) => MatchModel.fromJson(event.first))
        .asBroadcastStream();
  }

  Stream<List<Map<String, dynamic>>> getMatchEventsStream(String matchId) {
    return client
        .from('match_events')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('minute', ascending: true)
        .map(
          (rows) => rows.where((row) => row['event_type'] != 'assist').toList(),
        )
        .asBroadcastStream();
  }

  Stream<Map<String, dynamic>?> getMatchStatsStream(String matchId) {
    print('matchId');
    print(matchId);
    return client
        .from('match_stats')
        .stream(primaryKey: ['match_id'])
        .eq('match_id', matchId)
        .map((rows) {
          final mappingData = {'A': rows[0], 'B': rows[1]};
          print('mappingdata');
          print(mappingData);
          return mappingData;
        })
        // .map((rows) {
        // if (rows.length < 2) return null;
        // return {'A': rows[0], 'B': rows[1]};
        // })
        .asBroadcastStream();
  }
}
