import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.title,
    this.leading,
    this.actions,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      title: Text(
        title ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
