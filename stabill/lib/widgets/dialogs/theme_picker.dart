import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/providers/preference_provider.dart';

class ThemePicker extends StatefulWidget {
  final ThemeType defaultType;

  const ThemePicker({Key? key, required this.defaultType}) : super(key: key);

  @override
  _ThemePickerState createState() => _ThemePickerState();

  static Future<ThemeType> show(
    BuildContext context,
    ThemeType currentThemeType,
  ) async {
    return await showDialog<ThemeType>(
          context: context,
          builder: (_) => ThemePicker(
            defaultType: currentThemeType,
          ),
        ) ??
        currentThemeType;
  }
}

class _ThemePickerState extends State<ThemePicker> {
  late ThemeType selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.defaultType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Theme Type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ThemeType.values
            .map(
              (type) => RadioListTile<ThemeType>(
                  value: type,
                  groupValue: selectedType,
                  title: Text(type
                      .toString()
                      .substring(type.toString().indexOf(".") + 1)),
                  onChanged: (val) => setState(() {
                        selectedType = val!;
                      }),
                  contentPadding: EdgeInsets.zero),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Confirm"),
          onPressed: () => Navigator.of(context).pop(selectedType),
        )
      ],
    );
  }
}
