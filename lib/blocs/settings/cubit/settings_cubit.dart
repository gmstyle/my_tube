import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsCubit extends Cubit<dynamic> {
  SettingsCubit() : super(null);

  final settingsBox = Hive.box('settings');

  void init() {
    getCountry();
  }

  void getCountry() {
    final countryCode = settingsBox.get('countryCode', defaultValue: 'US');
    emit(countryCode);
  }

  void setCountry(String countryCode) {
    settingsBox.put('countryCode', countryCode);
    emit(countryCode);
  }
}
