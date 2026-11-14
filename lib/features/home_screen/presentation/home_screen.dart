import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sticker_flutter/assets_helper/app_colors.dart';
import 'package:sticker_flutter/common_widgets/loading_indicators.dart';
import 'package:sticker_flutter/features/home_screen/model/pack_model.dart';
import 'package:sticker_flutter/helpers/ui_helpers.dart';
import 'package:sticker_flutter/helpers/whatsapp_sticker_service.dart';
import 'package:sticker_flutter/networks/api_acess.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getPacksRxObj.fetchPacks();
  }

  Future<void> _onRefresh() async {
    await getPacksRxObj.fetchPacks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F18),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: const Color(0xFF171A29),
        child: StreamBuilder(
          stream: getPacksRxObj.fillData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: loadingIndicatorCircle(context: context));
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmptyState();
            }

            final packsResponse = PacksResponseModel.fromJson(snapshot.data);
            final packs = packsResponse.data ?? [];

            if (packs.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: packs.length,
              separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
              itemBuilder: (context, index) {
                final pack = packs[index];
                return _buildPackCard(pack);
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF141724),
      scrolledUnderElevation: 2,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFABC1D), Color(0xFFFF8A00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.black,
              size: 20.sp,
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sticker Studio",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                "Discover trending packs",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: Icon(Icons.refresh_rounded, color: Colors.white70, size: 22.sp),
          onPressed: _onRefresh,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildPackCard(PackModel pack) {
    final stickers = pack.stickers ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171A29),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _openPackDetailsSheet(pack),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Tray Icon, Name, Identifier, Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrayIcon(pack.trayIcon),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pack.name ?? "Unnamed Pack",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            pack.identifier ?? "ID: ${pack.id ?? '-'}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(pack.status),
                  ],
                ),

                UIHelper.verticalSpace(14.h),

                // Sticker preview row
                if (stickers.isNotEmpty) ...[
                  SizedBox(
                    height: 80.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: stickers.length,
                      separatorBuilder: (context, index) => UIHelper.horizontalSpace(8.w),
                      itemBuilder: (context, sIndex) {
                        final stickerUrl = stickers[sIndex];
                        return _buildStickerThumbnail(stickerUrl, sIndex, pack);
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(14.h),
                ],

                // Bottom row: Sticker count badge & Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.collections_rounded,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          UIHelper.horizontalSpace(6.w),
                          Text(
                            "${pack.stickerCount ?? stickers.length} Stickers",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAddToWhatsAppButton(pack),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrayIcon(String? trayIconUrl) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        color: const Color(0xFF22273B),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: trayIconUrl != null && trayIconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: trayIconUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              )
            : Icon(
                Icons.sentiment_very_satisfied_rounded,
                color: AppColors.primary,
                size: 26.sp,
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final isReady = (status ?? '').toLowerCase() == 'ready';
    final badgeColor = isReady ? const Color(0xFF00E676) : Colors.orangeAccent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          UIHelper.horizontalSpace(5.w),
          Text(
            status ?? "Active",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerThumbnail(String stickerUrl, int index, PackModel pack) {
    return GestureDetector(
      onTap: () => _openStickerPreviewDialog(stickerUrl, index, pack),
      child: Hero(
        tag: "sticker_${pack.id}_$index",
        child: Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: const Color(0xFF202538),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(6.r),
          child: CachedNetworkImage(
            imageUrl: stickerUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: 18.r,
                height: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image_rounded,
              color: Colors.white24,
              size: 22.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToWhatsAppButton(PackModel pack) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            WhatsAppStickerService.addPackToWhatsApp(context, pack);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 16.sp),
                UIHelper.horizontalSpace(4.w),
                Text(
                  "Get Pack",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStickerPreviewDialog(String stickerUrl, int index, PackModel pack) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pack.name ?? "Sticker Preview",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(10.h),
                    Hero(
                      tag: "sticker_${pack.id}_$index",
                      child: SizedBox(
                        width: 200.r,
                        height: 200.r,
                        child: CachedNetworkImage(
                          imageUrl: stickerUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(18.h),
                    Text(
                      "Sticker #${index + 1} of ${(pack.stickers ?? []).length}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPackDetailsSheet(PackModel pack) {
    final stickers = pack.stickers ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141724),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  UIHelper.verticalSpace(12.h),
                  Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  Row(
                    children: [
                      _buildTrayIcon(pack.trayIcon),
                      UIHelper.horizontalSpace(14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pack.name ?? "Unnamed Pack",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            UIHelper.verticalSpace(4.h),
                            Text(
                              "${stickers.length} stickers • ${pack.status ?? 'Ready'}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(18.h),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: stickers.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2235),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          padding: EdgeInsets.all(8.r),
                          child: CachedNetworkImage(
                            imageUrl: stickers[index],
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(14.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        WhatsAppStickerService.addPackToWhatsApp(context, pack);
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: Text(
                        "Add Pack to WhatsApp",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 64.sp,
              color: Colors.white38,
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              "No Sticker Packs Found",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              "Pull down or tap below to refresh packs.",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white38,
              ),
            ),
            UIHelper.verticalSpace(20.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.sp,
              color: Colors.redAccent.withValues(alpha: 0.8),
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              "Failed to load sticker packs",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              "Please check your internet connection.",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white38,
              ),
            ),
            UIHelper.verticalSpace(20.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
