import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/enums/load_state.dart';
import '../../../common/tools.dart';
import '../../../models/brand_layout_model.dart';
import '../../../models/entities/back_drop_arguments.dart';
import '../../../models/entities/brand.dart';
import '../../../routes/flux_navigate.dart';
import '../config/brand_carousel_config.dart';
import 'widgets/brand_skeleton.dart';

class BrandCarouselLayout extends StatefulWidget {
  final BrandCarouselConfig config;

  const BrandCarouselLayout({required this.config, super.key});

  @override
  State<BrandCarouselLayout> createState() => _BrandCarouselLayoutState();
}

class _BrandCarouselLayoutState extends State<BrandCarouselLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<BrandLayoutModel>().loadAllBrands();
    });
  }

  void _onBrandTap(Brand brand) {
    FluxNavigate.pushNamed(
      RouteList.backdrop,
      arguments: BackDropArguments(
        config: widget.config.toJson(),
        brandId: brand.id,
        brandName: brand.name,
        brandImg: brand.image,
      ),
      context: context,
    );
  }

  Widget _buildSlide(Brand brand) {
    final config = widget.config;
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onBrandTap(brand),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (brand.image != null && brand.image!.isNotEmpty)
              ClipRRect(
                borderRadius: config.isLogoCornerRounded
                    ? const BorderRadius.all(Radius.circular(15))
                    : BorderRadius.zero,
                child: FluxImage(
                  imageUrl: brand.image ?? '',
                  width: 72,
                  height: 72,
                  fit: ImageTools.boxFit(config.imageBoxFit ?? 'contain'),
                ),
              )
            else
              const SizedBox(height: 72, width: 72),
            if (config.showName) ...[
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  brand.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return BackgroundColorWidget(
      enable: config.enableBackground,
      child: Consumer<BrandLayoutModel>(
        builder: (_, model, __) {
          final hasHeader = (config.name ?? '').isNotEmpty;

          if (model.state == FSLoadState.loading && model.brands.isEmpty) {
            return Column(
              children: [
                if (hasHeader)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HeaderView(
                      headerText: config.name ?? '',
                      showSeeAll: false,
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      ...List.filled(5, BrandItemSkeleton()),
                    ],
                  ),
                ),
              ],
            );
          }

          if (model.brands.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              if (hasHeader)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HeaderView(
                    headerText: config.name ?? '',
                    showSeeAll: false,
                  ),
                ),
              SizedBox(
                height: config.height,
                child: Swiper(
                  itemCount: model.brands.length,
                  viewportFraction: 1 / config.itemsPerView,
                  scale: 0.95,
                  autoplay: config.autoPlay,
                  autoplayDelay: config.autoPlayDelay,
                  autoplayDisableOnInteraction: true,
                  loop:
                      config.loop && model.brands.length > config.itemsPerView,
                  itemBuilder: (_, index) => _buildSlide(model.brands[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
