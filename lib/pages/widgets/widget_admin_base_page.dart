import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/widget_appbar.dart';

class AdminBasePage extends StatelessWidget {
  final Widget child;
  final List<Widget> appBarWidgets;
  final bool? resizeInset;

  const AdminBasePage(
      {super.key,
      required this.child,
      this.appBarWidgets = const [],
      this.resizeInset});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          resizeToAvoidBottomInset: resizeInset,
          body: Column(
            children: [
              BaseAppBar(content: appBarWidgets),
              child,
            ],
          ),
        ));
  }
}
