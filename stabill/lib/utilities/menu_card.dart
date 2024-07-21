import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stabill/constants.dart';

class MenuCard<T> extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function(T?)? onSelect;
  final List<PopupMenuItem<T>> actions;

  const MenuCard({
    Key? key,
    required this.child,
    required this.actions,
    this.onSelect,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  _MenuCardState<T> createState() => _MenuCardState<T>();
}

class _MenuCardState<T> extends State<MenuCard<T>> {
  late Offset pressPosition;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool displayMenuButton =
        kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(cardRadius),
      ),
      child: GestureDetector(
        onLongPressDown: (details) => pressPosition = details.globalPosition,
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          onLongPress: () async {
            // Show a menu prompt if the platform is not on web
            if (!displayMenuButton) {
              final T? action = await showMenu<T>(
                context: context,
                items: widget.actions,
                shape: menuShape,
                position: RelativeRect.fromLTRB(
                  pressPosition.dx,
                  pressPosition.dy,
                  screenSize.width - pressPosition.dx,
                  screenSize.height - pressPosition.dy,
                ),
              );

              widget.onSelect?.call(action);
            }
          },
          onTap: widget.onTap,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(child: widget.child),
                if (displayMenuButton)
                  PopupMenuButton<T>(
                    itemBuilder: (_) => widget.actions,
                    onSelected: widget.onSelect,
                    shape: menuShape,
                    padding: EdgeInsets.zero,
                    tooltip: "Show Actions",
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
