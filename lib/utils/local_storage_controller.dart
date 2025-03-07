// Сохранение значения в локальное хранилище
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDataToLocalStorage(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

// Получение значения из локального хранилища
Future<String?> getDataFromLocalStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  return prefs.getString(key);
}

// Удаление значения из локального хранилища
Future<void> removeDataFromLocalStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}
