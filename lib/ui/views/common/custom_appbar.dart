import 'package:flutter/material.dart';
import 'package:my_tube/utils/app_breakpoints.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.title,
    this.centerTitle = false,
    this.showTitle = true,
    this.leading,
    this.actions,
    this.isSearch = false,
    this.backgroundColor,
    this.elevation,
    this.toolbarHeight,
  });

  final Widget? title;
  final bool centerTitle;
  final bool showTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isSearch;
  final Color? backgroundColor;
  final double? elevation;
  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompact;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      toolbarHeight: toolbarHeight ?? (isCompact ? 56.0 : 64.0),
      leading: leading,
      centerTitle: centerTitle,
      title: showTitle
          ? title ??
              Text(
                'MyTube',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: isCompact ? 18 : 20,
                  fontWeight: FontWeight.w600,
                ),
              )
          : null,
      actionsIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: isCompact ? 22 : 24,
      ),
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: isCompact ? 22 : 24,
      ),
      actions: _buildResponsiveActions(context),
    );
  }

  /// Build responsive actions with proper spacing
  List<Widget> _buildResponsiveActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return [];

    final isCompact = context.isCompact;
    final spacing = isCompact ? 4.0 : 8.0;
    final endPadding = isCompact ? 8.0 : 16.0;

    return [
      ...actions!
          .expand((action) => [
                action,
                SizedBox(width: spacing),
              ])
          .take(actions!.length * 2 - 1),
      SizedBox(width: endPadding),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
