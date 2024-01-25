import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/domain/providers/weather_provider.dart';
import 'package:weather_app/ui/style/app_colors.dart';
import 'package:weather_app/ui/style/app_style.dart';

class WeekDayItems extends StatelessWidget {
  const WeekDayItems({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WeatherProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 21),
      decoration: BoxDecoration(
        color: AppColors.weekDayBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: 150,
        child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              return DayItem(
                date: model.date[i],
                dayTemp: model.setDailyTemp(i),
                icon: model.setDailyIcons(i),
                windSpeed: '${model.setDailyWindSpeed(i)} km/h',
              );
            },
            separatorBuilder: (__, _) => const SizedBox(
                  width: 45,
                ),
            itemCount: model.date.length - 3),
      ),
    );
  }
}

class DayItem extends StatelessWidget {
  const DayItem({
    super.key,
    required this.date,
    required this.dayTemp,
    required this.icon,
    required this.windSpeed,
  });

  final String date;
  final String icon;
  final int dayTemp;
  final String windSpeed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date,
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.dayItemColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 13,
        ),
        Image.network(icon),
        const SizedBox(
          height: 7,
        ),
        Text(
          '$dayTemp °C',
          style: AppStyle.fontStyle
              .copyWith(fontSize: 16, color: AppColors.dayItemColor),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          windSpeed,
          style: AppStyle.fontStyle
              .copyWith(fontSize: 16, color: AppColors.dayItemColor),
        ),
      ],
    );
  }
}
