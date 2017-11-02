// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spotitem/models/item.dart';

const double _kDatePickerHeaderPortraitHeight = 100.0;
const double _kDatePickerHeaderLandscapeWidth = 168.0;

const Duration _kMonthScrollDuration = const Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight = _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

const double _kMonthPickerPortraitWidth = 330.0;
const double _kMonthPickerLandscapeWidth = 344.0;

const double _kDialogActionBarHeight = 52.0;
const double _kDatePickerLandscapeHeight = _kMaxDayPickerHeight + _kDialogActionBarHeight;

class _CalendarGridDelegate extends SliverGridDelegate {
  const _CalendarGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final columnCount = DateTime.DAYS_PER_WEEK;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final tileHeight =
        math.min(_kDayPickerRowHeight, constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return new SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_CalendarGridDelegate oldDelegate) => false;
}

const _CalendarGridDelegate _kCalendarGridDelegate = const _CalendarGridDelegate();

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
///
/// The day picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker].
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
class CalendarMonth extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  const CalendarMonth({
    @required this.selectedDates,
    @required this.currentMonth,
    @required this.firstDate,
    @required this.lastDate,
    @required this.onChanged,
    this.allowDisable = false,
    Key key,
  })
      : assert(selectedDates != null),
        assert(currentMonth != null),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(onChanged != null),
        super(key: key);

  /// The currently selected dates.
  ///
  /// Dates are highlighted in the picker.
  final List<Event> selectedDates;

  /// Disable days which are after lastDay and before Firstday
  final bool allowDisable;

  /// Current Month
  final DateTime currentMonth;

  /// First date of list
  final DateTime firstDate;

  /// Last date of list
  final DateTime lastDate;

  /// Called when the user picks a day.
  final ValueChanged<List<Event>> onChanged;

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(TextStyle headerStyle, MaterialLocalizations localizations) {
    final result = <Widget>[];
    for (var i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final weekday = localizations.narrowWeekdays[i];
      result.add(new Center(child: new Text(weekday, style: headerStyle)));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) {
        break;
      }
    }
    return result;
  }

  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _kDaysInMonth = const <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.FEBRUARY) {
      final isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) {
        return 29;
      }
      return 28;
    }
    return _kDaysInMonth[month - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final weekdayFromMonday = new DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final currentDate = new DateTime.now();
    final year = currentMonth.year;
    final month = currentMonth.month;
    final dates = new List<Event>.from(selectedDates);
    final daysInMonth = getDaysInMonth(year, month);
    final firstDayOffset = _computeFirstDayOffset(year, month, localizations);
    final labels = _getDayHeaders(themeData.textTheme.caption, localizations);
    for (var i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final day = i - firstDayOffset + 1;
      if (day > daysInMonth) {
        break;
      }
      if (day < 1) {
        labels.add(new Container());
      } else {
        final dayToBuild = new DateTime(year, month, day);
        final disabled = (dayToBuild.isAfter(lastDate) || dayToBuild.isBefore(firstDate)) && !allowDisable;
        BoxDecoration decoration;
        var itemStyle = themeData.textTheme.body1;
        final current = dates.firstWhere(
            (f) => f.date.day == dayToBuild.day && f.date.month == dayToBuild.month && f.date.year == dayToBuild.year,
            orElse: () => null);
        if (current != null) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = new BoxDecoration(color: themeData.accentColor, shape: BoxShape.circle);
        } else if (currentDate.year == year && currentDate.month == month && currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1.copyWith(color: themeData.disabledColor);
        }

        Widget dayWidget = new Container(
          decoration: decoration,
          child: new Center(
            child: new Text(localizations.formatDecimal(day), style: itemStyle),
          ),
        );
        if (!disabled) {
          dayWidget = new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (current != null) {
                selectedDates.removeWhere((f) =>
                    f.date.day == dayToBuild.day && f.date.month == dayToBuild.month && f.date.year == dayToBuild.year);
              } else {
                selectedDates.add(new Event({'date': dayToBuild.toString()}));
              }
              onChanged(selectedDates);
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Column(
        children: <Widget>[
          new Container(
            height: _kDayPickerRowHeight,
            child: new Center(
              child: new GestureDetector(
                // onTap: onMonthHeaderTap != null ? Feedback.wrapForTap(onMonthHeaderTap, context) : null,
                child: new Text(
                  localizations.formatMonthYear(currentMonth),
                  style: themeData.textTheme.subhead,
                ),
              ),
            ),
          ),
          new Flexible(
            child: new GridView.custom(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _kCalendarGridDelegate,
              childrenDelegate: new SliverChildListDelegate(labels, addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}
