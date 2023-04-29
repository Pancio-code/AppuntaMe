// @dart=2.9
import 'dart:collection';
import 'package:agenda/main.dart';
import 'package:table_calendar/table_calendar.dart';


/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
var kEvents = LinkedHashMap<DateTime, List<Event>> (
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

var _kEventSource = Map.fromIterable(list_of_appointment,
    key: (item) => DateTime.utc(DateTime.now().year, item['date'].split('/')[1][0] != 0 ? int.parse(item['date'].split('/')[1]) : int.parse(item['date'].split('/')[1][1]),  item['date'].split('/')[0][0] != 0 ? int.parse(item['date'].split('/')[0]) : int.parse(item['date'].split('/')[0][1])),
    value: (item) => List.generate(
        (num_of_appointment[item['date']]).length, (index) => Event((num_of_appointment[item['date']])[index]['client'] + ': ' + (num_of_appointment[item['date']])[index]['date'])
      )
    );

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/* Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}*/

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);