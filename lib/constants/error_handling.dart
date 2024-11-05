import 'dart:convert';

//import 'package:amazon_clone_tutorial/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'utils2.dart';

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar2(context, jsonDecode(response.body)['msg']);
      break;
    case 500:
      showSnackBar2(context, jsonDecode(response.body)['error']);
      break;
    default:
      showSnackBar2(context, response.body);
  }
}
