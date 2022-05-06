import 'package:flutter/material.dart';
import 'package:stabill/constants.dart';

class HistoryLimitPicker extends StatefulWidget {
  final int defaultLimit;

  const HistoryLimitPicker({Key? key, required this.defaultLimit})
      : super(key: key);

  @override
  _HistoryLimitPickerState createState() => _HistoryLimitPickerState();

  static Future<int> show(
    BuildContext context,
    int currentHistoryLimit,
  ) async {
    return await showDialog<int>(
          context: context,
          builder: (_) => HistoryLimitPicker(
            defaultLimit: currentHistoryLimit,
          ),
        ) ??
        currentHistoryLimit;
  }
}

class _HistoryLimitPickerState extends State<HistoryLimitPicker> {
  late int selectedLimit;

  @override
  void initState() {
    super.initState();
    selectedLimit = widget.defaultLimit;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select History Limit"),
      shape: dialogShape,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [25, 50, 75, 100]
            .map(
              (limit) => RadioListTile<int>(
                value: limit,
                groupValue: selectedLimit,
                title: Text("$limit Transactions"),
                onChanged: (val) => setState(() {
                  selectedLimit = val!;
                }),
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(selectedLimit),
          child: const Text("Confirm"),
        )
      ],
    );
  }
}
