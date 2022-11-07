import 'package:flutter/widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stabill/utilities/measure_size.dart';

class HeaderList extends StatefulWidget {
  final Widget? header;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final double itemHeight;
  final Widget? onEmpty;
  final bool? isLoading;
  final Widget? onLoading;
  final bool? error;
  final Widget? onError;
  final ScrollController? controller;

  const HeaderList({
    Key? key,
    this.header,
    required this.itemBuilder,
    required this.itemCount,
    required this.itemHeight,
    this.onEmpty,
    this.isLoading,
    this.onLoading,
    this.error,
    this.onError,
    this.controller,
  }) : super(key: key);

  @override
  _HeaderListState createState() => _HeaderListState();
}

class _HeaderListState extends State<HeaderList> {
  final ValueNotifier<Size> _headerSize = ValueNotifier<Size>(Size.zero);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _headerSize,
      builder: (BuildContext context, Size value, Widget? child) {
        Widget body = const SizedBox.shrink();
        if (widget.error ?? false) {
          body = Padding(
            padding: EdgeInsets.only(top: value.height),
            child: widget.onError ?? body,
          );
        } else if (widget.isLoading ?? false) {
          body = Padding(
            padding: EdgeInsets.only(top: value.height),
            child: widget.onLoading ?? body,
          );
        } else if (widget.itemCount == 0) {
          body = Padding(
            padding: EdgeInsets.only(top: value.height),
            child: widget.onEmpty ?? body,
          );
        } else {
          body = ResponsiveBuilder(
            builder: (context, sizingInformation) {
              int crossAxisCount = 1;

              if (sizingInformation.isDesktop) {
                crossAxisCount = 3;
              } else if (sizingInformation.isTablet) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: widget.itemHeight,
                  mainAxisSpacing: 4,
                ),
                controller: widget.controller,
                padding: EdgeInsets.only(top: value.height),
                itemCount: widget.itemCount,
                itemBuilder: widget.itemBuilder,
              );
            },
          );
        }

        return Stack(
          children: [
            body,
            MeasureSize(
              sizeValueNotifier: _headerSize,
              child: widget.header,
            ),
          ],
        );
      },
    );
  }
}
