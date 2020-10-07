import 'package:shared_preferences/shared_preferences.dart';

const String DEFAULT_SCREEN_SP_ROUT = 'defaultScreen';

Future<int> retrieveDefaultScreen(String route) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int data = (prefs.getInt(route) ?? 0);
  return data;
}

void saveDefaultScreen(String route, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(route, value);
  print('saved');
}
