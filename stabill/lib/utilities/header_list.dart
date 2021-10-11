import 'package:flutter/widgets.dart';
import 'package:stabill/utilities/measure_size.dart';

class HeaderList extends StatefulWidget {
  final Widget? header;
  final Widget? listBody;

  const HeaderList({
    Key? key,
    this.header,
    this.listBody,
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
      child: null,
      builder: (BuildContext context, Size value, Widget? child) {
        return Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: value.height + 1,
                ),
                Expanded(
                  child: widget.listBody ?? const SizedBox.shrink(),
                )
              ],
            ),
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
