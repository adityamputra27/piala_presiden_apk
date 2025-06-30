import 'package:piala_presiden_apk/models/team_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamService {
  final SupabaseClient client;

  TeamService({required this.client});

  Future<List<TeamModel>> getTeamsBySeason(String seasonId) async {
    final data = await client
        .from('teams')
        .select()
        // .eq('season_id', seasonId)
        .order('name', ascending: true);

    return (data as List).map((c) => TeamModel.fromJson(c)).toList();
  }

  Future<TeamModel> getTeamById(String id) async {
    final data = await client.from('teams').select().eq('id', id).maybeSingle();
    return TeamModel.fromJson(data!);
  }
}
