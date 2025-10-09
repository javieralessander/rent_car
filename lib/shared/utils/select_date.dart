import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectDate {
  DateTime selectedDate = DateTime.now();

  Future<DateTime?> selectDate(
    BuildContext context,
    DateTime dateSelected,
  ) async {
    if (Platform.isIOS) {
      // if (dateSelected != selectedDate) {
      //   selectedDate = dateSelected;
      // } else {
      //   selectedDate = DateTime.now();
      // }
      DateTime? pickedDate;
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).size.height / 3,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: dateSelected,
              onDateTimeChanged: (DateTime newDate) {
                pickedDate = newDate;
              },
              minimumYear: 1900,
              maximumYear: DateTime.now().year,
            ),
          );
        },
      );
      return pickedDate;
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateSelected,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      return picked;
    }
  }
}
