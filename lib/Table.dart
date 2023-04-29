// @dart=2.9
import 'dart:collection';
import 'package:agenda/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Account.dart';
import 'Appuntamento.dart';
import 'Calendar.dart';
import 'Update.dart';
import 'database_account.dart';
import 'database_helper.dart';
import 'package:device_calendar/device_calendar.dart' as device;

// Using a `LinkedHashSet` is recommended due to equality comparison override
final Set<DateTime> selectedDays = LinkedHashSet<DateTime>(
  equals: isSameDay,
  hashCode: getHashCode,
);

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final dbHelper = DatabaseHelper.instance;
  final dbAccount = DatabaseAccount.instance;
  List<Map<String, dynamic>> appuntamenti;
  List<Map<String, dynamic>> appuntamenti_of_day;
  List<Widget> _cardList = [];

  device.DeviceCalendarPlugin _deviceCalendarPlugin = new device.DeviceCalendarPlugin();
  List<device.Calendar> _calendars;
  device.Calendar _selectedCalendar;

  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() { 
    super.initState();
    _retrieveCalendars();
  }
  
  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> getNumberMonth() async{
    for(int month = 1;month <= 12;month++) {
      List<Map<String, dynamic>> number = await dbAccount.getMonth(month);
      dataMonth.add(
        NumberData(
          date: months[month-1],
          number: number.length,
        )
      );
      double prezzo = 0;
      for(Map<String, dynamic> item in number) {
        prezzo += (item['prezzo'] != '' ? item['prezzo'] : 0);
      }
      dataPrice.add(
        NumberData(
          date: months[month-1],
          number: prezzo.toInt(),
        )
      );
    }
  }

  Future<void> getNumberCLient() async{
    List<Map<String, dynamic>> number = await dbAccount.queryAllRows();
    List<String> clienti = [];
    for(Map<String, dynamic> client in number) {
      if(!clienti.contains(client['client'].toLowerCase())) {
        clienti.add(client['client'].toLowerCase());
        List<Map<String, dynamic>> client_appointment = await dbAccount.getClient(client['client'].toLowerCase());
        dataClient.add(
          NumberData(
            date: client['client'].toLowerCase(),
            number: client_appointment.length,
          )
      );
      }
    }
  }

  Future<void> getNumberDay() async{
    for(int day = 1;day <= 7;day++) {
      List<Map<String, dynamic>> number = await dbAccount.getDay(day);
      dataDay.add(
        NumberData(
          date: days[day -1],
          number: number.length,
        )
      );
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (selectedDays.contains(selectedDay)) {
        selectedDays.remove(selectedDay);
      } else {
        selectedDays.add(selectedDay);
      }
    });

    _selectedEvents.value = _getEventsForDays(selectedDays);
  }

  void _retrieveCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    setState(() {
      _calendars = calendarsResult?.data;
      _selectedCalendar = _calendars[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).size.height > 800 || MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
          children: [
            TableCalendar<Event>(
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if(events.length > 0) {
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: mainColor,
                      ),
                      child: Text(
                        events.length.toString(),
                        style: TextStyle(color: Colors.white,fontSize: 12,),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Container();
                },
              ),
              availableCalendarFormats: const {CalendarFormat.month : 'Mese',CalendarFormat.week: 'Settimana'},
              locale: 'it_IT',
              firstDay: kFirstDay,
              lastDay: kLastDay,
              calendarStyle: CalendarStyle(
                weekendTextStyle: TextStyle(
                  color: Colors.red.withOpacity(.8),
                ),
                markersAlignment: Alignment.bottomRight,
                markersAnchor: 0.5,
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withOpacity(.5),
                ),
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor,
                ),
              ),
              headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    color: mainColor.withOpacity(.3),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
                  formatButtonShowsNext: false,
              ),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                // Use values from Set to mark multiple days as selected
                return selectedDays.contains(day);
              },
        
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              child: Text(
                'Annulla selezione',
                style: TextStyle(
                  color: mainColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedDays.clear();
                  _selectedEvents.value = [];
                });
              },
              style: ElevatedButton.styleFrom(
                primary: mainColor.withOpacity(.2), //background color of button
                elevation: 0, //elevation of button
                shape: RoundedRectangleBorder( //to set border radius to button
                borderRadius: BorderRadius.circular(100)
                ),
                padding: EdgeInsets.all(20) //content padding inside button
              ),            
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Slidable(
                          direction: Axis.horizontal,
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: ListTile(
                              onTap: () async{
                                List<String> event = '${value[index]}'.split(': ');
                                String name = event[0];
                                String date = event[1];
                                List<Map<String, dynamic>> appointment = await dbHelper.getFromDay(name, date);
                                _onAppointmentPressed(context, appointment[0]);
                              },
                              title: Text('${value[index]}'),
                            ),
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () async {
                                List<String> event = '${value[index]}'.split(': ');
                                String name = event[0];
                                String date = event[1];
                                List<Map<String, dynamic>> app = await dbHelper.getFromDay(name, date);
                                _onDeletePressed(context, app[0]);
                              },
                            ),
                            IconSlideAction(
                              caption: 'Modifica',
                              color: Colors.blue,
                              icon: Icons.create_rounded,
                              onTap: () async {
                                List<String> event = '${value[index]}'.split(': ');
                                String name = event[0];
                                String date = event[1];
                                List<Map<String, dynamic>> app = await dbHelper.getFromDay(name, date);
                                var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage(app[0])));
                                if(res == null || res == true) {
                                  if(currentClient != null) {
                                    var res = await dbHelper.update(currentClient.toMap());
                                    List<String> data_current = currentClient.date.split('/');
                                    int month = data_current[1][0] == 0 ? data_current[1][1] : int.parse(data_current[1]);
                                    int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                                    await dbAccount.update({
                                      'key': currentClient.key,
                                      'client': currentClient.client.toLowerCase(),
                                      'day': DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0]).weekday,
                                      'month': month,
                                      'year' : year,
                                      'prezzo' : currentClient.prezzo,
                                    });
                                    setState(() {
                                      selectedDays.clear();
                                      _selectedEvents.value = [];
                                    });
                                    getDatabase();
                                    if(res == null || res == true) {
                                      currentClient = null;
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
    } else {
      return Center(
        child: Container(
          child: Text(
            'Ruotare lo schermo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> cloneAppuntamenti(List<Map<String, dynamic>> original) {
    List<Map<String, dynamic>> clone = [];
    for(Map<String, dynamic> item in original) {
      clone.add(item);
    }
    clone.sort(
      (a,b) {
        String a_data = a['date'];
        String b_data = b['date'];
        Date data_comp = Date((a_data.split('/'))[0],(a_data.split('/'))[1],(a_data.split('/'))[2]);
        Date data_other = Date((b_data.split('/'))[0],(b_data.split('/'))[1],(b_data.split('/'))[2]);
        return data_comp.compareTo(data_other);      
    });
    return clone;
  }

  void _addCardWidget(Map<String, dynamic> app) {
    _cardList.add(_card(app));
  }

  Widget _card(Map<String, dynamic> app) {
    return Container(
      height: 150,
      margin: EdgeInsets.only(top: 5,left: 8,right: 8),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color:  mainColor.withOpacity(.2),
      ),
      child: Center(
        child: ListTile(
          onTap: () => _onAppointmentPressed(context,app),
          title: Text(
            app['client'],
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainColor),
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            app['date'],
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black),
                textAlign: TextAlign.center,
          ),
          trailing: Card(
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 120,
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    IconButton(
                      onPressed: () async {
                        _onDeletePressed(context, app);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 10,),
                    IconButton(
                      onPressed: () async {
                        var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage(app)));
                        if(res == null || res == true) {
                          if(currentClient != null) {
                            var res = await dbHelper.update(currentClient.toMap());
                            List<String> data_current = currentClient.date.split('/');
                            int month = data_current[1][0] == 0 ? data_current[1][1] : int.parse(data_current[1]);
                            int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                            await dbAccount.update({
                              'key': currentClient.key,
                              'client': currentClient.client.toLowerCase(),
                              'day': DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0]).weekday,
                              'month': month,
                              'year' : year,
                              'prezzo' : currentClient.prezzo,
                            });
                            getDatabase();
                            if(res == null || res == true) {
                              currentClient = null;
                            }
                          }
                        }
                      },
                      icon: Icon(
                        Icons.create_rounded,
                        color: Colors.black,
                        size: 30,
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<int> getDatabase() async {
    num = await dbHelper.queryRowCount();   
    num_tot = await dbAccount.queryRowCount();
    appuntamenti = await dbHelper.queryAllRows();
    appuntamenti_of_day = cloneAppuntamenti((await dbHelper.queryAllRowsOfDay(start, end)));
    list_of_appointment = appuntamenti;
    num_of_day = appuntamenti_of_day.length;
    num_of_appointment = {};
    for(int i = 0; i < num;i++) {
      String data = appuntamenti[i]['date'];
      Date data_comp = Date((data.split('/'))[0],(data.split('/'))[1],(data.split('/'))[2]);
      Date data_odierna = Date((now.split('/'))[0],(now.split('/'))[1],(now.split('/'))[2]);
      if(data_comp.compareTo(data_odierna) < 0) {
        _delete_past(data);
      }
      String new_start = data.split('/')[0] + '/' + (data.split('/'))[1] + '/2021 - 00:00';
      String new_end = data.split('/')[0] + '/' + (data.split('/'))[1] + '/2021 - 24:00';
      List<Map<String, dynamic>> number = await dbHelper.queryAllRowsOfDay(new_start,new_end);
      num_of_appointment.putIfAbsent(appuntamenti[i]['date'], () => number);
    }
    _cardList = [];
    setState(() {
      for(int i = 0; i < num_of_day;i++) _addCardWidget(appuntamenti_of_day[i]);
    });

    var _kEventSource = Map.fromIterable(list_of_appointment,
    key: (item) => DateTime.utc(DateTime.now().year, item['date'].split('/')[1][0] != 0 ? int.parse(item['date'].split('/')[1]) : int.parse(item['date'].split('/')[1][1]),  item['date'].split('/')[0][0] != 0 ? int.parse(item['date'].split('/')[0]) : int.parse(item['date'].split('/')[0][1])),
    value: (item) => List.generate(
        (num_of_appointment[item['date']]).length, (index) => Event((num_of_appointment[item['date']])[index]['client'] + ': ' + (num_of_appointment[item['date']])[index]['date'])
      )
    );
     kEvents = LinkedHashMap<DateTime, List<Event>> (
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);
    dataMonth = [];
    dataPrice = [];
    await getNumberMonth();
    dataDay = [];
    await getNumberDay();
    dataClient = [];
    await getNumberCLient();
    return num;
  }

  void _delete(int key) async {
    await dbHelper.delete(key);
  }

  void _delete_past(String key) async {
    await dbHelper.delete_past(key);
  } 

   _onAppointmentPressed(context,app) {
    Alert(
      closeFunction: () {
        Navigator.pop(context);        
      },
      style: AlertStyle(
        descTextAlign: TextAlign.start,
        titleStyle: TextStyle(
          color: mainColor,
          fontSize: 30
        ),
        descStyle: TextStyle(
          fontSize: 23
        ),
      ),
      context: context,
      title: "Appuntamento",
      desc: "Cliente: " + app['client']  + 
            "\nNumero: " + (app['phoneNumber']).toString() +
            ((app['email']).toString() != '' ? "\nEmail: " + (app['email']).toString() : '') +
            "\nData: " + (app['date']).toString() + ( app['Servizio'] != '' ?
            "\nServizio: " + (app['Servizio']).toString() : '') +
            (app['prezzo'].toString() != '' ? "\nPrezzo: " + (app['prezzo']).toString() + '€' : ''), 
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(100),
          child: Icon(
            Icons.check_sharp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.greenAccent[400],
        ),
        DialogButton(
          radius: BorderRadius.circular(100),
          child: Icon(
            Icons.delete_sharp,
          ),
          onPressed: () async {
            Navigator.pop(context);
            _onDeletePressed(context, app);
          },
          color: Colors.red,
        ),
        DialogButton(
          radius: BorderRadius.circular(100),
          child: Icon(
            Icons.create_sharp,
          ),
          onPressed: () async {
            Navigator.pop(context);
            var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage(app)));
            if(res == null || res == true) {
              if(currentClient != null) {
                var res = await dbHelper.update(currentClient.toMap());
                List<String> data_current = currentClient.date.split('/');
                int month = data_current[1][0] == 0 ? data_current[1][1] : int.parse(data_current[1]);
                int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                await dbAccount.update({
                  'key': currentClient.key,
                  'client': currentClient.client.toLowerCase(),
                  'day': DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0]).weekday,
                  'month': month,
                  'year' : year,
                  'prezzo' : currentClient.prezzo,
                });
                getDatabase();
                if(res == null || res == true) {
                  currentClient = null;
                }
              }
            }            
          },
          color: Colors.blue,
        ),
      ],
    ).show();
  }
 
  _onDeletePressed(context,app) {
    Alert(
      closeFunction: () {
        Navigator.pop(context);     
      },
      style: AlertStyle(
        titleStyle: TextStyle(
          color: mainColor,
        ),
        descStyle: TextStyle(
          color: mainColor.withOpacity(.4),
        ),
      ),
      context: context,
      title: "Elimina Appuntamento",
      desc: "confermi la tua scelta?",
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(100),
          child: Text(
            "SI",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async{
            await _deviceCalendarPlugin.deleteEvent(selectedCalendar.id, (app['calendar']).toString());
            await _delete(app['key']);
            await dbAccount.delete(app['key']);
            getDatabase();
            setState(() {
              selectedDays.clear();
              _selectedEvents.value = [];
            });
            Navigator.pop(context);
          },
          color: Colors.greenAccent[400],
        ),
        DialogButton(
          radius: BorderRadius.circular(100),
          child: Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () { 
            Navigator.pop(context);
          },
          color: Colors.redAccent,
        )
      ],
    ).show();
  }
}

