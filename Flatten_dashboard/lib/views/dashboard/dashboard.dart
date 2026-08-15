import 'package:flatten/controllers/dashboard/dashboard_controller.dart';
import 'package:flatten/controllers/other/syncfusion_charts_controller.dart';
import 'package:flatten/helpers/extensions/string.dart';
import 'package:flatten/helpers/theme/app_style.dart';
import 'package:flatten/helpers/utils/mixins/ui_mixin.dart';
import 'package:flatten/helpers/utils/my_shadow.dart';
import 'package:flatten/helpers/widgets/my_breadcrumb.dart';
import 'package:flatten/helpers/widgets/my_breadcrumb_item.dart';
import 'package:flatten/helpers/widgets/my_button.dart';
import 'package:flatten/helpers/widgets/my_card.dart';
import 'package:flatten/helpers/widgets/my_container.dart';
import 'package:flatten/helpers/widgets/my_flex.dart';
import 'package:flatten/helpers/widgets/my_flex_item.dart';
import 'package:flatten/helpers/widgets/my_list_extension.dart';
import 'package:flatten/helpers/widgets/my_spacing.dart';
import 'package:flatten/helpers/widgets/my_text.dart';

import 'package:flatten/images.dart';
import 'package:flatten/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
        child: GetBuilder<DashboardController>(
            init: controller,
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: MySpacing.x(flexSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText.titleMedium(
                          "dashboard".tr(),
                          fontSize: 18,
                          fontWeight: 600,
                        ),
                        MyBreadcrumb(
                          children: [
                            MyBreadcrumbItem(name: 'ecommerce'.tr()),
                            MyBreadcrumbItem(
                                name: 'dashboard'.tr(), active: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  MySpacing.height(flexSpacing),
                  Padding(
                    padding: MySpacing.x(flexSpacing / 2),
                    child: MyFlex(
                      wrapAlignment: WrapAlignment.start,
                      wrapCrossAlignment: WrapCrossAlignment.start,
                      children: [
                        MyFlexItem(
                          sizes: "xl-3 lg-6 sm-6 md-6",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.headlineSmall(
                                        "\$12,000",
                                        fontWeight: 600,
                                      ),
                                      MySpacing.height(4),
                                      MyText.bodySmall(
                                        "total_revenue".tr().capitalizeWords,
                                        muted: true,
                                        fontWeight: 600,
                                      ),
                                    ],
                                  ),
                                  MyContainer(
                                      color: contentTheme.primary.withAlpha(48),
                                      child: Icon(
                                        LucideIcons.credit_card,
                                        color: contentTheme.primary,
                                        size: 24,
                                      ))
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "xl-3 lg-6 sm-6 md-6",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.headlineSmall(
                                        "127",
                                        fontWeight: 600,
                                      ),
                                      MySpacing.height(4),
                                      MyText.bodySmall(
                                        "today_sales".tr().capitalizeWords,
                                        muted: true,
                                        fontWeight: 600,
                                      ),
                                    ],
                                  ),
                                  MyContainer(
                                      color: contentTheme.success.withAlpha(48),
                                      child: Icon(
                                        LucideIcons.shopping_cart,
                                        color: contentTheme.success,
                                        size: 24,
                                      ))
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "xl-3 lg-6 sm-6 md-6",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.headlineSmall(
                                        "248",
                                        fontWeight: 600,
                                      ),
                                      MySpacing.height(4),
                                      MyText.bodySmall(
                                        "on_delivery".tr().capitalizeWords,
                                        muted: true,
                                        fontWeight: 600,
                                      ),
                                    ],
                                  ),
                                  MyContainer(
                                      color:
                                          contentTheme.secondary.withAlpha(48),
                                      child: Icon(
                                        LucideIcons.truck,
                                        color: contentTheme.secondary,
                                        size: 24,
                                      ))
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "xl-3 lg-6 sm-6 md-6",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.headlineSmall(
                                        "125k",
                                        fontWeight: 600,
                                      ),
                                      MySpacing.height(4),
                                      MyText.bodySmall(
                                        "website_visits".tr().capitalizeWords,
                                        muted: true,
                                        fontWeight: 600,
                                      ),
                                    ],
                                  ),
                                  MyContainer(
                                      color: contentTheme.danger.withAlpha(48),
                                      child: Icon(
                                        LucideIcons.eye,
                                        color: contentTheme.danger,
                                        size: 26,
                                      ))
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "lg-6 sm-12",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.titleMedium(
                                    "revenue".tr(),
                                    fontWeight: 600,
                                  ),
                                  MySpacing.height(36),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "target".tr(),
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_down,
                                                size: 16,
                                                color: contentTheme.danger,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '3.02%',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "last_week".tr(),
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_up,
                                                size: 16,
                                                color: contentTheme.primary,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '\$ 2.1k',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "last_month".tr(),
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_down,
                                                size: 16,
                                                color: contentTheme.danger,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '\$ 1.2k',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(36),
                                  buildRevenueChart()
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "lg-6 sm-12",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.titleMedium(
                                    "product_comparison".tr().capitalizeWords,
                                    fontWeight: 600,
                                  ),
                                  MySpacing.height(36),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "${"product".tr()} 1",
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_down,
                                                size: 16,
                                                color: contentTheme.danger,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '40.2%',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "${"product".tr()} 2",
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_up,
                                                size: 16,
                                                color: contentTheme.primary,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '24.5%',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MyText.bodyMedium(
                                            "${"Product".tr()} 3",
                                            muted: true,
                                          ),
                                          MySpacing.height(8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.arrow_down,
                                                size: 16,
                                                color: contentTheme.danger,
                                              ),
                                              MySpacing.width(8),
                                              MyText.bodyLarge(
                                                '32.5%',
                                                fontWeight: 600,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(36),
                                  buildComparisonChart()
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "lg-6 sm-12",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText.titleMedium(
                                        "trending_products"
                                            .tr()
                                            .capitalizeWords,
                                        fontWeight: 600,
                                      ),
                                      MyButton.text(
                                        onPressed: controller.goToProducts,
                                        elevation: 6,
                                        padding: MySpacing.xy(20, 16),
                                        child: MyText.bodySmall(
                                          'view_all'.tr().capitalizeWords,
                                          color: contentTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(20),
                                  MyContainer.none(
                                    borderRadiusAll: 4,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                          sortAscending: true,
                                          columnSpacing: 60,
                                          onSelectAll: (_) => {},
                                          headingRowColor:
                                              WidgetStatePropertyAll(
                                                  contentTheme.primary
                                                      .withAlpha(40)),
                                          dataRowMaxHeight: 60,
                                          showBottomBorder: false,
                                          columns: [
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'id'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'name'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'price'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'stock'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'orders'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                            DataColumn(
                                                label: MyText.labelLarge(
                                              'action'.tr(),
                                              color: contentTheme.primary,
                                            )),
                                          ],
                                          rows: controller.products
                                              .mapIndexed((index, data) =>
                                                  DataRow(cells: [
                                                    DataCell(MyText.bodyMedium(
                                                        '#${data.id}')),
                                                    DataCell(SizedBox(
                                                      width: 220,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          MyContainer.none(
                                                              borderRadiusAll:
                                                                  20,
                                                              clipBehavior: Clip
                                                                  .antiAliasWithSaveLayer,
                                                              child: Image.asset(
                                                                  Images.squareImages[index %
                                                                      Images
                                                                          .squareImages
                                                                          .length],
                                                                  height: 40,
                                                                  width: 40)),
                                                          MySpacing.width(16),
                                                          Expanded(
                                                            child: MyText
                                                                .labelLarge(
                                                              data.name
                                                                  .toString(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                    DataCell(MyText.bodyMedium(
                                                        '\$${data.price}')),

                                                    DataCell(MyText.bodyMedium(
                                                        '${data.stock}')),
                                                    DataCell(MyText.bodyMedium(
                                                        '${data.ordersCount}')),

                                                    DataCell(Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child:
                                                          MyContainer.bordered(
                                                        onTap: () => {},
                                                        padding:
                                                            MySpacing.xy(6, 6),
                                                        borderColor:
                                                            contentTheme.primary
                                                                .withAlpha(40),
                                                        child: Icon(
                                                          LucideIcons.pencil,
                                                          size: 14,
                                                          color: contentTheme
                                                              .primary,
                                                        ),
                                                      ),
                                                    )),
                                                    // DataCell(MyText.bodyMedium('${DateTime.tryParse('2022-11-26T15:56:14Z')}')),
                                                  ]))
                                              .toList()),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        MyFlexItem(
                          sizes: "lg-6 sm-12",
                          child: MyCard(
                              shadow: MyShadow(
                                  elevation: 0.5,
                                  position: MyShadowPosition.bottom),
                              padding: MySpacing.xy(20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText.titleMedium(
                                        "customers".tr(),
                                        fontWeight: 600,
                                      ),
                                      MyButton.text(
                                        onPressed: controller.goToCustomers,
                                        elevation: 6,
                                        padding: MySpacing.xy(20, 16),
                                        child: MyText.bodySmall(
                                          'view_all'.tr().capitalizeWords,
                                          color: contentTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  MySpacing.height(20),
                                  MyContainer.none(
                                    borderRadiusAll: 4,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        sortColumnIndex: 1,
                                        columnSpacing: 50,
                                        sortAscending: true,
                                        onSelectAll: (_) => {},
                                        headingRowColor: WidgetStatePropertyAll(
                                            contentTheme.primary.withAlpha(40)),
                                        // dataRowHeight: 60,
                                        dataRowMaxHeight: 60,
                                        showBottomBorder: false,
                                        columns: [
                                          DataColumn(
                                            label: MyText.labelLarge(
                                              'id'.tr(),
                                              color: contentTheme.primary,
                                            ),
                                          ),
                                          DataColumn(
                                            label: MyText.labelLarge(
                                              'name'.tr(),
                                              color: contentTheme.primary,
                                            ),
                                          ),
                                          DataColumn(
                                            label: MyText.labelLarge(
                                              'phone'.tr(),
                                              color: contentTheme.primary,
                                            ),
                                          ),
                                          DataColumn(
                                            label: MyText.labelLarge(
                                              'balance'.tr(),
                                              color: contentTheme.primary,
                                            ),
                                          ),
                                          DataColumn(
                                            label: MyText.labelLarge(
                                              'orders'.tr(),
                                              color: contentTheme.primary,
                                            ),
                                          ),
                                          DataColumn(
                                              label: MyText.labelLarge(
                                            'action'.tr(),
                                            color: contentTheme.primary,
                                          )),
                                        ],
                                        rows: controller.customers
                                            .mapIndexed(
                                              (index, data) => DataRow(
                                                cells: [
                                                  DataCell(MyText.bodyMedium(
                                                      "#${data.id}")),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 180,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          MyContainer.none(
                                                            borderRadiusAll: 20,
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            child: Image.asset(
                                                              Images.avatars[index %
                                                                  Images.avatars
                                                                      .length],
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                          ),
                                                          MySpacing.width(12),
                                                          Expanded(
                                                            child: MyText
                                                                .labelLarge(
                                                              data.fullName,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(MyText.bodyMedium(
                                                      '${data.phoneNumber}')),
                                                  DataCell(MyText.bodyMedium(
                                                      '\$${data.balance}')),
                                                  DataCell(MyText.bodyMedium(
                                                      '${data.ordersCount}')),
                                                  DataCell(Align(
                                                    alignment: Alignment.center,
                                                    child: MyContainer.bordered(
                                                      onTap: () => {},
                                                      padding:
                                                          MySpacing.xy(6, 6),
                                                      borderColor: contentTheme
                                                          .primary
                                                          .withAlpha(40),
                                                      child: Icon(
                                                        LucideIcons.pencil,
                                                        size: 14,
                                                        color: contentTheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }

  Widget buildRevenueChart() {
    List<SplineSeries<ChartSampleData, DateTime>> getDefaultAreaSeries() {
      return <SplineSeries<ChartSampleData, DateTime>>[
        SplineSeries<ChartSampleData, DateTime>(
          dataSource: controller.revenueChartData,
          opacity: 0.7,
          name: '${'Product'.tr()} A',
          color: contentTheme.primary.withAlpha(150),
          xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
        ),
        SplineSeries<ChartSampleData, DateTime>(
          dataSource: controller.revenueChartData,
          opacity: 0.7,
          name: '${'Product'.tr()} B',
          color: contentTheme.danger.withAlpha(150),
          xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
        )
      ];
    }

    return SizedBox(
      height: 400,
      child: SfCartesianChart(
        legend: Legend(opacity: 0.7, position: LegendPosition.bottom),
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(
            interval: 1,
            intervalType: DateTimeIntervalType.months,
            majorGridLines: const MajorGridLines(width: 1),
            axisLine: AxisLine(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift),
        primaryYAxis: NumericAxis(
            labelFormat: '{value}',
            //title: AxisTitle(text: 'Revenue in millions'),
            interval: 4,
            axisLine: const AxisLine(
              width: 0,
            ),
            minimum: 16,
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(
              size: 16,
              width: 0,
              color: Colors.transparent,
            )),
        series: getDefaultAreaSeries(),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget buildComparisonChart() {
    List<ColumnSeries<ChartSampleData, DateTime>> getDefaultAreaSeries() {
      return <ColumnSeries<ChartSampleData, DateTime>>[
        ColumnSeries<ChartSampleData, DateTime>(
          dataSource: controller.comparisonChartData,
          opacity: 0.7,
          name: '${'Product'.tr()} A',
          width: 0.2,
          color: contentTheme.primary.withAlpha(150),
          xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
        ),
        ColumnSeries<ChartSampleData, DateTime>(
          dataSource: controller.comparisonChartData,
          opacity: 0.7,
          name: '${'Product'.tr()} B',
          width: 0.2,
          color: contentTheme.danger.withAlpha(150),
          xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
        )
      ];
    }

    return SizedBox(
      height: 400,
      child: SfCartesianChart(
        legend: Legend(opacity: 0.7, position: LegendPosition.bottom),
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(
            interval: 1,
            intervalType: DateTimeIntervalType.days,
            majorGridLines: const MajorGridLines(width: 1),
            axisLine: AxisLine(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift),
        primaryYAxis: NumericAxis(
            labelFormat: '{value}',
            //title: AxisTitle(text: 'Revenue in millions'),
            interval: 4,
            minimum: 8,
            axisLine: const AxisLine(
              width: 0,
            ),
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(
              size: 16,
              width: 0,
              color: Colors.transparent,
            )),
        series: getDefaultAreaSeries(),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }
}
