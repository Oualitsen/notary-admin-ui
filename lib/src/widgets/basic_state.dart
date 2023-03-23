import 'package:notary_model/model/address.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/gender.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class BasicState<T extends StatefulWidget> extends State<T>
    with LangMixin {
  @override
  void dispose() {
    for (var element in subjects) {
      element.close();
    }
    for (var element in notifiers) {
      element.dispose();
    }

    super.dispose();
  }

  List<Subject> get subjects;

  List<ChangeNotifier> get notifiers;
}

extension AppLocalizationsExt on AppLocalizations {
  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  static final DateFormat _timeFormat = DateFormat("HH:mm");

  static final DateFormat _dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static final DateFormat _dayFormat = DateFormat("E dd");
  String formatDateDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  String formatDateMillis(int date) {
    return formatDateDate(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatDate(int date) {
    return _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatAddress(Address address) {
    return "${address.street},${address.city}, ${address.state}, ${address.postalCode},${address.country}";
  }

  String formatTime(int date) {
    return _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    return formatTime(DateTime(0, 1, 1, timeOfDay.hour, timeOfDay.minute)
        .millisecondsSinceEpoch);
  }

  String formatDateTime(int date) {
    return _dateTimeFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String genderName(Gender gender) {
    switch (gender) {
      case Gender.MALE:
        return genderMale;
        break;
      case Gender.FEMALE:
        return genderFemale;
    }
  }

  String selectionType(Gender gender) {
    switch (gender) {
      case Gender.MALE:
        return genderMale;
        break;
      case Gender.FEMALE:
        return genderFemale;
    }
  }

  String formatDay(int date) {
    return _dayFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatTimeOfTheDay(TimeOfDay timeOfDay) {
    return "${addZero(timeOfDay.hour)}:${addZero(timeOfDay.minute)}";
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return (dateTime.subtract(
      Duration(
        days: dateTime.weekday - 1,
      ),
    ));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  String addZero(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  String genderValue(Gender s) {
    switch (s) {
      case Gender.MALE:
        return genderMale;
      case Gender.FEMALE:
        return genderFemale;
    }
  }

  String monthName(int date) {
    return DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(date));
  }
}
