import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/models/news_model.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel newsModel;
  const NewsDetailScreen({super.key, required this.newsModel});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  // Author constant
  static const String _authorName = "dittmptrr27";

  @override
  Widget build(BuildContext context) {
    final String timeAgo = timeago.format(
      widget.newsModel.createdAt,
      locale: 'id',
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.newsModel.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
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
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category & Time ago
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.newsModel.category.toUpperCase(),
                      style: AppTextStyle.label.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: AppTextStyle.label.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  widget.newsModel.title,
                  style: AppTextStyle.label.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
              ),
              // Author row (constant)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _authorName,
                      style: AppTextStyle.label.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 24),
                child: Html(
                  data: widget.newsModel.content,
                  style: {
                    "*": Style(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato",
                      fontSize: FontSize(14),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
