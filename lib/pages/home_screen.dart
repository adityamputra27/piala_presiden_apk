import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/data/local_notification_db.dart';
import 'package:piala_presiden_apk/models/match_model.dart';
import 'package:piala_presiden_apk/models/team_model.dart';
import 'package:piala_presiden_apk/pages/match_detail_screen.dart';
import 'package:piala_presiden_apk/pages/notification_screen.dart';
import 'package:piala_presiden_apk/pages/players_screen.dart';
import 'package:piala_presiden_apk/provider/notification_provider.dart';
import 'package:piala_presiden_apk/services/match_service.dart';
import 'package:piala_presiden_apk/services/notification_service.dart';
import 'package:piala_presiden_apk/services/season_service.dart';
import 'package:piala_presiden_apk/services/team_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:piala_presiden_apk/widgets/live_badge.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/global_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final teamService = TeamService(client: Supabase.instance.client);
  final matchService = MatchService(client: Supabase.instance.client);
  final seasonService = SeasonService(client: Supabase.instance.client);
  final notificationService = NotificationService(
    client: Supabase.instance.client,
  );

  // State masing-masing section
  String? seasonId;
  bool loadingSeason = true;

  bool loadingClubs = true;
  bool loadingUpcoming = true;
  List<TeamModel> teams = [];
  List<MatchModel> upcomingMatches = [];
  MatchModel? selectedMatch;

  InterstitialAd? _interstitialAd;
  InterstitialAd? _interstitialAd2;
  InterstitialAd? _interstitialAd3;
  bool isInterstitialAdLoaded = false;
  bool isInterstitialAd2Loaded = false;
  bool isInterstitialAd3Loaded = false;
  TeamModel? selectedClub;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _loadUpcoming();
    _loadActiveSeason();
    _loadInterstitialAd();
    _loadInterstitialAd2();
    _loadBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    notificationService.dispose();
    _interstitialAd?.dispose();
    _interstitialAd2?.dispose();
    _interstitialAd3?.dispose();
    _bannerAd?.dispose();
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
                  builder: (context) => PlayersScreen(club: selectedClub!),
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

  void _loadInterstitialAd2() {
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
            _interstitialAd2 = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('error interstitial ad');
        },
      ),
    );
  }

  void _loadInterstitialAd3() {
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
            _interstitialAd3 = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('error interstitial ad');
        },
      ),
    );
  }

  Future<void> _loadActiveSeason() async {
    setState(() => loadingSeason = true);
    final season = await seasonService.getActiveSeason();
    if (season != null) {
      seasonId = season.id;
      // Langsung fetch klub dan upcoming begitu dapat seasonId
      _loadTeams();
      _loadUpcoming();
    }
    setState(() => loadingSeason = false);
  }

  Future<void> _loadTeams() async {
    if (seasonId == null) return;
    setState(() => loadingClubs = true);
    final fetchedTeams = await teamService.getTeamsBySeason(seasonId!);
    setState(() {
      teams = fetchedTeams;
      loadingClubs = false;
    });
  }

  Future<void> _loadUpcoming() async {
    if (seasonId == null) return;
    setState(() => loadingUpcoming = true);
    final fetchedUpcoming = await matchService.getUpcomingMatches(seasonId!);
    setState(() {
      upcomingMatches = fetchedUpcoming;
      loadingUpcoming = false;
    });
  }

  Widget showTeamLogo(String url, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.network(url, fit: BoxFit.contain),
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
        return value;
    }
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://dittmptrr27.com/contact.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

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
      // ... AppBar, dsb
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: AppColors.black,
          title: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 2),
                    Image.asset(
                      "assets/images/logo/logo-piala-presiden.jpeg",
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat Datang di,",
                      style: AppTextStyle.label.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Piala Presiden App 2025",
                      style: AppTextStyle.label.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          centerTitle: false,
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.info_outline, color: Colors.white),
            //   onPressed: _launchURL,
            // ),
            Stack(
              children: [
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                StreamBuilder<int>(
                  stream: Stream.periodic(
                    Duration(seconds: 5),
                  ).asyncMap((_) => LocalNotificationDb().getUnreadCount()),
                  builder: (context, snapshot) {
                    int count = snapshot.data ?? 0;
                    return count > 0
                        ? Positioned(
                          right: 5,
                          top: 3,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$count",
                              style: AppTextStyle.label.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        : const SizedBox();
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Klub Section ----
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                child: Text(
                  'Daftar Klub',
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child:
                    loadingClubs
                        ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary,
                            ),
                          ),
                        )
                        : teams.isEmpty
                        ? Center(
                          child: Text(
                            'Belum ada tim',
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        )
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: teams.length,
                          itemBuilder: (context, index) {
                            final club = teams[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    customBorder: const CircleBorder(),
                                    splashColor:
                                        Colors.grey[300], // warna abu ripple
                                    onTap: () {
                                      // Pindah ke halaman PlayersScreen
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
                                                  (context) => PlayersScreen(
                                                    club:
                                                        club, // lempar objek club/ID-nya
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
                                                (context) => PlayersScreen(
                                                  club:
                                                      club, // lempar objek club/ID-nya
                                                ),
                                          ),
                                        );
                                      }

                                      setState(() {
                                        selectedClub = club;
                                      });
                                    },
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Image.network(
                                            club.logoUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width:
                                        72, // Fixed width supaya rapi sejajar
                                    child: Text(
                                      shortTeamName(club.name, 2),
                                      style: AppTextStyle.label,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),

              // ---- Live Matches Section ----
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 4,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pertandingan Live',
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     'Lihat Semua',
                    //     style: AppTextStyle.body.copyWith(
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: StreamBuilder<List<MatchModel>>(
                  stream: matchService.watchLiveMatches(seasonId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "Belum ada pertandingan live",
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }

                    final liveMatches = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: liveMatches.length,
                      itemBuilder: (context, index) {
                        final match = liveMatches[index];
                        // Ambil data tim A dan tim B secara async
                        return FutureBuilder<List<TeamModel?>>(
                          future: Future.wait([
                            teamService.getTeamById(match.teamA),
                            teamService.getTeamById(match.teamB),
                          ]),
                          builder: (context, teamSnapshot) {
                            if (!teamSnapshot.hasData) {
                              return SizedBox(
                                width: 320,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final teamA = teamSnapshot.data![0];
                            final teamB = teamSnapshot.data![1];

                            // UI sama persis dengan template kamu
                            return GestureDetector(
                              onTap: () {
                                Map<String, dynamic> json = match.toJson();
                                json['team_a_team'] = teamA?.toJson();
                                json['team_b_team'] = teamB?.toJson();

                                setState(() {
                                  selectedMatch = MatchModel.fromJson(json);
                                });
                                if (!isInterstitialAd3Loaded) {
                                  if (_interstitialAd3 != null) {
                                    _interstitialAd3?.show();
                                    setState(() {
                                      isInterstitialAd3Loaded = true;
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MatchDetailScreen(
                                              matchModel: MatchModel.fromJson(
                                                json,
                                              ),
                                            ),
                                      ),
                                    );
                                    setState(() {
                                      isInterstitialAd3Loaded = true;
                                    });
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MatchDetailScreen(
                                            matchModel: MatchModel.fromJson(
                                              json,
                                            ),
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Card(
                                    color: Colors.black,
                                    margin: const EdgeInsets.only(right: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      width: 320,
                                      padding: const EdgeInsets.only(
                                        left: 22,
                                        right: 22,
                                        top: 18,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(match.matchTime.toLocal())} WIB",
                                                style: AppTextStyle.label
                                                    .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[900],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  stageLabel(match.stage),
                                                  style: AppTextStyle.label
                                                      .copyWith(
                                                        color: AppColors.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    showTeamLogo(
                                                      teamA?.logoUrl ?? '',
                                                      50,
                                                      50,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      shortTeamName(
                                                        teamA?.name ?? '-',
                                                        1,
                                                      ),
                                                      style: AppTextStyle.label
                                                          .copyWith(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 4,
                                                          ),
                                                      child: Text(
                                                        "${match.scoreA} - ${match.scoreB}",
                                                        style: AppTextStyle
                                                            .label2
                                                            .copyWith(
                                                              color:
                                                                  AppColors
                                                                      .white,
                                                              fontSize: 32,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    showTeamLogo(
                                                      teamB?.logoUrl ?? '',
                                                      50,
                                                      50,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      shortTeamName(
                                                        teamB?.name ?? '-',
                                                        1,
                                                      ),
                                                      style: AppTextStyle.label
                                                          .copyWith(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 28,
                                        right: 22,
                                      ),
                                      child: LiveBadge(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // ---- Upcoming Matches Section ----
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 32,
                  right: 16,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jadwal Pertandingan',
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     'Lihat Semua',
                    //     style: AppTextStyle.body.copyWith(
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              loadingUpcoming
                  ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                    ),
                  )
                  : upcomingMatches.isEmpty
                  ? Center(
                    child: Text(
                      "Belum ada jadwal pertandingan",
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  )
                  : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: upcomingMatches.length,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 0,
                    ),
                    itemBuilder: (context, index) {
                      final match = upcomingMatches[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMatch = match;
                          });

                          if (!isInterstitialAd2Loaded) {
                            if (_interstitialAd2 != null) {
                              _interstitialAd2?.show();
                              setState(() {
                                isInterstitialAd2Loaded = true;
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          MatchDetailScreen(matchModel: match),
                                ),
                              );
                              setState(() {
                                isInterstitialAd2Loaded = true;
                              });
                            }
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        MatchDetailScreen(matchModel: match),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Tim A
                                    Column(
                                      children: [
                                        showTeamLogo(
                                          match.teamAObj!.logoUrl,
                                          48,
                                          48,
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 72, // samakan width antar team
                                          child: Text(
                                            shortTeamName(
                                              match.teamAObj!.name,
                                              2,
                                            ),
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
                                    // Tanggal Pertandingan
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
                                      ],
                                    ),
                                    // Tim B
                                    Column(
                                      children: [
                                        showTeamLogo(
                                          match.teamBObj!.logoUrl,
                                          48,
                                          48,
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 72,
                                          child: Text(
                                            shortTeamName(
                                              match.teamBObj!.name,
                                              2,
                                            ),
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
                  ),
              _buildBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}
