
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar2(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
  