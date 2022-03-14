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

const formFieldSpace = SizedBox(
  height: 8,
);

const dialogFieldSpace = SizedBox(
  height: 16,
);

const defaultTextInputDecoration = InputDecoration(
  filled: true,
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  labelStyle: TextStyle(color: Colors.grey),
  iconColor: Colors.grey,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.grey, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.green, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(fieldRadius),
    borderSide: BorderSide(color: Colors.grey, width: 2),
  ),
);

const checkboxFieldShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(fieldRadius),
  side: BorderSide(color: Colors.grey, width: 2),
);

InputDecoration textInputDecoration({
  String? labelText,
  String? hintText,
  IconData? prefixIcon,
}) {
  return defaultTextInputDecoration.copyWith(
    prefixIcon: prefixIcon != null
        ? Icon(
            prefixIcon,
            color: Colors.grey,
          )
        : null,
    labelText: labelText,
    hintText: hintText,
  );
}

Color formFieldFill(Brightness themeBrightness) {
  return themeBrightness == Brightness.light
      ? const Color(0x0A000000)
      : const Color(0x1AFFFFFF);
}

String? emailValidator(
  String? email, {
  String errorMessage = "Email is invalid",
}) {
  if (email == null) {
    return null;
  }
  const String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(email)) {
    return errorMessage;
  } else {
    return null;
  }
}

String? passwordValidator(
  String? value, {
  String lengthErrorMessage = "Password must be longer than 6 characters",
}) {
  if (value == null) {
    return null;
  }
  if (value.length < 6) {
    return lengthErrorMessage;
  } else {
    return null;
  }
}
