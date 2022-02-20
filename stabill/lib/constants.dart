import 'package:flutter/material.dart';

// Constant Shapes

const cardRadius = Radius.circular(12);
const fieldRadius = cardRadius;
const modalRadius = Radius.circular(24);

const cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(cardRadius),
);

const modalShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(topLeft: modalRadius, topRight: modalRadius),
);

const dialogShape = cardShape;
const menuShape = cardShape;

const topCardShape = RoundedRectangleBorder(
  borderRadius:
      BorderRadius.only(bottomLeft: cardRadius, bottomRight: cardRadius),
);

const defaultTextInputDecoration = InputDecoration(
  filled: true,
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  iconColor: Colors.grey,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.green, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
);

InputDecoration textInputDecoration({String? hintText, IconData? prefixIcon}) {
  return defaultTextInputDecoration.copyWith(
    prefixIcon: prefixIcon != null
        ? Icon(
            prefixIcon,
            color: Colors.grey,
          )
        : null,
    hintText: hintText,
  );
}

Color formFieldFill(Brightness themeBrightness) {
  return themeBrightness == Brightness.light
      ? const Color(0x0A000000)
      : const Color(0x1AFFFFFF);
}
