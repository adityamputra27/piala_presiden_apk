import 'package:piala_presiden_apk/models/season_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SeasonService {
  final SupabaseClient client;

  SeasonService({required this.client});

  Future<SeasonModel?> getActiveSeason() async {
    final data =
        await client
            .from('seasons')
            .select()
            .eq('is_active', true)
            .limit(1)
            .maybeSingle();

    if (data == null) return null;
    return SeasonModel.fromJson(data);
  }
}
