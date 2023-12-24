import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.title,
    this.leading,
    this.actions,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        title: title ??
            const Text('MyTube', style: TextStyle(color: Colors.white)),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
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
