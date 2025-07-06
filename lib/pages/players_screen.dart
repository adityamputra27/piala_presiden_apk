import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/models/team_model.dart';
import 'package:piala_presiden_apk/services/player_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayersScreen extends StatefulWidget {
  final TeamModel club;
  const PlayersScreen({super.key, required this.club});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  late final PlayerService playerService;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    playerService = PlayerService(client: Supabase.instance.client);
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
            margin: const EdgeInsets.only(bottom: 10, top: 24),
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        )
        : Container();
  }

  Widget buildPlayerCard(Map<String, dynamic> player) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Row(
          children: [
            const SizedBox(width: 10),
            ClipOval(
              child: Image.network(
                player['photo_url'],
                width: 44,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Icon(Icons.person, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['name'] ?? '-',
                    style: AppTextStyle.label.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          player['position'] ?? '-',
                          style: AppTextStyle.label.copyWith(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (player['nationality_icon'] != null &&
                          player['nationality_icon'].toString().isNotEmpty)
                        Text(
                          player['nationality_icon'],
                          style: AppTextStyle.label.copyWith(fontSize: 13),
                        ),
                      if (player['nationality_name'] != null &&
                          player['nationality_name'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            player['nationality_name'],
                            style: AppTextStyle.label.copyWith(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${player['height_cm'] ?? '-'} cm',
                        style: AppTextStyle.label.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      // Text(
                      //   '${player['weight_kg'] ?? '-'} kg',
                      //   style: AppTextStyle.label.copyWith(fontSize: 12),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 24,
              child: Text(
                (player['jersey_number'] ?? '-').toString(),
                style: AppTextStyle.label.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          club.name,
          style: AppTextStyle.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.black,
        centerTitle: true,
      ),
      backgroundColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(club.logoUrl, width: 48, height: 48),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Pelatih: ${club.coach ?? '-'}',
                    style: AppTextStyle.label.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              "Daftar Pemain",
              style: AppTextStyle.label.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: playerService.getPlayersByTeam(club.id),
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
                        'Belum ada pemain',
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  final players = snapshot.data!;
                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return buildPlayerCard(players[index]);
                    },
                  );
                },
              ),
            ),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }
}
