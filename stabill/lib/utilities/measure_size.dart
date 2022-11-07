import 'package:flutter/widgets.dart';

class MeasureSize extends StatefulWidget {
  final Widget? child;
  final ValueNotifier<Size> sizeValueNotifier;

  const MeasureSize({
    Key? key,
    required this.child,
    required this.sizeValueNotifier,
  }) : super(key: key);

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSize();
    });
  }

  void _getSize() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    widget.sizeValueNotifier.value = renderBox!.size;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
