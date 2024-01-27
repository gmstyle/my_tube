import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.title,
    this.centerTitle = false,
    this.showTitle = true,
    this.leading,
    this.actions,
  });

  final Widget? title;
  final bool centerTitle;
  final bool showTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        centerTitle: centerTitle,
        title: showTitle
            ? title ??
                Text('MyTube',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary))
            : null,
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        actions: [
          if (actions != null) ...actions!,
        ],
        flexibleSpace: isSearch
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              )
            : null);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
