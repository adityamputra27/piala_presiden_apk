import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:piala_presiden_apk/services/news_service.dart';
import 'package:piala_presiden_apk/utils/ad_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/models/news_model.dart';
import 'package:piala_presiden_apk/pages/news_detail_screen.dart';
import 'package:scrollable_tab_view/scrollable_tab_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/global_navigator.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsModel>> newsFuture;
  String? selectedCategory;
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;
  NewsModel? selectedNews;

  BannerAd? _bannerAd;
  final newsService = NewsService(client: Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    newsFuture = newsService.fetchNewsLastWeek();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
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
                      (context) => NewsDetailScreen(newsModel: selectedNews!),
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

  Widget _buildNewsCard(NewsModel newsData) {
    return GestureDetector(
      onTap: () {
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
                builder: (context) => NewsDetailScreen(newsModel: newsData),
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
              builder: (context) => NewsDetailScreen(newsModel: newsData),
            ),
          );
        }
        setState(() {
          selectedNews = newsData;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: newsData.thumbnailUrl,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsData.title,
                    style: AppTextStyle.label.copyWith(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        newsData.getTimeAgo(),
                        style: AppTextStyle.label.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: AppColors.black),
                          Text(
                            "dittmptrr27",
                            style: AppTextStyle.label.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(List<NewsModel> newsData, String category) {
    final filtered =
        category == "All"
            ? newsData
            : newsData.where((n) => n.category == category).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            "Belum ada berita di kategori ini.",
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 24),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(filtered[index]);
        },
      ),
    );
  }

  final categories = const [
    'Tim Nasional',
    'Klub',
    'Pertandingan',
    'Pemain',
    'Turnamen',
    'Transfer',
    'Statistik',
    'Opini',
    'Cedera & Sanksi',
    'Off The Pitch',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        centerTitle: true,
        title: Text(
          'Berita Terkini',
          style: AppTextStyle.label.copyWith(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder<List<NewsModel>>(
              future: newsFuture,
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
                  return Container(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(
                      child: Text(
                        "Belum ada berita di kategori ini.",
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                final newsData = snapshot.data!;
                return SingleChildScrollView(
                  child: ScrollableTab(
                    indicatorWeight: 1,
                    indicatorColor: AppColors.black,
                    unselectedLabelColor: Colors.grey[400],
                    unselectedLabelStyle: AppTextStyle.label.copyWith(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    labelStyle: AppTextStyle.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    labelColor: AppColors.black,
                    padding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    useMaxWidth: true,
                    tabBarAlignment: TabAlignment.start,
                    tabAlignment: Alignment.centerLeft,
                    onTap: (index) {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    tabs: categories.map((cat) => Tab(text: cat)).toList(),
                    children:
                        categories
                            .map((cat) => buildTabContent(newsData, cat))
                            .toList(),
                  ),
                );
              },
            ),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }
}
