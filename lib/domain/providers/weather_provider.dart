import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/domain/api/api.dart';
import 'package:weather_app/domain/hive/favorite_history.dart';
import 'package:weather_app/domain/hive/hive_box.dart';
import 'package:weather_app/domain/models/coord.dart';
import 'package:weather_app/domain/models/weather_data.dart';
import 'package:weather_app/ui/resources/app_bg.dart';
import 'package:weather_app/ui/routes/app_routes.dart';
import 'package:weather_app/ui/style/app_colors.dart';
import 'package:weather_app/ui/style/app_style.dart';

class WeatherProvider extends ChangeNotifier {
// хранение координат
  Coord? _coords;
  Coord? get coord => _coords;

// хранение данных о погоде
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

// хранение текущих данных о погоде
  Current? _current;
  Current? get current => _current;
  final searchController = TextEditingController();
  bool isActive = false;

// главная функция для запуска во FutureBuilder
  Future<WeatherData?> setUp({String? cityName}) async {
    cityName = (await pref).getString('cityName');
    // print(cityName);
    _coords = await Api.getCoords(cityName: cityName ?? 'Tashkent');
    _weatherData = await Api.getWeather(_coords);
    _current = _weatherData?.current;
    setCurrentDay();
    setCurrentDate();
    setCurrentTime();
    setCurrentTemp();
    setHumidity();
    setWindSpeed();
    setFeelslike();
    setWeekday();
    setSunrise();
    setSunset();
    getCurrentCity();

    return _weatherData;
  }

  final pref = SharedPreferences.getInstance();

  // установка текущего города
  Future<void> setCurrentCity(BuildContext context, {String? cityName}) async {
    if (searchController.text != '') {
      cityName = searchController.text;
      (await pref).setString('cityName', cityName);
      await setUp(cityName: (await pref).getString('cityName')).then(
        (value) => searchController.clear(),
      );
      notifyListeners();
    }
   // ignore: use_build_context_synchronously
   context.go(AppRoutes.home);
  }

  String currentCity = '';
  Future<String> getCurrentCity() async {
    currentCity = (await pref).getString('cityName') ?? 'Ташкент';
    return capitalize(currentCity);
  }

  // Установка заднего фона
  String? currentBg;
  String setBg() {
    int id = _current?.weather?[0].id ?? -1;

    if (id == -1 || _current?.sunset == null || _current?.dt == null) {
      currentBg = AppBg.dayClear;
    }

    try {
      if (_current?.sunset < _current?.dt) {
        if (id >= 200 && id <= 531) {
          currentBg = AppBg.nightRain;
        } else if (id >= 600 && id <= 622) {
          currentBg = AppBg.nightSnow;
        } else if (id >= 701 && id <= 781) {
          currentBg = AppBg.nightFog;
        } else if (id == 800) {
          currentBg = AppBg.nightClear;
        } else if (id == 801 && id <= 804) {
          currentBg = AppBg.nightCloud;
        }
      } else {
        if (id >= 200 && id <= 531) {
          currentBg = AppBg.dayRain;
        } else if (id >= 600 && id <= 622) {
          currentBg = AppBg.daySnow;
        } else if (id >= 701 && id <= 781) {
          currentBg = AppBg.dayFog;
        } else if (id == 800) {
          currentBg = AppBg.dayClear;
        } else if (id == 801 && id <= 804) {
          currentBg = AppBg.dayCloud;
        }
      }
      //
    } catch (e) {
      return AppBg.dayClear;
    }
    print(currentBg);
    return currentBg ?? AppBg.dayClear;
  }

  // текущая дата
  String? currentDay;
  String setCurrentDay() {
    final getTime = (current?.dt ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    currentDay = DateFormat('MMMM d').format(setTime);
    return currentDay ?? 'Error';
  }

  String? currentDate;
  String setCurrentDate() {
    final getTime = (current?.dt ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    currentDate = DateFormat('yMd').format(setTime);
    return currentDate ?? 'Error';
  }

  // текущее время
  String? currentTime;
  String setCurrentTime() {
    final getTime = (current?.dt ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    currentTime = DateFormat('HH:mm').format(setTime);
    return currentTime ?? 'Error';
  }

  // текущая иконка
  final String _weatherIconUrl = 'https://api.openweathermap.org/img/w/';

  String iconData() {
    return '$_weatherIconUrl${current?.weather?[0].icon}.png';
  }

  //
  String capitalize(String str) => str[0].toUpperCase() + str.substring(1);

  // статус погоды
  String currentStatus = '';
  String getCurrentStatus() {
    currentStatus = current?.weather?[0].description ?? 'Ошибка';
    return capitalize(currentStatus);
  }

  int kelvin = -273;

  // получение текущей температуры

  int currentTemp = 0;
  int setCurrentTemp() {
    currentTemp = ((current?.temp ?? -kelvin) + kelvin).round();
    return currentTemp;
  }

  // влажность
  int humidity = 0; // значение по умолчанию
  int setHumidity() {
    humidity = ((current?.humidity ?? 0) / 1).round();
    return humidity;
  }

  // ветер
  dynamic windSpeed = 0;
  dynamic setWindSpeed() {
    windSpeed = current?.windSpeed ?? 0;
    return windSpeed;
  }

  // ощущение температуры
  int feelsLike = 0;
  int setFeelslike() {
    feelsLike = ((current?.feelsLike ?? -kelvin) + kelvin).round();
    return feelsLike;
  }

  // погода на неделю

  // дни недели

  final List<String> date = [];
  List<Daily> daily = [];

  void setWeekday() {
    daily = weatherData?.daily ?? [];
    for (var i = 0; i < daily.length; i++) {
      if (i == 0 && daily.isNotEmpty) {
        date.clear();
      }

      var timeNum = daily[i].dt * 1000;
      var itemDate = DateTime.fromMillisecondsSinceEpoch(timeNum);
      date.add(capitalize(DateFormat('EEE d').format(itemDate)));
    }
  }

  // иконки на каждый день
  String setDailyIcons(int index) {
    final String getIcon = '${weatherData?.daily?[index].weather?[0].icon}';
    final String setIcon = '$_weatherIconUrl$getIcon.png';
    return setIcon;
  }

  // температура на каждый день

  int setDailyTemp(int index) {
    int dayTemp =
        ((weatherData?.daily?[index].temp?.day ?? -kelvin) + kelvin).round();
    return dayTemp;
  }

  // скорость ветра на каждый день
  int setDailyWindSpeed(int index) {
    int dayWindSpeed = (weatherData?.daily?[index].windSpeed ?? 0).round();
    return dayWindSpeed;
  }

  // восход
  String sunRise = '';
  String setSunrise() {
    final getTime =
        (current?.sunrise ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    sunRise = DateFormat('HH:MM').format(setTime);
    return sunRise;
  }

  String sunSet = '';
  String setSunset() {
    final getTime = (current?.sunset ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    sunSet = DateFormat('HH:MM').format(setTime);
    return sunSet;
  }

//
  openField() {
    isActive = true;
    notifyListeners();
  }

  var box = Hive.box<FavoriteHistory>(HiveBox.favoriteBox);

// добавление в избранное
  Future<void> setFavorite(BuildContext context, {String? cityName}) async {
    box
        .add(
          FavoriteHistory(
              cityName: currentCity,
              currentStatus: capitalize(currentStatus),
              humidity: '$humidity',
              icon: iconData(),
              temperature: '$currentTemp',
              windSpeed: '$windSpeed'),
        )
        .then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.white.withOpacity(0.7),
              content: Text(
                'The city $cityName has been added to saved locations',
                style: AppStyle.fontStyle
                    .copyWith(color: AppColors.black, shadows: []),
              ),
            ),
          ),
        );
  }

  // удаление из избранного
  Future<void> deleteFavorite(int index) async {
    box.deleteAt(index);
  }
}
