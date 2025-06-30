import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/models/match_model.dart';
import 'package:piala_presiden_apk/services/match_service.dart';
import 'package:piala_presiden_apk/services/player_service.dart';
import 'package:piala_presiden_apk/services/team_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:piala_presiden_apk/widgets/done_badge.dart';
import 'package:piala_presiden_apk/widgets/live_badge.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetailScreen extends StatefulWidget {
  final MatchModel matchModel;
  const MatchDetailScreen({super.key, required this.matchModel});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  int selectedTab = 1; // 0 = live, 1 = highlight

  // String? getYoutubeThumbnail(String? url) {
  //   if (url == null) return null;
  //   final uri = Uri.tryParse(url);
  //   if (uri == null) return null;
  //   if (uri.host.contains("youtube")) {
  //     final videoId = uri.queryParameters['v'];
  //     if (videoId != null) {
  //       return "https://img.youtube.com/vi/$videoId/0.jpg";
  //     }
  //   }
  //   if (uri.host.contains("youtu.be")) {
  //     final videoId =
  //         uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  //     if (videoId != null) {
  //       return "https://img.youtube.com/vi/$videoId/0.jpg";
  //     }
  //   }
  //   return null;
  // }

  // String shortTeamName(String name, int wordTake) {
  //   final words = name.trim().split(RegExp(r'\s+'));
  //   return words.take(wordTake).join(' ');
  // }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void _onRefresh() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  final playerService = PlayerService(client: Supabase.instance.client);
  final teamService = TeamService(client: Supabase.instance.client);
  final matchService = MatchService(client: Supabase.instance.client);

  Stream<MatchModel> get matchStream =>
      Supabase.instance.client
          .from('matches')
          .stream(primaryKey: ['id'])
          .eq('id', widget.matchModel.id)
          .limit(1)
          .map((event) => MatchModel.fromJson(event.first))
          .asBroadcastStream();

  Stream<List<Map<String, dynamic>>> get eventsStream =>
      Supabase.instance.client
          .from('match_events')
          .stream(primaryKey: ['id'])
          .eq('match_id', widget.matchModel.id)
          .order('minute')
          .map(
            (rows) => rows.where((e) => e['event_type'] != 'assist').toList(),
          )
          .asBroadcastStream();

  Stream<Map<String, dynamic>?> get statsStream =>
      Supabase.instance.client
          .from('match_stats')
          .stream(primaryKey: ['match_id', 'team_id'])
          .eq('match_id', widget.matchModel.id)
          .map((rows) {
            if (rows.length < 2) return null;
            return {'A': rows[0], 'B': rows[1]};
          })
          .asBroadcastStream();

  String? getYoutubeThumbnail(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains("youtube")) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null) {
        return "https://img.youtube.com/vi/$videoId/0.jpg";
      }
    }
    if (uri.host.contains("youtu.be")) {
      final videoId =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (videoId != null) {
        return "https://img.youtube.com/vi/$videoId/0.jpg";
      }
    }
    return null;
  }

  String shortTeamName(String name, int wordTake) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(wordTake).join(' ');
  }

  IconData iconForEvent(String type) {
    switch (type) {
      case "goal":
        return Icons.sports_soccer;
      case "yellow_card":
        return Icons.square;
      case "red_card":
        return Icons.square;
      case "own_goal":
        return Icons.warning_amber;
      default:
        return Icons.info;
    }
  }

  Color colorForEvent(String type) {
    switch (type) {
      case "goal":
        return Colors.black;
      case "yellow_card":
        return Colors.yellow[800]!;
      case "red_card":
        return Colors.red[700]!;
      case "own_goal":
        return Colors.red[300]!;
      default:
        return AppColors.secondary;
    }
  }

  Widget eventRowLeft(Map<String, dynamic>? event) {
    if (event == null) return const SizedBox();
    return Row(
      children: [
        Text(
          "'${event['minute']}",
          style: AppTextStyle.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          iconForEvent(event['event_type']),
          color: colorForEvent(event['event_type']),
          size: 18,
        ),
        const SizedBox(width: 6),
        FutureBuilder(
          future: playerService.getPlayerById(event['player_id']),
          builder: (context, playerSnapshot) {
            final hasData = playerSnapshot.hasData;
            final data = playerSnapshot.data;
            if (!hasData) {
              return Expanded(
                child: Text(
                  "loading...",
                  style: AppTextStyle.label.copyWith(fontSize: 12),
                ),
              );
            }
            return Expanded(
              child: Text(
                "${data!['name']}",
                style: AppTextStyle.label.copyWith(fontSize: 12),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget eventRowRight(Map<String, dynamic>? event) {
    if (event == null) return const SizedBox();
    return Row(
      children: [
        FutureBuilder(
          future: playerService.getPlayerById(event['player_id']),
          builder: (context, playerSnapshot) {
            final hasData = playerSnapshot.hasData;
            final data = playerSnapshot.data;
            if (!hasData) {
              return Expanded(
                child: Text(
                  "loading...",
                  style: AppTextStyle.label.copyWith(fontSize: 12),
                ),
              );
            }
            return Expanded(
              child: Text(
                "${data!['name']}",
                style: AppTextStyle.label.copyWith(fontSize: 12),
              ),
            );
          },
        ),
        Icon(
          iconForEvent(event['event_type']),
          color: colorForEvent(event['event_type']),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          "'${event['minute']}",
          style: AppTextStyle.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget buildStatsBar({
    required String label,
    required int valueA,
    required int valueB,
    String? unit,
    Color colorA = Colors.blue,
    Color colorB = Colors.red,
    int max = 100, // default untuk persen, tapi shots/corners dll bisa lebih
  }) {
    final total = (valueA + valueB) == 0 ? 1 : valueA + valueB;
    final leftRatio = valueA / total;
    final rightRatio = valueB / total;
    final font = AppTextStyle.label.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: font.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  "$valueA${unit ?? ''}",
                  style: font.copyWith(color: AppColors.black),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: (leftRatio * 1000).toInt(),
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: colorA,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(9),
                                bottomLeft: Radius.circular(9),
                                topRight: Radius.circular(
                                  rightRatio == 0 ? 9 : 0,
                                ),
                                bottomRight: Radius.circular(
                                  rightRatio == 0 ? 9 : 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (rightRatio * 1000).toInt(),
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: colorB,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(9),
                                bottomRight: Radius.circular(9),
                                topLeft: Radius.circular(
                                  leftRatio == 0 ? 9 : 0,
                                ),
                                bottomLeft: Radius.circular(
                                  leftRatio == 0 ? 9 : 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  "$valueB${unit ?? ''}",
                  style: font.copyWith(color: AppColors.black),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ],
      ),
    );
  }

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
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
            margin: const EdgeInsets.only(bottom: 16, top: 12),
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: StreamBuilder<MatchModel>(
          stream: matchStream,
          builder: (context, snapshot) {
            final match = widget.matchModel;
            final teamA = match.teamAObj!;
            final teamB = match.teamBObj!;
            return Text(
              "${teamA.name} vs ${teamB.name}",
              style: AppTextStyle.label.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        backgroundColor: AppColors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: WaterDropHeader(waterDropColor: AppColors.black),
        child: Stack(
          children: [
            // HEADER HITAM
            Container(
              width: double.infinity,
              height: height * 0.4,
              color: AppColors.black,
            ),
            // BODY
            SingleChildScrollView(
              child: StreamBuilder<MatchModel>(
                stream: matchStream,
                builder: (context, matchSnapshot) {
                  final match = widget.matchModel;
                  final teamA = match.teamAObj!;
                  final teamB = match.teamBObj!;
                  final status = match.status;
                  final scoreA = matchSnapshot.data?.scoreA ?? match.scoreA;
                  final scoreB = matchSnapshot.data?.scoreB ?? match.scoreB;

                  return Column(
                    children: [
                      // CARD SKOR
                      Container(
                        margin: const EdgeInsets.only(
                          top: 16,
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // LOGO - SKOR - LOGO
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Image.network(
                                      teamA.logoUrl,
                                      width: 60,
                                      height: 60,
                                      errorBuilder:
                                          (c, e, s) => const Icon(
                                            Icons.shield,
                                            size: 60,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        teamA.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (status == 'upcoming')
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
                                    if (status == 'live' || status == 'ongoing')
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
                                            "${scoreA ?? 0} - ${scoreB ?? 0}",
                                            style: AppTextStyle.label2.copyWith(
                                              color: AppColors.black,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          LiveBadge(),
                                        ],
                                      ),
                                    if (status == 'done')
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
                                            "$scoreA - $scoreB",
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
                                    Image.network(
                                      teamB.logoUrl,
                                      width: 60,
                                      height: 60,
                                      errorBuilder:
                                          (c, e, s) => const Icon(
                                            Icons.shield,
                                            size: 60,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        teamB.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // TAB VIDEO
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(() => selectedTab = 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            selectedTab == 0
                                                ? AppColors.black
                                                : Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        border: Border.all(
                                          color:
                                              selectedTab == 0
                                                  ? AppColors.black
                                                  : Colors.grey[400]!,
                                          width: 1.1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.live_tv,
                                            color:
                                                selectedTab == 0
                                                    ? Colors.white
                                                    : AppColors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Live",
                                            style: AppTextStyle.label.copyWith(
                                              color:
                                                  selectedTab == 0
                                                      ? Colors.white
                                                      : AppColors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(() => selectedTab = 1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            selectedTab == 1
                                                ? AppColors.black
                                                : Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        border: Border.all(
                                          color:
                                              selectedTab == 1
                                                  ? AppColors.black
                                                  : Colors.grey[400]!,
                                          width: 1.1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.ondemand_video_rounded,
                                            color:
                                                selectedTab == 1
                                                    ? Colors.white
                                                    : AppColors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Highlight",
                                            style: AppTextStyle.label.copyWith(
                                              color:
                                                  selectedTab == 1
                                                      ? Colors.white
                                                      : AppColors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // VIDEO SECTION
                            Builder(
                              builder: (_) {
                                final highlightUrl = match.highlightLink;
                                final liveUrl = match.liveLink;
                                if (selectedTab == 0) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (liveUrl != null &&
                                          await canLaunchUrl(
                                            Uri.parse(liveUrl),
                                          )) {
                                        await launchUrl(
                                          Uri.parse(liveUrl),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 54,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (highlightUrl != null &&
                                          await canLaunchUrl(
                                            Uri.parse(highlightUrl),
                                          )) {
                                        await launchUrl(
                                          Uri.parse(highlightUrl),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              getYoutubeThumbnail(
                                                        highlightUrl,
                                                      ) !=
                                                      null
                                                  ? Image.network(
                                                    getYoutubeThumbnail(
                                                      highlightUrl,
                                                    )!,
                                                    width: double.infinity,
                                                    height: 180,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.asset(
                                                    'assets/images/background/bg-piala-presiden.jpeg', // Ganti path sesuai asset kamu!
                                                    width: double.infinity,
                                                    height: 180,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.55,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 54,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            // MATCH EVENTS SPLIT 2 COLUMN (REALTIME)
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: matchService.getMatchEventsStream(
                                widget.matchModel.id,
                              ),
                              builder: (context, eventSnapshot) {
                                final hasData = eventSnapshot.hasData;
                                if (eventSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      bottom: 20,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.secondary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (!eventSnapshot.hasData ||
                                    eventSnapshot.data!.isEmpty) {
                                  return const SizedBox(height: 24);
                                }

                                final events = eventSnapshot.data ?? [];
                                final eventsA =
                                    events
                                        .where(
                                          (e) => e["team_id"] == match.teamA,
                                        )
                                        .toList();

                                final eventsB =
                                    events
                                        .where(
                                          (e) => e["team_id"] == match.teamB,
                                        )
                                        .toList();
                                final maxRows =
                                    eventsA.length > eventsB.length
                                        ? eventsA.length
                                        : eventsB.length;

                                return Container(
                                  padding: EdgeInsets.only(
                                    top: hasData && eventsA.isNotEmpty ? 16 : 0,
                                    bottom:
                                        hasData && eventsB.isNotEmpty ? 8 : 0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tim A events
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: List.generate(maxRows, (i) {
                                            return i < eventsA.length
                                                ? Container(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 10,
                                                  ),
                                                  child: eventRowLeft(
                                                    eventsA[i],
                                                  ),
                                                )
                                                : const SizedBox(height: 24);
                                          }),
                                        ),
                                      ),
                                      // Separator
                                      Container(
                                        width: 2,
                                        height: (maxRows * 28).toDouble().clamp(
                                          32,
                                          220,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        color: Colors.transparent,
                                      ),
                                      // Tim B events
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(maxRows, (i) {
                                            return i < eventsB.length
                                                ? Container(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 10,
                                                  ),
                                                  child: eventRowRight(
                                                    eventsB[i],
                                                  ),
                                                )
                                                : const SizedBox(height: 24);
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (status == 'live' ||
                                status == 'ongoing' ||
                                status == 'done')
                              Container(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stadium,
                                      color: AppColors.mutedText,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.matchModel.location,
                                      style: AppTextStyle.label.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildBannerAd(),
                      // MATCH STATS
                      StreamBuilder<Map<String, dynamic>?>(
                        stream: matchService.getMatchStatsStream(
                          widget.matchModel.id,
                        ),
                        builder: (context, statsSnapshot) {
                          final stats = statsSnapshot.data;
                          if (statsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 20,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          // Default zero jika stats belum ada
                          final statA =
                              stats != null && stats['A'] != null
                                  ? stats['A']
                                  : {};
                          final statB =
                              stats != null && stats['B'] != null
                                  ? stats['B']
                                  : {};
                          return Container(
                            margin: const EdgeInsets.only(
                              top: 8,
                              bottom: 32,
                              left: 16,
                              right: 16,
                            ),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 24,
                              bottom: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildStatsBar(
                                  label: "Possession",
                                  valueA: statA['ball_possession'] ?? 0,
                                  valueB: statB['ball_possession'] ?? 0,
                                  unit: "%",
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Shots on Target",
                                  valueA: statA['shots_on_target'] ?? 0,
                                  valueB: statB['shots_on_target'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Total Shots",
                                  valueA: statA['total_shots'] ?? 0,
                                  valueB: statB['total_shots'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Corners",
                                  valueA: statA['corners'] ?? 0,
                                  valueB: statB['corners'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Fouls",
                                  valueA: statA['fouls'] ?? 0,
                                  valueB: statB['fouls'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Offsides",
                                  valueA: statA['offsides'] ?? 0,
                                  valueB: statB['offsides'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                                buildStatsBar(
                                  label: "Passes",
                                  valueA: statA['passes'] ?? 0,
                                  valueB: statB['passes'] ?? 0,
                                  colorA: Colors.blue,
                                  colorB: Colors.red,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
