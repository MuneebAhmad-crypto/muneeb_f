import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/index.dart' show FStoreNotificationItem;
import '../../models/notification_model.dart';
import '../../screens/common/app_bar_mixin.dart';
import '../../services/index.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AppBarMixin {
  final scrollController = ScrollController();

  NotificationModel get notificationModel => context.read<NotificationModel>();

  @override
  void initState() {
    screenScrollController = scrollController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return renderScaffold(
      routeName: RouteList.notify,
      secondAppBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor.getColorBasedOnBackground,
        ),
        title: Text(
          S.of(context).listMessages,
          style: TextStyle(
            color: Theme.of(context).primaryColor.getColorBasedOnBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child:
          Selector<
            NotificationModel,
            UnmodifiableListView<FStoreNotificationItem>
          >(
            selector: (context, notificationModel) => UnmodifiableListView(
              notificationModel.listNotification.reversed,
            ),
            shouldRebuild: (oldList, newList) {
              /// When a new notification arrive then scroll to top
              if (newList.length > oldList.length) {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceIn,
                );
              }
              return oldList != newList;
            },
            builder: (context, notifications, child) {
              if (notifications.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValueOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 36,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          S.of(context).noData,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  final notificationItem = notifications[index];
                  return Dismissible(
                    key: Key(notificationItem.id),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        notificationModel.removeMessage(notificationItem.id);
                      }
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        handleMessage(notificationItem);
                        return false;
                      }
                      return confirmDeleteMessage();
                    },
                    background: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        notificationItem.seen
                            ? S.of(context).markAsUnread
                            : S.of(context).markAsRead,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        S.of(context).delete,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      elevation: notificationItem.seen ? 0 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: notificationItem.seen
                              ? Theme.of(
                                  context,
                                ).dividerColor.withValueOpacity(0.08)
                              : Theme.of(
                                  context,
                                ).primaryColor.withValueOpacity(0.25),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          onTapMessage(notificationItem);
                          notificationModel.markAsRead(notificationItem.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeading(notificationItem),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notificationItem.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              fontSize: 16,
                                              fontWeight: notificationItem.seen
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (!notificationItem.seen)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notificationItem.body,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValueOpacity(0.78),
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      notificationItem.displayDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValueOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  void handleMessage(FStoreNotificationItem notificationItem) {
    if (notificationItem.seen) {
      notificationModel.markAsUnread(notificationItem.id);
    } else {
      notificationModel.markAsRead(notificationItem.id);
    }
  }

  Future<bool> confirmDeleteMessage() async {
    return await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text(S.of(context).confirm),
              content: Text(S.of(context).confirmDeleteItem),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    S.of(context).delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(S.of(context).cancel),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void onTapMessage(FStoreNotificationItem data) async {
    final url = data.dynamicLink;
    if (url != null) {
      try {
        final handled = await Services().dynamicLinkService.handleLink(url);
        if (handled) {
          return;
        }
      } catch (_) {
        // Fall back to showing notification content if link handling fails.
      }
    }
    final heightScreen = MediaQuery.sizeOf(context).height;
    final maxHeight = min(heightScreen * 0.6, 600).toDouble();
    final minHeight = min(heightScreen * 0.2, 200).toDouble();

    await _showNotificationDetailDialog(
      data: data,
      maxHeight: maxHeight,
      minHeight: minHeight,
    );
  }

  Future<void> _showNotificationDetailDialog({
    required FStoreNotificationItem data,
    required double maxHeight,
    required double minHeight,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValueOpacity(0.45),
      builder: (dialogContext) {
        final secondaryColor = Theme.of(dialogContext).colorScheme.secondary;
        final surfaceColor = Theme.of(dialogContext).colorScheme.surface;
        final hasImage = data.image?.isNotEmpty ?? false;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minHeight: minHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 10, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: secondaryColor.withValueOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              data.displayDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryColor.withValueOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        splashRadius: 20,
                        icon: Icon(
                          Icons.close_rounded,
                          color: secondaryColor.withValueOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: FluxImage(
                          imageUrl: data.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SingleChildScrollView(
                      child: Text(
                        data.body,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: secondaryColor.withValueOpacity(0.88),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(FStoreNotificationItem notificationItem) {
    final image = notificationItem.image;

    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: FluxImage(
          imageUrl: image,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValueOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.notifications_none_rounded,
        size: 28,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
