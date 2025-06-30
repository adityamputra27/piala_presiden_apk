import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerService {
  final SupabaseClient client;
  PlayerService({required this.client});

  Future<List<Map<String, dynamic>>> getPlayersByTeam(String teamId) async {
    final res = await client
        .from('players')
        .select()
        .eq('team_id', teamId)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> getPlayerById(String id) async {
    final response =
        await client
            .from('players')
            .select()
            .eq('id', id)
            .order('name', ascending: true)
            .single();

    return Map<String, dynamic>.from(response);
  }
}
