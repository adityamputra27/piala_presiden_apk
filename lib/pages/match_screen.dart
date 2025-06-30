import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/models/match_model.dart';
import 'package:piala_presiden_apk/models/team_model.dart';
import 'package:piala_presiden_apk/pages/match_detail_screen.dart';
import 'package:piala_presiden_apk/services/match_service.dart';
import 'package:piala_presiden_apk/services/season_service.dart';
import 'package:piala_presiden_apk/services/standing_service.dart';
import 'package:piala_presiden_apk/services/team_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:piala_presiden_apk/widgets/done_badge.dart';
import 'package:piala_presiden_apk/widgets/live_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/global_navigator.dart';

// Helper label tahap pertandingan
String stageLabel(String value) {
  switch (value) {
    case 'group':
      return 'Grup';
    case 'semifinal':
      return 'Semifinal';
    case 'final':
      return 'Final';
    case 'third_place':
      return 'Perebutan 3';
    default:
      return value;
  }
}

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final teamService = TeamService(client: Supabase.instance.client);
  final matchService = MatchService(client: Supabase.instance.client);
  final seasonService = SeasonService(client: Supabase.instance.client);
  final standingService = StandingService(client: Supabase.instance.client);

  List<Map<String, dynamic>> standings = [];
  bool loadingStandings = true;
  String? seasonId;
  bool loadingSeason = true;

  final List<Map<String, dynamic>> groupStandings = [
    {
      "team": "Persib",
      "played": 3,
      "win": 2,
      "draw": 1,
      "lose": 0,
      "goal_diff": 5,
      "points": 7,
      "logo":
          "https://upload.wikimedia.org/wikipedia/id/9/94/Persija_Jakarta_logo.png",
    },
    {
      "team": "Persija",
      "played": 3,
      "win": 2,
      "draw": 0,
      "lose": 1,
      "goal_diff": 2,
      "points": 6,
      "logo":
          "https://upload.wikimedia.org/wikipedia/id/9/94/Persija_Jakarta_logo.png",
    },
    {
      "team": "Bali Utd",
      "played": 3,
      "win": 1,
      "draw": 1,
      "lose": 1,
      "goal_diff": 1,
      "points": 4,
      "logo":
          "https://upload.wikimedia.org/wikipedia/id/9/94/Persija_Jakarta_logo.png",
    },
    {
      "team": "Arema",
      "played": 3,
      "win": 0,
      "draw": 0,
      "lose": 3,
      "goal_diff": -8,
      "points": 0,
      "logo":
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgdHnJidTHq1JJULbe0RaG9jE0U8RnohJqNH1HqWDYwozDFreEVNAJgCCvPzZAy2M3uiHrMnv2wMPAm2vzvPXRfk7x6F9PEpwSNlv4uAQfIkyE43-BpxvlzPPIHIw7xu8O7WvkQEkxcCUZo/w640-h640/logo-arema-fc.png",
    },
  ];

  Map<String, List<MatchModel>> knockoutMatches = {};
  bool loadingKnockout = true;

  final List<Tab> matchTabs = const [
    Tab(text: "Jadwal Pertandingan"),
    Tab(text: "Klasemen Grup"),
    Tab(text: "Knockout"),
  ];

  BannerAd? _bannerAd;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;

  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;
  MatchModel? selectedMatch;

  @override
  void initState() {
    _tabController = TabController(length: matchTabs.length, vsync: this);
    super.initState();
    _loadActiveSeason();
    _loadBannerAd();
    _loadBannerAd2();
    _loadBannerAd3();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
    _bannerAd2?.dispose();
    _bannerAd3?.dispose();
    _interstitialAd?.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          MatchDetailScreen(matchModel: selectedMatch!),
                ),
              );
              ad.dispose();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('error interstitial ad');
        },
      ),
    );
  }

  void _loadBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void _loadBannerAd2() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd2 = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void _loadBannerAd3() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd3 = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  Widget _buildBannerAd() {
    return (_bannerAd != null)
        ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 4),
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        )
        : Container();
  }

  Widget _buildBannerAd2() {
    return (_bannerAd2 != null)
        ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 4),
            width: _bannerAd2!.size.width.toDouble(),
            height: _bannerAd2!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd2!),
          ),
        )
        : Container();
  }

  Widget _buildBannerAd3() {
    return (_bannerAd2 != null)
        ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 4),
            width: _bannerAd3!.size.width.toDouble(),
            height: _bannerAd3!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd2!),
          ),
        )
        : Container();
  }

  Future<void> _loadActiveSeason() async {
    setState(() => loadingSeason = true);
    final season = await seasonService.getActiveSeason();
    if (season != null) {
      seasonId = season.id;
      fetchStandings(seasonId!);
      fetchKnockoutMatches(seasonId!);
    }
    setState(() => loadingSeason = false);
  }

  Future<void> fetchStandings(String seasonId) async {
    setState(() => loadingStandings = true);
    final standing = await standingService.getStandingsBySeason(seasonId);
    setState(() {
      standings = standing;
      loadingStandings = false;
    });
  }

  Future<void> fetchKnockoutMatches(String seasonId) async {
    setState(() => loadingKnockout = true);
    final result = await standingService.getKnockoutMatches(seasonId);
    setState(() {
      knockoutMatches = result;
      loadingKnockout = false;
    });
  }

  Widget showTeamLogo(String url, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child:
              url.isNotEmpty
                  ? Image.network(url, fit: BoxFit.contain)
                  : Icon(
                    Icons.shield,
                    size: width * 0.7,
                    color: Colors.grey[400],
                  ),
        ),
      ),
    );
  }

  String shortTeamName(String name, int wordTake) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(wordTake).join(' ');
  }

  String stageLabel(String value) {
    switch (value) {
      case 'group':
        return 'Grup';
      case 'semifinal':
        return 'Semifinal';
      case 'final':
        return 'Final';
      case 'third_place':
        return 'Perebutan 3';
      default:
        return value; // fallback: tampilkan raw value
    }
  }

  Widget buildMatchList() {
    return StreamBuilder<List<MatchModel>>(
      stream: matchService.watchAllMatches(seasonId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(top: 32),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text(
                "Belum ada pertandingan",
                style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        final matches = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: matches.length + 1,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            itemBuilder: (context, index) {
              if (index == 3) {
                return _buildBannerAd();
              }

              final match = index > 3 ? matches[index - 1] : matches[index];
              return FutureBuilder<List<TeamModel?>>(
                future: Future.wait([
                  teamService.getTeamById(match.teamA),
                  teamService.getTeamById(match.teamB),
                ]),
                builder: (context, teamSnapshot) {
                  if (!teamSnapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final teamA = teamSnapshot.data![0];
                  final teamB = teamSnapshot.data![1];

                  return GestureDetector(
                    onTap: () {
                      Map<String, dynamic> json = match.toJson();
                      json['team_a_team'] = teamA?.toJson();
                      json['team_b_team'] = teamB?.toJson();

                      setState(() {
                        selectedMatch = MatchModel.fromJson(json);
                      });
                      if (!isInterstitialAdLoaded) {
                        if (_interstitialAd != null) {
                          _interstitialAd?.show();
                          setState(() {
                            isInterstitialAdLoaded = true;
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MatchDetailScreen(
                                    matchModel: MatchModel.fromJson(json),
                                  ),
                            ),
                          );
                          setState(() {
                            isInterstitialAdLoaded = true;
                          });
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MatchDetailScreen(
                                  matchModel: MatchModel.fromJson(json),
                                ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    showTeamLogo(teamA?.logoUrl ?? '', 48, 48),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        shortTeamName(teamA!.name, 2),
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (match.status == 'upcoming')
                                      Column(
                                        children: [
                                          Text(
                                            DateFormat(
                                              'd MMM yyyy',
                                              'id_ID',
                                            ).format(match.matchTime.toLocal()),
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${DateFormat('HH:mm', 'id_ID').format(match.matchTime.toLocal())} WIB",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              shortTeamName(match.location, 5),
                                              style: AppTextStyle.label
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (match.status == 'live' ||
                                        match.status == 'ongoing')
                                      Column(
                                        children: [
                                          Text(
                                            "Hari ini",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${match.scoreA} - ${match.scoreB}",
                                            style: AppTextStyle.label2.copyWith(
                                              color: AppColors.black,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          LiveBadge(),
                                        ],
                                      ),
                                    if (match.status == 'done')
                                      Column(
                                        children: [
                                          Text(
                                            "${DateFormat('HH:mm', 'id_ID').format(match.matchTime.toLocal())} WIB, ${DateFormat('d MMM yyyy', 'id_ID').format(match.matchTime.toLocal())}",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${match.scoreA} - ${match.scoreB}",
                                            style: AppTextStyle.label2.copyWith(
                                              color: AppColors.black,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          DoneBadge(),
                                        ],
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    showTeamLogo(teamB?.logoUrl ?? '', 48, 48),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        shortTeamName(teamB!.name, 2),
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget buildStandingsTab() {
    if (loadingStandings) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }
    if (standings.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada data klasemen",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Bagi data per grup
    final groupA = standings.where((x) => x['group_name'] == 'A').toList();
    final groupB = standings.where((x) => x['group_name'] == 'B').toList();
    final groupC = standings.where((x) => x['group_name'] == 'C').toList();
    final groupD = standings.where((x) => x['group_name'] == 'D').toList();
    final groupE = standings.where((x) => x['group_name'] == 'E').toList();
    final groupF = standings.where((x) => x['group_name'] == 'F').toList();
    final groupG = standings.where((x) => x['group_name'] == 'G').toList();
    final groupH = standings.where((x) => x['group_name'] == 'H').toList();
    final groupI = standings.where((x) => x['group_name'] == 'I').toList();
    final groupJ = standings.where((x) => x['group_name'] == 'J').toList();

    Widget buildGroupTable(String groupName, List<Map<String, dynamic>> teams) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Text(
                "Grup $groupName",
                style: AppTextStyle.label.copyWith(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: AppColors.black),
                  children: [
                    tableCellHeader("Tim"),
                    tableCellHeader("Ma"),
                    tableCellHeader("M"),
                    tableCellHeader("S"),
                    tableCellHeader("K"),
                    // tableCellHeader("SG"),
                    tableCellHeader("P"),
                  ],
                ),
                // Data rows
                for (var team in teams)
                  TableRow(
                    decoration: BoxDecoration(color: Colors.white),
                    children: [
                      tableTeamWithLogo(
                        team['teams']['name'],
                        team['teams']['logo_url'] ?? '',
                      ),
                      tableCellBody(team['matches_played'].toString()),
                      tableCellBody(team['wins'].toString()),
                      tableCellBody(team['draws'].toString()),
                      tableCellBody(team['losses'].toString()),
                      // tableCellBody((team['goals_for'] - team['goals_against']).toString()),
                      tableCellBody(team['points'].toString()),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            groupA.isNotEmpty ? buildGroupTable("A", groupA) : const SizedBox(),
            groupB.isNotEmpty ? buildGroupTable("B", groupB) : const SizedBox(),
            groupC.isNotEmpty ? buildGroupTable("C", groupC) : const SizedBox(),
            groupD.isNotEmpty ? buildGroupTable("D", groupD) : const SizedBox(),
            groupE.isNotEmpty ? buildGroupTable("E", groupE) : const SizedBox(),
            _buildBannerAd2(),
            groupF.isNotEmpty ? buildGroupTable("F", groupF) : const SizedBox(),
            groupG.isNotEmpty ? buildGroupTable("G", groupG) : const SizedBox(),
            groupH.isNotEmpty ? buildGroupTable("H", groupH) : const SizedBox(),
            groupI.isNotEmpty ? buildGroupTable("I", groupI) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget tableCellHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    child: Center(
      child: Text(
        text,
        style: AppTextStyle.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );

  Widget tableCellBody(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 20, left: 8, right: 8),
    child: Center(
      child: Text(
        text,
        style: AppTextStyle.label.copyWith(
          color: AppColors.black,
          fontSize: 14,
        ),
      ),
    ),
  );

  Widget tableTeamWithLogo(String teamName, String logoUrl) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 16, left: 8, right: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          logoUrl,
          width: 28,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 24),
        ),
        const SizedBox(width: 8, height: 10),
        Expanded(
          child: Text(
            teamName,
            style: AppTextStyle.label.copyWith(
              color: AppColors.black,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget buildKnockoutTab() {
    if (loadingKnockout) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    // Cek jika semua kosong
    final hasData = knockoutMatches.values.any((list) => list.isNotEmpty);
    if (!hasData) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada jadwal knockout",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    Widget buildStage(String label, String stageKey) {
      final matches = knockoutMatches[stageKey] ?? [];
      if (matches.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 18,
              top: 8,
              bottom: 16,
            ),
            child: Text(
              label,
              style: AppTextStyle.label.copyWith(
                color: AppColors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: matches.length + 1,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            itemBuilder: (context, index) {
              if (matches.length > 0 && index == 1) {
                return _buildBannerAd3();
              }

              final match = index > 1 ? matches[index - 1] : matches[index];
              // ...copy UI card pertandingan kamu, pakai FutureBuilder TeamModel juga
              // Lihat referensi buildMatchList
              return FutureBuilder<List<TeamModel?>>(
                future: Future.wait([
                  teamService.getTeamById(match.teamA),
                  teamService.getTeamById(match.teamB),
                ]),
                builder: (context, teamSnapshot) {
                  if (!teamSnapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final teamA = teamSnapshot.data![0];
                  final teamB = teamSnapshot.data![1];

                  return GestureDetector(
                    onTap: () {
                      Map<String, dynamic> json = match.toJson();
                      json['team_a_team'] = teamA?.toJson();
                      json['team_b_team'] = teamB?.toJson();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MatchDetailScreen(
                                matchModel: MatchModel.fromJson(json),
                              ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    showTeamLogo(teamA?.logoUrl ?? '', 48, 48),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        shortTeamName(teamA!.name, 2),
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (match.status == 'upcoming')
                                      Column(
                                        children: [
                                          Text(
                                            DateFormat(
                                              'd MMM yyyy',
                                              'id_ID',
                                            ).format(match.matchTime.toLocal()),
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${DateFormat('HH:mm', 'id_ID').format(match.matchTime.toLocal())} WIB",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              shortTeamName(match.location, 5),
                                              style: AppTextStyle.label
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (match.status == 'live' ||
                                        match.status == 'ongoing')
                                      Column(
                                        children: [
                                          Text(
                                            "Hari ini",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${match.scoreA} - ${match.scoreB}",
                                            style: AppTextStyle.label2.copyWith(
                                              color: AppColors.black,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          LiveBadge(),
                                        ],
                                      ),
                                    if (match.status == 'done')
                                      Column(
                                        children: [
                                          Text(
                                            "${DateFormat('HH:mm', 'id_ID').format(match.matchTime.toLocal())} WIB, ${DateFormat('d MMM yyyy', 'id_ID').format(match.matchTime.toLocal())}",
                                            style: AppTextStyle.label.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${match.scoreA} - ${match.scoreB}",
                                            style: AppTextStyle.label2.copyWith(
                                              color: AppColors.black,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          DoneBadge(),
                                        ],
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    showTeamLogo(teamB?.logoUrl ?? '', 48, 48),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        shortTeamName(teamB!.name, 2),
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStage("Semifinal", "semifinal"),
            buildStage("Perebutan Juara 3", "third_place"),
            buildStage("Final", "final"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingSeason) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    if (seasonId == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada season aktif!')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text(
          "Jadwal & Klasemen",
          style: AppTextStyle.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          labelColor: AppColors.white,
          labelStyle: AppTextStyle.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          controller: _tabController,
          indicatorColor: AppColors.black,
          indicatorWeight: 3,
          tabs: matchTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: buildMatchList()),
          buildStandingsTab(),
          buildKnockoutTab(),
        ],
      ),
    );
  }
}
