// validators.dart
class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Телефон номерин киргизиңиз';
    }
    if (value.length < 9) {
      return 'Телефон номери 9 сандан кем эмес болушу керек';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Аты-жөнүңүздү киргизиңиз';
    }
    if (value.length < 3) {
      return 'Аты-жөнүңүз 3 тамгадан кем эмес болушу керек';
    }
    return null;
  }

  static String? validateSmsCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'СМС кодду киргизиңиз';
    }
    if (value.length < 6) {
      return 'СМС коду 6 сандан турушу керек';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName киргизиңиз';
    }
    return null;
  }
}