import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

class Utility {

  static Uint8List imageFromBase64String(String base64String) {
    Uint8List bytes =dataFromBase64String(base64String);

    return bytes;

  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}