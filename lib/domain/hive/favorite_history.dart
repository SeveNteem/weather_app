import 'package:hive/hive.dart';

part 'favorite_history.g.dart';

@HiveType(typeId: 0)
class FavoriteHistory {
  @HiveField(0)
  String cityName;

  @HiveField(1)
  String currentStatus;

  @HiveField(2)
  String humidity;

  @HiveField(3)
  String windSpeed;

  @HiveField(4)
  String icon;

  @HiveField(5)
  String temperature;

  FavoriteHistory({
    required this.cityName,
    required this.currentStatus,
    required this.humidity,
    required this.icon,
    required this.temperature,
    required this.windSpeed,
  });
}
