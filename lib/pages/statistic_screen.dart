import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/services/season_service.dart';
import 'package:piala_presiden_apk/services/statistic_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:piala_presiden_apk/widgets/statistic_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> topScorers = [];
  List<Map<String, dynamic>> topAssists = [];
  List<Map<String, dynamic>> topYellowCards = [];
  List<Map<String, dynamic>> topRedCards = [];
  bool loadingTopScorer = true;
  bool loadingTopAssist = true;
  bool loadingTopYellowCard = true;
  bool loadingTopRedCard = true;
  String? seasonId;
  bool loadingSeason = true;

  BannerAd? _bannerAd;
  BannerAd? _bannerAd2;
  BannerAd? _bannerAd3;
  BannerAd? _bannerAd4;

  final seasonService = SeasonService(client: Supabase.instance.client);
  final statisticService = StatisticService(client: Supabase.instance.client);

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
    _loadActiveSeason();
    _loadBannerAd();
    _loadBannerAd2();
    _loadBannerAd3();
    _loadBannerAd4();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
    _bannerAd2?.dispose();
    _bannerAd3?.dispose();
    _bannerAd4?.dispose();
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

  void _loadBannerAd4() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd4 = ad as BannerAd;
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
            margin: const EdgeInsets.only(bottom: 16, top: 8),
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
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            width: _bannerAd2!.size.width.toDouble(),
            height: _bannerAd2!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd2!),
          ),
        )
        : Container();
  }

  Widget _buildBannerAd3() {
    return (_bannerAd3 != null)
        ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            width: _bannerAd3!.size.width.toDouble(),
            height: _bannerAd3!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd3!),
          ),
        )
        : Container();
  }

  Widget _buildBannerAd4() {
    return (_bannerAd4 != null)
        ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            width: _bannerAd4!.size.width.toDouble(),
            height: _bannerAd4!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd4!),
          ),
        )
        : Container();
  }

  Future<void> _loadActiveSeason() async {
    setState(() => loadingSeason = true);
    final season = await seasonService.getActiveSeason();
    if (season != null) {
      seasonId = season.id;
      fetchTopScorers(seasonId!);
      fetchTopAssists(seasonId!);
      fetchTopYellowCard(seasonId!);
      fetchTopRedCard(seasonId!);
    }
  }

  Future<void> fetchTopScorers(String seasonId) async {
    setState(() => loadingTopScorer = true);
    final scorers = await statisticService.getTopScorers(seasonId);
    setState(() {
      loadingSeason = false;
      topScorers = scorers;
      loadingTopScorer = false;
    });
  }

  Future<void> fetchTopAssists(String seasonId) async {
    setState(() => loadingTopAssist = true);
    final assists = await statisticService.getTopAssists(seasonId);
    setState(() {
      loadingSeason = false;
      topAssists = assists;
      loadingTopAssist = false;
    });
  }

  Future<void> fetchTopYellowCard(String seasonId) async {
    setState(() => loadingTopYellowCard = true);
    final yellowCards = await statisticService.getTopYellowCard(seasonId);
    setState(() {
      loadingSeason = false;
      topYellowCards = yellowCards;
      loadingTopYellowCard = false;
    });
  }

  Future<void> fetchTopRedCard(String seasonId) async {
    setState(() => loadingTopRedCard = true);
    final redCards = await statisticService.getTopRedCard(seasonId);
    setState(() {
      loadingSeason = false;
      topRedCards = redCards;
      loadingTopRedCard = false;
    });
  }

  Widget buildTopSkorTab() {
    if (loadingTopScorer) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    if (topScorers.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada statistik",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          children: [
            StatisticCard(
              rank: topScorers[0]['rank'],
              name: topScorers[0]['name'],
              teamName: topScorers[0]['team_name'],
              teamLogo: topScorers[0]['team_logo'],
              photoUrl: topScorers[0]['photo_url'],
              value: topScorers[0]['goals'],
              valueLabel: "Gol",
              icon: Icons.sports_soccer,
              isMain: true,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topScorers.length - 1,
              itemBuilder: (context, idx) {
                final scorer = topScorers[idx + 1];
                return StatisticCard(
                  rank: scorer['rank'],
                  name: scorer['name'],
                  teamName: scorer['team_name'],
                  teamLogo: scorer['team_logo'],
                  photoUrl: scorer['photo_url'],
                  value: scorer['goals'],
                  valueLabel: "Gol",
                  icon: Icons.sports_soccer,
                  isMain: false,
                );
              },
            ),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget buildTopAssistTab() {
    if (loadingTopAssist) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    if (topAssists.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada statistik",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          children: [
            StatisticCard(
              rank: topAssists[0]['rank'],
              name: topAssists[0]['name'],
              teamName: topAssists[0]['team_name'],
              teamLogo: topAssists[0]['team_logo'],
              photoUrl: topAssists[0]['photo_url'],
              value: topAssists[0]['assists'],
              valueLabel: "Assist",
              icon: Icons.handshake,
              isMain: true,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topAssists.length - 1,
              itemBuilder: (context, idx) {
                final assist = topAssists[idx + 1];
                return StatisticCard(
                  rank: assist['rank'],
                  name: assist['name'],
                  teamName: assist['team_name'],
                  teamLogo: assist['team_logo'],
                  photoUrl: assist['photo_url'],
                  value: assist['assists'],
                  valueLabel: "Assist",
                  icon: Icons.handshake,
                  isMain: false,
                );
              },
            ),
            _buildBannerAd2(),
          ],
        ),
      ),
    );
  }

  Widget buildTopYellowCard() {
    if (loadingTopYellowCard) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    if (topYellowCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada statistik",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          children: [
            StatisticCard(
              rank: topYellowCards[0]['rank'],
              name: topYellowCards[0]['name'],
              teamName: topYellowCards[0]['team_name'],
              teamLogo: topYellowCards[0]['team_logo'],
              photoUrl: topYellowCards[0]['photo_url'],
              value: topYellowCards[0]['cards'],
              valueLabel: "Kartu kuning",
              icon: Icons.square,
              iconColor: Colors.amber,
              isMain: true,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topYellowCards.length - 1,
              itemBuilder: (context, idx) {
                final card = topYellowCards[idx + 1];
                return StatisticCard(
                  rank: card['rank'],
                  name: card['name'],
                  teamName: card['team_name'],
                  teamLogo: card['team_logo'],
                  photoUrl: card['photo_url'],
                  value: card['cards'],
                  valueLabel: "Kartu kuning",
                  icon: Icons.square,
                  iconColor: Colors.amber,
                  isMain: false,
                );
              },
            ),
            _buildBannerAd3(),
          ],
        ),
      ),
    );
  }

  Widget buildTopRedCard() {
    if (loadingTopRedCard) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      );
    }

    if (topRedCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada statistik",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          children: [
            StatisticCard(
              rank: topRedCards[0]['rank'],
              name: topRedCards[0]['name'],
              teamName: topRedCards[0]['team_name'],
              teamLogo: topRedCards[0]['team_logo'],
              photoUrl: topRedCards[0]['photo_url'],
              value: topRedCards[0]['cards'],
              valueLabel: "Kartu",
              icon: Icons.square,
              iconColor: Colors.red,
              isMain: true,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topRedCards.length - 1,
              itemBuilder: (context, idx) {
                final card = topRedCards[idx + 1];
                return StatisticCard(
                  rank: card['rank'],
                  name: card['name'],
                  teamName: card['team_name'],
                  teamLogo: card['team_logo'],
                  photoUrl: card['photo_url'],
                  value: card['cards'],
                  valueLabel: "Kartu",
                  icon: Icons.square,
                  iconColor: Colors.red,
                  isMain: false,
                );
              },
            ),
            _buildBannerAd4(),
          ],
        ),
      ),
    );
  }

  Widget buildOtherTab(String label) {
    return Center(
      child: Text(
        "$label akan segera tersedia...",
        style: AppTextStyle.label.copyWith(color: Colors.white),
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
          "Statistik Pertandingan",
          style: AppTextStyle.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          isScrollable: true,
          labelColor: AppColors.white,
          labelStyle: AppTextStyle.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Top Skor"),
            Tab(text: "Top Assist"),
            Tab(text: "Kartu Kuning"),
            Tab(text: "Kartu Merah"),
            // Tab(text: "Top Save"),
            // Tab(text: "Best Player"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTopSkorTab(),
          buildTopAssistTab(),
          buildTopYellowCard(),
          buildTopRedCard(),
          // buildOtherTab("Top Save"),
          // buildOtherTab("Top Save"),
          // buildOtherTab("Best Player"),
        ],
      ),
    );
  }
}
