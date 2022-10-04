import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:untare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';

class CustomScrollNotification {
  final HideBottomNavBarStatefulWidget widget;

  CustomScrollNotification({required this.widget});

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            widget.isHideBottomNavBar(true);
            break;
          case ScrollDirection.reverse:
            widget.isHideBottomNavBar(false);
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }
}
