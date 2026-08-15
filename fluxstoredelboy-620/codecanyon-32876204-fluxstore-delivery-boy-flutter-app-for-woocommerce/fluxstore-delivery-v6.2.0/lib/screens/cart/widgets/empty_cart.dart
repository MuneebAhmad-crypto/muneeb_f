import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/config.dart';
import '../../../common/tools/navigate_tools.dart';
import '../../../modules/dynamic_layout/helper/helper.dart';

class EmptyCart extends StatelessWidget {
  final bool isDesktop;

  const EmptyCart({super.key, this.isDesktop = false});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final emptyImage = kCartDetail.emptyImage;
    final theme = Theme.of(context);

    if (isDesktop) {
      return LayoutBuilder(
        builder: (ct, constraints) {
          return LayoutLimitWidthScreen(
            backgroundColor: theme.colorScheme.surface,
            child: Column(
              spacing: 20.0,
              children: <Widget>[
                SizedBox(height: constraints.maxHeight * 0.3),
                if (emptyImage != null)
                  FluxImage(imageUrl: emptyImage, width: 90, height: 90),
                Text(
                  S.of(context).emptyCart,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 32 / 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    S.of(context).emptyCartSubtitle02,
                    style: const TextStyle(fontSize: 16, height: 20 / 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ButtonTheme(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: theme.primaryColor,
                      ),
                      onPressed: () =>
                          NavigateTools.navigateToDefaultTab(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: Text(S.of(context).exploreNow),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Stack(
            children: <Widget>[
              if (emptyImage != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: FluxImage(
                    imageUrl: emptyImage,
                    width: 120,
                    height: 120,
                  ),
                ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 60),
                  Text(
                    S.of(context).yourBagIsEmpty,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      S.of(context).emptyCartSubtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
