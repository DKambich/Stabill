import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
    final deviceSize = getDeviceType(screenSize);

    final bool displayMenuButton = deviceSize == DeviceScreenType.desktop ||
        deviceSize == DeviceScreenType.tablet;

    return Card(
      child: GestureDetector(
        onLongPressDown: (details) => pressPosition = details.globalPosition,
        child: InkWell(
          onLongPress: () async {
            // Show a menu prompt if the platform is not on web
            if (!displayMenuButton) {
              final T? action = await showMenu<T>(
                context: context,
                position: RelativeRect.fromLTRB(
                  pressPosition.dx,
                  pressPosition.dy,
                  screenSize.width - pressPosition.dx,
                  screenSize.height - pressPosition.dy,
                ),
                items: widget.actions,
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
                    padding: EdgeInsets.zero,
                    tooltip: "Show Actions",
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
