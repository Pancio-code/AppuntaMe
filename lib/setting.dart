//@dart=2.9
import 'dart:io';

import 'package:agenda/database_account.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:agenda/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/Theme.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final dbAccount = DatabaseAccount.instance;
  DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();
  List<Calendar> _calendars;
  Calendar _selectedCalendar;
  String _chosenValue;
  String _chosenTime;
  String _chosenReminder;
  List<String> names_calendars = [];
  TextEditingController numberController = new TextEditingController();

  @override
  void initState() {
    _retrieveCalendars();
    _retriveDuration();
    _retriveNumber();
    _retriveReminder();
    super.initState();
  }
    
  _share() async {
    String text = '';
    List<Map<String, dynamic>> app = await dbAccount.queryAllRows();
    for(Map<String, dynamic> item in app) {
      text += item['client'] + ": "  + (item['day'] > 9 ? item['day'].toString() : '0' + item['day'].toString())  + "/" + (item['month'] > 9 ? item['month'].toString() : '0' + item['month'].toString()) + "/"  + item['year'].toString() + "  " +(item['prezzo'].toString()) + "€" "\n"; 
    }
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/databse.txt');
    await file.writeAsString(text);
    await Share.shareFiles(['${directory.path}/databse.txt']);
  }

  Calendar getCalendarById(String id) {
    if(id == null) return null;
    for(Calendar item in _calendars) {
      if(item.id == id) return item;
    }
    return null;
  }
  
  Calendar getCalendarByName(String name) {
    if(name == null) return null;
    for(Calendar item in _calendars) {
      if(item.name == name) return item;
    }
    return null;
  }

  void _retriveDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int duration = prefs.getInt('duration') ?? 0;
    if(duration != 0) {
      _chosenTime = duration > 3 ? duration.toString() + ' m' : duration.toString() + ' h';
    }
  }

  void _retriveReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String reminder= prefs.get('reminder') ?? 'Nessun promemoria';
    if(reminder != 'Nessun promemoria') {
      _chosenReminder = int.parse(reminder) > 3 ? reminder + ' m' : reminder + ' h';
    }
  }

  void _retrieveCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _calendars = calendarsResult?.data;
    });
    String id = prefs.get('calendar');
    if(id != null) {
      _selectedCalendar = getCalendarById(id);
      _chosenValue = _selectedCalendar.name;
    } else {
      _selectedCalendar = _calendars[0];
    }
    _calendars.forEach((element) {names_calendars.add(element.name); });
  }

  void _retriveNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     String number = prefs.get('number');
     if(number != null) {
       numberController = TextEditingController( text: number); 
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: EdgeInsets.only(left: 25),
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: mainColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "Impostazioni",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "seleziona le tue preferenze",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.brightness_2,color: Colors.black,),
                  title: Text(
                    'Tema Scuro',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  ),
                  trailing: ChangeThemeButtonWidget(),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.calendar_today_outlined,color: Colors.black,),
                  title: DropdownButton<String>(
                    itemHeight: null,
                    isExpanded: true,
                    value: _chosenValue,
                    //elevation: 5,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: mainColor,
                    ),
                    items: names_calendars.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text(
                      "Seleziona Calendario",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: mainColor,
                      ),
                    ),
                    onChanged: (String value) async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      setState(() {
                        _chosenValue = value;
                        selectedCalendar = getCalendarByName(_chosenValue);
                      });
                      await prefs.setString('calendar', getCalendarByName(_chosenValue).id);
                    },
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.update,color: Colors.black,),
                  title: DropdownButton<String>(
                    itemHeight: null,
                    isExpanded: true,
                    value: _chosenTime,
                    //elevation: 5,
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                    items: <String>[
                      '10 m',
                      '20 m',
                      '30 m',
                      '40 m',
                      '50 m',
                      '1 h',
                      '2 h',
                      '3 h',                        
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text(
                      "Durata Appuntamento",
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    onChanged: (String value) async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('duration', value.length > 3 ? int.parse(value[0] + value[1]) : int.parse(value[0]));
                      setState(() {
                        _chosenTime = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.notifications_active_sharp,color: Colors.black,),
                  title: DropdownButton<String>(
                    itemHeight: null,
                    isExpanded: true,
                    value: _chosenReminder,
                    //elevation: 5,
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                    items: <String>[
                      '10 m',
                      '20 m',
                      '30 m',
                      '40 m',
                      '50 m',
                      '1 h',
                      '2 h',
                      '3 h',
                      'Nessun promemoria',                        
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text(
                      "Promemoria",
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    onChanged: (String value) async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      if(value == "Nessun promemoria") await prefs.setString('reminder', value);
                      else await prefs.setString('reminder', value.length > 3 ? value[0] + value[1] : value[0]);
                      setState(() {
                        _chosenReminder = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.phone_rounded,color: Colors.black,),
                  title: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: mainColor,
                      ),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        Pattern phonePattern = r"^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}";
                        RegExp regexNumber = new RegExp(phonePattern);
                        if (!regexNumber.hasMatch(numberController.text) || numberController.text == null)
                          return "Numero inserito invalido";
                        return null;
                      },
                      cursorColor: mainColor,
                      controller: numberController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "N° Di telefono",
                        labelStyle: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear,color: mainColor,),
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.remove('number');
                            numberController.clear();
                          }
                        ),
                      ),
                      onChanged: (numero) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('number', numero);
                      },
                    ),      
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.data_saver_off_sharp,color: Colors.black,),
                  title: Text(
                    'Database',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  ),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.download_sharp,color: Colors.black,),
                    label: Text("Download",style: TextStyle(color: Colors.black,),),
                    style: ElevatedButton.styleFrom(
                        primary: mainColor,
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                    ),
                    onPressed: () {
                      _share();
                    },
                  ),
                ),
                SizedBox(height: 30,),
              ],
            ),
          )                     
        ),
      ),
    
    );
  } 
}
