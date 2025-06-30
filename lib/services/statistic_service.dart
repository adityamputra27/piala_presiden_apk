import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticService {
  final SupabaseClient client;

  StatisticService({required this.client});

  Future<List<Map<String, dynamic>>> getTopScorers(String seasonId) async {
    // Step 1: Ambil semua match_id untuk season ini
    final matches = await client
        .from('matches')
        .select('id')
        .eq('season_id', seasonId);

    final matchIds =
        (matches as List)
            .map((m) => m['id'] as String)
            .where((id) => id != null)
            .toList();

    if (matchIds.isEmpty) return [];

    // Step 2: Ambil match_stats dengan event_type goal dan match_id yang sesuai
    final stats = await client
        .from('match_events')
        .select('player_id')
        .inFilter('match_id', matchIds)
        .eq('event_type', 'goal');

    // Step 3: Grouping & count by player_id
    final Map<String, int> goalCount = {};
    for (final row in stats) {
      final playerId = row['player_id'] as String;
      if (!goalCount.containsKey(playerId)) {
        goalCount[playerId] = 1;
      } else {
        goalCount[playerId] = goalCount[playerId]! + 1;
      }
    }

    if (goalCount.isEmpty) return [];

    // Step 4: Ambil data player dari tabel players (atau player detail table kamu)
    final playerIds = goalCount.keys.toList();
    final players = await client
        .from('players')
        .select(
          'id, name, photo_url, team_id, team:team_id(id, name, logo_url)',
        )
        .inFilter('id', playerIds);

    // Step 5: Gabungkan data goals & player info
    final List<Map<String, dynamic>> topScorers = [];
    for (final player in players) {
      final playerId = player['id'] as String;
      final team = player['team'] ?? {};
      topScorers.add({
        'player_id': playerId,
        'name': player['name'],
        'photo_url': player['photo_url'],
        'team_id': player['team_id'],
        'team_name': team['name'],
        'team_logo': team['logo_url'],
        'goals': goalCount[playerId] ?? 0,
      });
    }

    // Step 6: Urutkan dan tambahkan rank
    topScorers.sort((a, b) => (b['goals'] as int).compareTo(a['goals'] as int));
    for (var i = 0; i < topScorers.length; i++) {
      topScorers[i]['rank'] = i + 1;
    }

    return topScorers.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getTopAssists(String seasonId) async {
    // Step 1: Ambil semua match_id untuk season ini
    final matches = await client
        .from('matches')
        .select('id')
        .eq('season_id', seasonId);

    final matchIds =
        (matches as List)
            .map((m) => m['id'] as String)
            .where((id) => id != null)
            .toList();

    if (matchIds.isEmpty) return [];

    // Step 2: Ambil match_stats dengan event_type goal dan match_id yang sesuai
    final stats = await client
        .from('match_events')
        .select('player_id')
        .inFilter('match_id', matchIds)
        .eq('event_type', 'assist');

    // Step 3: Grouping & count by player_id
    final Map<String, int> assistCount = {};
    for (final row in stats) {
      final playerId = row['player_id'] as String;
      if (!assistCount.containsKey(playerId)) {
        assistCount[playerId] = 1;
      } else {
        assistCount[playerId] = assistCount[playerId]! + 1;
      }
    }

    if (assistCount.isEmpty) return [];

    // Step 4: Ambil data player dari tabel players (atau player detail table kamu)
    final playerIds = assistCount.keys.toList();
    final players = await client
        .from('players')
        .select(
          'id, name, photo_url, team_id, team:team_id(id, name, logo_url)',
        )
        .inFilter('id', playerIds);

    // Step 5: Gabungkan data goals & player info
    final List<Map<String, dynamic>> topAssists = [];
    for (final player in players) {
      final playerId = player['id'] as String;
      final team = player['team'] ?? {};
      topAssists.add({
        'player_id': playerId,
        'name': player['name'],
        'photo_url': player['photo_url'],
        'team_id': player['team_id'],
        'team_name': team['name'],
        'team_logo': team['logo_url'],
        'assists': assistCount[playerId] ?? 0,
      });
    }

    // Step 6: Urutkan dan tambahkan rank
    topAssists.sort(
      (a, b) => (b['assists'] as int).compareTo(a['assists'] as int),
    );
    for (var i = 0; i < topAssists.length; i++) {
      topAssists[i]['rank'] = i + 1;
    }

    return topAssists.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getTopYellowCard(String seasonId) async {
    // Step 1: Ambil semua match_id untuk season ini
    final matches = await client
        .from('matches')
        .select('id')
        .eq('season_id', seasonId);

    final matchIds =
        (matches as List)
            .map((m) => m['id'] as String)
            .where((id) => id != null)
            .toList();

    if (matchIds.isEmpty) return [];

    // Step 2: Ambil match_stats dengan event_type goal dan match_id yang sesuai
    final stats = await client
        .from('match_events')
        .select('player_id')
        .inFilter('match_id', matchIds)
        .eq('event_type', 'yellow_card');

    // Step 3: Grouping & count by player_id
    final Map<String, int> yellowCardCount = {};
    for (final row in stats) {
      final playerId = row['player_id'] as String;
      if (!yellowCardCount.containsKey(playerId)) {
        yellowCardCount[playerId] = 1;
      } else {
        yellowCardCount[playerId] = yellowCardCount[playerId]! + 1;
      }
    }

    if (yellowCardCount.isEmpty) return [];

    // Step 4: Ambil data player dari tabel players (atau player detail table kamu)
    final playerIds = yellowCardCount.keys.toList();
    final players = await client
        .from('players')
        .select(
          'id, name, photo_url, team_id, team:team_id(id, name, logo_url)',
        )
        .inFilter('id', playerIds);

    // Step 5: Gabungkan data goals & player info
    final List<Map<String, dynamic>> topYellowCard = [];
    for (final player in players) {
      final playerId = player['id'] as String;
      final team = player['team'] ?? {};
      topYellowCard.add({
        'player_id': playerId,
        'name': player['name'],
        'photo_url': player['photo_url'],
        'team_id': player['team_id'],
        'team_name': team['name'],
        'team_logo': team['logo_url'],
        'cards': yellowCardCount[playerId] ?? 0,
      });
    }

    // Step 6: Urutkan dan tambahkan rank
    topYellowCard.sort(
      (a, b) => (b['cards'] as int).compareTo(a['cards'] as int),
    );
    for (var i = 0; i < topYellowCard.length; i++) {
      topYellowCard[i]['rank'] = i + 1;
    }

    return topYellowCard.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getTopRedCard(String seasonId) async {
    // Step 1: Ambil semua match_id untuk season ini
    final matches = await client
        .from('matches')
        .select('id')
        .eq('season_id', seasonId);

    final matchIds =
        (matches as List)
            .map((m) => m['id'] as String)
            .where((id) => id != null)
            .toList();

    if (matchIds.isEmpty) return [];

    // Step 2: Ambil match_stats dengan event_type goal dan match_id yang sesuai
    final stats = await client
        .from('match_events')
        .select('player_id')
        .inFilter('match_id', matchIds)
        .eq('event_type', 'red_card');

    // Step 3: Grouping & count by player_id
    final Map<String, int> redCardCount = {};
    for (final row in stats) {
      final playerId = row['player_id'] as String;
      if (!redCardCount.containsKey(playerId)) {
        redCardCount[playerId] = 1;
      } else {
        redCardCount[playerId] = redCardCount[playerId]! + 1;
      }
    }

    if (redCardCount.isEmpty) return [];

    // Step 4: Ambil data player dari tabel players (atau player detail table kamu)
    final playerIds = redCardCount.keys.toList();
    final players = await client
        .from('players')
        .select(
          'id, name, photo_url, team_id, team:team_id(id, name, logo_url)',
        )
        .inFilter('id', playerIds);

    // Step 5: Gabungkan data goals & player info
    final List<Map<String, dynamic>> topRedCard = [];
    for (final player in players) {
      final playerId = player['id'] as String;
      final team = player['team'] ?? {};
      topRedCard.add({
        'player_id': playerId,
        'name': player['name'],
        'photo_url': player['photo_url'],
        'team_id': player['team_id'],
        'team_name': team['name'],
        'team_logo': team['logo_url'],
        'cards': redCardCount[playerId] ?? 0,
      });
    }

    // Step 6: Urutkan dan tambahkan rank
    topRedCard.sort((a, b) => (b['cards'] as int).compareTo(a['cards'] as int));
    for (var i = 0; i < topRedCard.length; i++) {
      topRedCard[i]['rank'] = i + 1;
    }

    return topRedCard.take(10).toList();
  }
}
