// @dart=2.9
import 'package:agenda/Appuntamento.dart';
import 'package:agenda/helperFunctions.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/main.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdatePage extends StatefulWidget {
  Map<String, dynamic> oldApp;
  UpdatePage(this.oldApp);
  @override
  _UpdatePageState createState() => _UpdatePageState(oldApp);
}

class _UpdatePageState extends State<UpdatePage> {
  Map<String, dynamic> oldApp;
  Iterable<Contact> _contacts;
  TextEditingController numberController;
  TextEditingController nameController;
  TextEditingController serviziController;
  TextEditingController dateController;
    TextEditingController mailController;
  TextEditingController prezzoController;
  final _formKey = GlobalKey<FormState>();
  DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

  _UpdatePageState(this.oldApp);

  @override
  void initState() {
    numberController = new TextEditingController(text: oldApp['phoneNumber']);
    nameController = new TextEditingController(text: oldApp['client']);
    serviziController = new TextEditingController(text: oldApp['Servizio']);
    dateController = new TextEditingController(text: oldApp['date']);
    mailController = new TextEditingController(text: oldApp['email']);
    prezzoController = new TextEditingController(text: oldApp['prezzo'].toString());
    getContacts();
    super.initState();
  }


  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    nameController.addListener(() {
      filterContacts();
    });
    setState(() {
      _contacts = contacts;
    });
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr[0] == '+' && phoneStr.length > 2 ? phoneStr.substring(3).replaceAll(" ", "") : phoneStr.replaceAll(" ", "");
  }

  Future<void> filterContacts() async{
    final Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false,query: nameController.text);
    setState(() {
      _contacts = contacts;
    });
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
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    oldApp['client'],
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "modifica appuntamento",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: mainColor.withOpacity(.4),
                    ),
                  ),
                  SizedBox(height: 30,),                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: mainColor,
                        ),
                      ),
                      child: SimpleAutocompleteFormField<Contact>(
                        validator: (value) {
                          if (nameController.text == null)
                            return "inserire un nome";
                          else if(nameController.text.length < 2)
                          return "nome inserito errato";
                          else 
                            return null;
                        },
                        controller: nameController,
                        maxSuggestions: 5,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person_rounded,size: 30,),
                          labelText: "NOME",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        suggestionsHeight: 120.0,
                        itemBuilder: (context, contact) => Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(contact.displayName ?? '', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                            Text(HelperFunctions.getValidPhoneNumber(contact.phones) ?? 'Nessun Numero',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.grey[400],),)
                          ]),
                        ),
                        onSearch: (search) async => _contacts
                            .where((contact) =>
                                contact.displayName != null ? contact.displayName.toLowerCase().contains(search.toLowerCase()) : false ||
                                HelperFunctions.getValidPhoneNumber(contact.phones) != null ? HelperFunctions.getValidPhoneNumber(contact.phones).contains(search.toLowerCase()) : false)
                            .toList(),
                        itemToString: (contact) {
                          if(contact != null && contact.displayName == nameController.text) {
                            numberController.text = flattenPhoneNumber(HelperFunctions.getValidPhoneNumber(contact.phones)) ?? '';
                          }
                          return contact != null ? contact.displayName : nameController.text;
                        },
                        onTap: () {
                          nameController.clear();
                          nameController.value = TextEditingValue( text: "", selection: TextSelection.fromPosition( TextPosition(offset: 0), ),);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
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
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.phone_rounded,size: 30,),
                          labelText: "N° DI TELEFONO",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              numberController.clear();
                            }
                          ),
                        ),
                        onSaved: (numero) {
                          numberController.value = TextEditingValue( text: numero);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: mainColor,
                        ),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          Pattern mailPattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                          RegExp regexNumber = new RegExp(mailPattern);
                          if(value == '') return null;
                          else if (!regexNumber.hasMatch(mailController.text) || mailController.text == null)
                            return "email inserita invalida";
                          return null;
                        },
                        cursorColor: mainColor,
                        controller: mailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.mail_outline_sharp,size: 30,),
                          labelText: "E-MAIL",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              mailController.clear();
                            }
                          ),
                        ),
                        onSaved: (mail) {
                          mailController.value = TextEditingValue( text: mail);
                        },
                      ),      
                    ),
                  ),                  
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: mainColor,
                        ),
                      ),
                      child: DateTimeField(
                        validator: (value) {
                          if (dateController.text == null)
                            return "Inserire data e ora";
                          else if(dateController.text.length < 2)
                            return "Data inserita errata";
                          else
                            return null;
                        },
                        controller: dateController,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.calendar_today_rounded,size: 30,),
                          labelText: "DATA E ORA",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        format: DateFormat("dd/MM/yyyy - HH:mm"),
                        onShowPicker: (context, currentValue) async {
                          final date_now = await showDatePicker(
                            locale: const Locale("it","IT"),
                            context: context,
                            firstDate: DateTime(date.year,date.month,date.day),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.fromSwatch(
                                    primarySwatch: mainColor,
                                  ),
                                ),
                                child: child,
                              );
                            }
                          );
                          if (date_now != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                              builder: (BuildContext context, Widget child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.fromSwatch(
                                      primarySwatch: mainColor,
                                    ),
                                  ),
                                  child: child,
                                );
                              }
                            );
                            return DateTimeField.combine(date_now, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: mainColor,
                        ),
                      ),
                      child: TextFormField(
                        controller: serviziController,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.work_rounded,size: 30,),
                          labelText: "SERVIZIO",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              serviziController.clear();
                            }
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: mainColor,
                        ),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if(value == '') return null;
                          try {
                            double.parse(value);
                            return null;
                          } catch(e) {
                            return "prezzo inserito invalido";
                          }
                        },
                        keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                        controller: prezzoController,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.euro_symbol_sharp,size: 30,),
                          labelText: "PREZZO",
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: mainColor.withOpacity(.4),
                            fontWeight: FontWeight.w800,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              prezzoController.clear();
                            }
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox( 
                          height:80, //height of button
                          width:150, //width of button
                          child:ElevatedButton.icon(
                            icon: Icon(Icons.message_sharp),
                            label: Text("MODIFICA"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.greenAccent[400], //background color of button
                              elevation: 3, //elevation of button
                              shape: RoundedRectangleBorder( //to set border radius to button
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              padding: EdgeInsets.all(20) //content padding inside button
                            ),
                            onPressed: () async{ 
                              if(_formKey.currentState.validate()) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String reminder_time = prefs.get('reminder') ?? "Nessun promemoria";
                                int number_saved = prefs.get('number');
                                int duration = prefs.getInt('duration') ?? 1;
                                List<String> data_current = dateController.text.split('/');
                                int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                                var eventToCreate;
                                if(reminder_time == "Nessun promemoria")
                                  eventToCreate = new Event.fromJson({
                                    'calendarId' : selectedCalendar.id,
                                    'eventId' : (oldApp['calendar']).toString(),
                                  });
                                else 
                                  eventToCreate = new Event.fromJson({
                                    'calendarId' : selectedCalendar.id,
                                    'eventId' : (oldApp['calendar']).toString(),
                                    'reminders' : [{'minutes' : reminder_time.length == 1 ? int.parse(reminder_time)*60 : int.parse(reminder_time)}]
                                  });
                                eventToCreate.title = 'Appuntamento: ' + nameController.text;
                                eventToCreate.start = DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0] + " " + data_current[2].split("- ")[1] + ":00");
                                eventToCreate.description = "Cliente: " + nameController.text + "\nNumero: " + numberController.text + (mailController.text != '' ? "\nMail: " + mailController.text : "") +  "\nData: " + dateController.text + (serviziController.text != '' ? "\nServizio: " + serviziController.text : '' + (prezzoController.text != '' ? "\nPrezzo: " + prezzoController.text + "€" : "") );
                                if(duration > 3)  eventToCreate.end = eventToCreate.start.add(new Duration(minutes: duration));
                                else eventToCreate.end = eventToCreate.start.add(new Duration(hours: duration));
                                Result<String> key =await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);
                                _sendSMS("Modificato appuntamento per il " + dateController.text + (serviziController.text.length > 2 ? "\nServizio: " + serviziController.text : "") + (prezzoController.text != '' ? "\nPrezzo: " + prezzoController.text + "€" : "") + (number_saved != null ? "\nPer eventuali modifiche chiamare: 3888865279" : ''), [numberController.text]);

                                currentClient = new Appuntamento(oldApp['key'], nameController.text, numberController.text,mailController.text,dateController.text,serviziController.text,prezzoController.text,int.parse(key.data));
                                bool esiste = false;
                                _contacts.forEach((element) { 
                                  if(element.displayName == nameController.text && flattenPhoneNumber(HelperFunctions.getValidPhoneNumber(element.phones)) == numberController.text) {
                                    esiste = true;
                                    return;
                                  }
                                });
                                if(esiste) {
                                  Navigator.of(context).pop();
                                } else {
                                  _onAlertButtonsPressed(context);
                                }
                              }
                            }, 
                          ),
                        ),
                        SizedBox(width: 30,),
                        SizedBox( 
                          height:80, //height of button
                          width:150, //width of button
                          child:ElevatedButton.icon(
                            icon: Icon(Icons.share),
                            label: Text("SHARE"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.greenAccent[400], //background color of button
                              elevation: 3, //elevation of button
                              shape: RoundedRectangleBorder( //to set border radius to button
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              padding: EdgeInsets.all(20) //content padding inside button
                            ),
                            onPressed: () async{ 
                              if(_formKey.currentState.validate()) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                int number_saved = prefs.get('number');
                                String reminder_time = prefs.get('reminder') ?? "Nessun promemoria";
                                int duration = prefs.getInt('duration') ?? 1;
                                List<String> data_current = dateController.text.split('/');
                                int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                                var eventToCreate;
                                if(reminder_time == "Nessun promemoria")
                                  eventToCreate = new Event.fromJson({
                                    'calendarId' : selectedCalendar.id,
                                    'eventId' : (oldApp['calendar']).toString(),
                                  });
                                else 
                                  eventToCreate = new Event.fromJson({
                                    'calendarId' : selectedCalendar.id,
                                    'eventId' : (oldApp['calendar']).toString(),
                                    'reminders' : [{'minutes' : reminder_time.length == 1 ? int.parse(reminder_time)*60 : int.parse(reminder_time)}]
                                  });
                                eventToCreate.title = 'Appuntamento: ' + nameController.text;
                                eventToCreate.start = DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0] + " " + data_current[2].split("- ")[1] + ":00");
                                eventToCreate.description = "Cliente: " + nameController.text + "\nNumero: " + numberController.text + (mailController.text != '' ? "\nMail: " + mailController.text : "") + "\nData: " + dateController.text + (serviziController.text != '' ? "\nServizio: " + serviziController.text : '') + (prezzoController.text != '' ? "\nPrezzo: " + prezzoController.text + "€" : "");
                                if(duration > 3)  eventToCreate.end = eventToCreate.start.add(new Duration(minutes: duration));
                                else eventToCreate.end = eventToCreate.start.add(new Duration(hours: duration));
                                Result<String> key = await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);
                                if(mailController.text != '')
                                  await Share.share("Modificato appuntamento per il " + dateController.text + (serviziController.text.length > 2 ? "\nServizio: " + serviziController.text : "") + (prezzoController.text != '' ? "\nPrezzo: " + prezzoController.text + "€" : "")+ (number_saved != null ? "\nPer eventuali modifiche chiamare: 3888865279" : ''));
                                else 
                                  await Share.share("Modificato appuntamento per il " + dateController.text + (serviziController.text.length > 2 ? "\nServizio: " + serviziController.text : "") + (prezzoController.text != '' ? "\nPrezzo: " + prezzoController.text + "€" : "")+ (number_saved != null ? "\nPer eventuali modifiche chiamare: 3888865279" : ''),subject: mailController.text);
                                currentClient = new Appuntamento(oldApp['key'], nameController.text, numberController.text,mailController.text,dateController.text,serviziController.text,prezzoController.text,int.parse(key.data));
                                bool esiste = false;
                                _contacts.forEach((element) { 
                                  if(element.displayName == nameController.text && flattenPhoneNumber(HelperFunctions.getValidPhoneNumber(element.phones)) == numberController.text) {
                                    esiste = true;
                                    return;
                                  }
                                });
                                if(esiste) {
                                  Navigator.of(context).pop();
                                } else {
                                  _onAlertButtonsPressed(context);
                                }
                              }
                            }, 
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: SizedBox( 
                      height:80, //height of button
                      width:150, //width of button
                      child:ElevatedButton.icon(
                        icon: Icon(Icons.exit_to_app_rounded),
                        label: Text("EXIT"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.redAccent, //background color of button
                            elevation: 3, //elevation of button
                            shape: RoundedRectangleBorder( //to set border radius to button
                                borderRadius: BorderRadius.circular(100)
                            ),
                            padding: EdgeInsets.all(20) //content padding inside button
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        }, 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
      .catchError((onError) {
      Fluttertoast.showToast(
        msg: "Messaggio non inviato",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
      );
    });
    Fluttertoast.showToast(
      msg: "Messaggio inviato",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.greenAccent,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }
}

// Alert with multiple and custom buttons
_onAlertButtonsPressed(context) {
  Alert(
    closeFunction: () {
      Navigator.pop(context);
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
    title: "Nuovo Contatto",
    desc: "vuoi aggiungerlo ai contatti?",
    buttons: [
      DialogButton(
        radius: BorderRadius.circular(100),
        child: Text(
          "SI",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () {
          ContactsService.addContact(Contact(givenName: currentClient.client,androidAccountName: currentClient.client, displayName: currentClient.client,phones:[Item(label: currentClient.phoneNumber, value: currentClient.phoneNumber)],emails:[Item(label: currentClient.email, value: currentClient.email)]));
          Fluttertoast.showToast(
            msg: "Contatto creato",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.greenAccent,
            textColor: Colors.white,
            fontSize: 16.0
          );
          Navigator.pop(context);
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
          Navigator.pop(context);
        },
        color: Colors.redAccent,
      )
    ],
  ).show();
}

