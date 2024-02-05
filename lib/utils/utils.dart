import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static showToast({required String message}) {
    Fluttertoast.showToast(msg: message);
  }
}