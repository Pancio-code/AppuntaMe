// @dart=2.9
import 'dart:collection';
import 'dart:ui';
import 'package:agenda/Account.dart';
import 'package:agenda/Theme.dart';
import 'package:agenda/Update.dart';
import 'package:agenda/client.dart';
import 'package:agenda/database_client.dart';
import 'package:agenda/setting.dart';
import 'package:device_calendar/device_calendar.dart' as device;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Appuntamenti.dart';
import 'Appuntamento.dart';
import 'Calendar.dart';
import 'database_account.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'Table.dart';
import 'info.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


Map<String,dynamic> num_of_appointment;
List<Map<String, dynamic>> list_of_appointment;
List<Map<String, dynamic>> list_of_client;
Color mainColor = Colors.red;
Appuntamento currentClient = null;
int num = 0;
int num_of_day = 0;
var days = ['Lunedì','Martedì','Mercoledì','Giovedì','Venerdì','Sabato','Domenica'];
var date = new DateTime.now();
var selected_date = DateTime.parse(date.toString());
var formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
var weekDay = days[selected_date.weekday -1];
device.Calendar selectedCalendar;

//Per delet_past and queryAllRowsofDay(now)
var now = formattedDate + " - " + "${selected_date.hour <= 9 ? '0' + selected_date.hour.toString() : selected_date.hour}" + ":" + "${selected_date.minute<= 9 ? '0' + selected_date.minute.toString() : selected_date.minute}";
var start = formattedDate + " - " + "${selected_date.hour <= 9 ? '0' + selected_date.hour.toString() : selected_date.hour}" + ":" + "${selected_date.minute <= 9 ? '0' + selected_date.minute.toString() : selected_date.minute}";
var end = formattedDate + " - " + "24" + ":" + "00";


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create:(context) => ThemeProvider(),
    builder: (context, _) {
      final themeProvider = Provider.of<ThemeProvider>(context);

      return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('it')
        ],
        debugShowCheckedModeBanner: false,
        title: 'MyAgenda',
        themeMode: themeProvider.darkTheme ? ThemeMode.system : ThemeMode.light,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: MyHomePage(),
      );
    }
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool firstTime = true;
  List<Slide> listSlides = [];
  int _selectedIndex = 0;
  final dbHelper = DatabaseHelper.instance;
  final dbAccount = DatabaseAccount.instance;
  final dbClient = DatabaseClient.instance;
  List<Map<String, dynamic>> appuntamenti;
  List<Map<String, dynamic>> appuntamenti_of_day;
  List<Widget> _cardList = [];
  Future<int> _future;
  InterstitialAd _interstitialAd;

  device.DeviceCalendarPlugin _deviceCalendarPlugin = new device.DeviceCalendarPlugin();
  List<device.Calendar> _calendars;

  static List<Widget> _pages; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      mainColor = pageColor();
    });
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

  @override
  void initState() { 
    super.initState();
    _retrieveCalendars();
    _createInterstitialAd();
    _future = getDatabase();
  }

  onPressedDone() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial',false);
    getDatabase();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4105105189383277/8540277605",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _createInterstitialAd();
        },
      )
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd.dispose();
  }

  static BannerAd getBannerAd(){
     BannerAd bAd = new BannerAd(size: AdSize.largeBanner, adUnitId: 'ca-app-pub-4105105189383277/9392805214', listener: BannerAdListener(
        onAdClosed: (Ad ad){
          print("Ad Closed");
        },
        onAdFailedToLoad: (Ad ad,LoadAdError error){
          ad.dispose();
        },
        onAdLoaded: (Ad ad){
          print('Ad Loaded');
        },
        onAdOpened: (Ad ad){
          print('Ad opened');
        }
    ), request: AdRequest());
    return bAd;
  }


  void _retrieveCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.get('calendar');
    setState(() {
      _calendars = calendarsResult?.data;
      selectedCalendar = getCalendarById(id) ?? _calendars[0];
    });
  }

  device.Calendar getCalendarById(String id) {
    if(id == null) return null;
    for(device.Calendar item in _calendars) {
      if(item.id == id) return item;
    }
    return null;
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
    dataClient.sort((a,b) => a.compareTo(b));
    while(dataClient.length > 10) {
      dataClient.removeLast();
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

  void _addCardWidget(Map<String, dynamic> app) {
    _cardList.add(_card(app));
  }

  Widget _card(Map<String, dynamic> app) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Slidable(
        direction: Axis.horizontal,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          height: 120,
          decoration: new BoxDecoration(
            color:  Colors.red.withOpacity(.2),
            border: Border.all(
              color: Colors.red,
            )
          ),
          child: Center(
            child: ListTile(
              onTap: () => _onAppointmentPressed(context,app),
              title: Text(
                app['client'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                app['date'].split('/')[2].split('- ')[1],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),      
            ),
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async { 
              _onDeletePressed(context, app);
            },
          ),
          IconSlideAction(
            caption: 'Modifica',
            color: Colors.blue,
            icon: Icons.create_rounded,
            onTap: () async {
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
          ),
        ],
      ),
    );
  }

  Future<int> getDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firstTime = prefs.getBool('tutorial') ?? true;
    num = await dbHelper.queryRowCount();
    num_tot = await dbAccount.queryRowCount();
    appuntamenti = await dbHelper.queryAllRows();
    appuntamenti_of_day = cloneAppuntamenti((await dbHelper.queryAllRowsOfDay(start, end)));
    list_of_appointment = appuntamenti;
    list_of_client = await dbClient.queryAllRows();
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

  List<Widget> getHome() {
    _pages =  <Widget>[
      num != 0  ? ListView.builder( 
        itemCount: num_of_day + 1,
        itemBuilder: (context,index){
          if(index == 0) {
            if(num_of_day != 0) {
              return Column(
                children: [
                  Center(
                    child: Container(
                      child: Text(
                        'Appuntamenti',
                        style: TextStyle(
                          fontSize: 30,
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity > 0) {
                          if(selected_date.isAfter(DateTime.parse(date.toString()))) {
                            selected_date = selected_date.subtract(Duration(days: 1));
                            formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                            start = formattedDate + " - " + "${selected_date.hour <= 9 ? '0' + selected_date.hour.toString() : selected_date.hour}" + ":" + "${selected_date.minute <= 9 ? '0' + selected_date.minute.toString() : selected_date.minute}";
                            end = formattedDate + " - " + "24" + ":" + "00";
                            weekDay = days[selected_date.weekday -1];
                            getDatabase();
                          } else {
                            null;
                          }
                        } else if (details.primaryVelocity < 0) {
                          selected_date = selected_date.add(Duration(days: 1));
                          formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                          start = formattedDate + " - "+ "00" + ":" + "00";
                          end = formattedDate + " - " + "24" + ":" + "00";
                          weekDay = days[selected_date.weekday -1];
                          getDatabase();
                        };               
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 25),
                        child: ElevatedButton(
                          onPressed: () async {
                            final date_now = await showDatePicker(
                              locale: const Locale("it","IT"),
                              context: context,
                              firstDate: DateTime(date.year,date.month,date.day),
                              initialDate: DateTime.now(),
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
                            if(date_now != null) {
                              var dateParse_selected = DateTime.parse(date_now.toString());
                              selected_date = dateParse_selected;
                              formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                              start = formattedDate + " - "+ "00" + ":" + "00";
                              end = formattedDate + " - " + "24" + ":" + "00";
                              weekDay = days[selected_date.weekday -1];
                              getDatabase();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            weekDay + '\n' + formattedDate,
                            style: TextStyle(
                              fontSize: 30,
                              color: mainColor.withOpacity(.5),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],      
              );
            } else {
              return Center(
                child:Column(
                  children: [
                    Container(
                      child: Text(
                        'Appuntamenti ',
                        style: TextStyle(
                          fontSize: 30,
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) async {
                        if (details.primaryVelocity > 0) {
                          if(selected_date.isAfter(DateTime.parse(date.toString()))) {
                            selected_date = selected_date.subtract(Duration(days: 1));
                            formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                            start = formattedDate + " - "+ "00" + ":" + "00";
                            end = formattedDate + " - " + "24" + ":" + "00";
                            weekDay = days[selected_date.weekday -1];
                            getDatabase();
                          } else {
                            null;
                          }
                        } else if (details.primaryVelocity < 0) {
                          selected_date = selected_date.add(Duration(days: 1));
                          formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                              start = formattedDate + " - "+ "00" + ":" + "00";
                              end = formattedDate + " - " + "24" + ":" + "00";
                          weekDay = days[selected_date.weekday -1];
                          getDatabase();
                        };                    
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 25),
                        child: ElevatedButton(
                          onPressed: () async {
                            final date_now = await showDatePicker(
                              locale: const Locale("it","IT"),
                              context: context,
                              firstDate: DateTime(date.year,date.month,date.day),
                              initialDate: DateTime.now(),
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
                            if(date_now != null) {
                              var dateParse_selected = DateTime.parse(date_now.toString());
                              selected_date = dateParse_selected;
                              formattedDate = "${selected_date.day <= 9 ? '0' + selected_date.day.toString() : selected_date.day}/${selected_date.month <= 9 ? '0' + selected_date.month.toString() : selected_date.month.toString() }/${selected_date.year}";
                              start = formattedDate + " - " + "${selected_date.hour <= 9 ? '0' + selected_date.hour.toString() : selected_date.hour}" + ":" + "${selected_date.minute <= 9 ? '0' + selected_date.minute.toString() : selected_date.minute}";
                              end = formattedDate + " - " + "24" + ":" + "00";
                              weekDay = days[selected_date.weekday -1];
                              getDatabase();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            weekDay + '\n' + formattedDate,
                            style: TextStyle(
                              fontSize: 30,
                              color: mainColor.withOpacity(.5),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50,),
                    Container(
                      child: AdWidget(
                        ad: getBannerAd()..load(),
                        key: UniqueKey(),
                      ),
                      height: 120,
                    ),
                    SizedBox(height: 50,),
                    Container(
                      child: Text(
                        'Nessun\nAppuntamento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              );              
            }
          }
          return _cardList[index- 1];
        }
      ) : (MediaQuery.of(context).size.height > 800 || MediaQuery.of(context).orientation == Orientation.portrait ?
      Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Container(
              child: AdWidget(
                ad: getBannerAd()..load(),
                key: UniqueKey(),
              ),
              height: 120,
            ),
            SizedBox(height: 50,),
            Container(
              child: Text(
                'Nessun\nAppuntamento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ]
        )
      ) : Center(child: 
        Container(
          child: Text(
            'Nessun\nAppuntamento',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),)
      ),
      Center(child: Calendar()),
      Account(),
    ];
    return _pages;
  }

  Color pageColor() {
    if(_selectedIndex == 0) return Colors.red;
    else if(_selectedIndex == 1) return Colors.green;
    else return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(horizontal: width/20, vertical: 12);
    double gap = 10;
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          listSlides = [];
          listSlides.add(Slide(
            title: "HOME",
            pathImage: "assets/images/tutorial.jpg",
            widthImage: width > 1080 ? 1080 : width,
            heightImage: height > 2326 ? 2326 : height,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Color.fromRGBO(237, 126, 50,1),
          ));
          listSlides.add(Slide(
            title: "NEW",
            pathImage: "assets/images/tutorial1.jpg",
            widthImage: width > 1080 ? 1080 : width,
            heightImage: height > 2326 ? 2326 : height,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Color.fromRGBO(247, 102, 52,1),
          ));
          listSlides.add(Slide(
            title: "APPUNTAMENTO",
            pathImage: "assets/images/tutorial2.jpg",
            widthImage: width > 1080 ? 1080 : width,
            heightImage: height > 2326 ? 2326 : height,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Color.fromRGBO(224, 78, 58,1),
          ));
          listSlides.add(Slide(
            title: "CONTATTI",
            pathImage: "assets/images/tutorial3.jpg",
            widthImage: width > 1080 ? 1080 : width,
            heightImage: height > 2326 ? 2326 : height,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Color.fromRGBO(247, 42, 69,1),
          ));
          listSlides.add(Slide(
            title: "CALENDARIO",
            pathImage: "assets/images/tutorial4.jpg",
            widthImage: width > 1080 ? 1080 : width,
            heightImage: height > 2326 ? 2326 : height,
            foregroundImageFit: BoxFit.contain,
            backgroundColor: Color.fromRGBO(237, 50, 157,1),
          ));
          return ! firstTime ? Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                   IconButton(
                    onPressed: () async {
                      var nav = await Navigator.push(context, MaterialPageRoute(builder: (context) => ClientPage()));
                      if(nav == null || nav == true) 
                        getDatabase();
                    },
                    icon: Icon(Icons.contacts_sharp,),
                    alignment: Alignment.topRight,
                    iconSize: 40,
                    color: mainColor.withOpacity(.5),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InfoPage()));
                    },
                    icon: Icon(Icons.info_sharp,),
                    alignment: Alignment.topRight,
                    iconSize: 40,
                    color: mainColor.withOpacity(.5),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingPage()));
                    },
                    icon: Icon(Icons.settings),
                    alignment: Alignment.topRight,
                    iconSize: 40,
                    color: mainColor.withOpacity(.5),
                  ),
                ],
              ),
              body: Padding(
                padding: EdgeInsets.all(25),
                child: getHome().elementAt(_selectedIndex),       
              ),
              floatingActionButton: _selectedIndex != 2 ? FloatingActionButton.extended(
                elevation: 0,
                backgroundColor: pageColor().withOpacity(.2),
                onPressed: () async {
                  currentClient = null;
                  final PermissionStatus permissionContact = await Permission.contacts.request();
                  final PermissionStatus permissionCalendar = await Permission.calendar.request();
                  if (permissionContact == PermissionStatus.granted && permissionCalendar == PermissionStatus.granted) {
                    var nav = await Navigator.push(context, MaterialPageRoute(builder: (context) => AppuntamentiPage()));
                    if(nav == null || nav == true) {
                      if (_interstitialAd != null) _showInterstitialAd();
                      if(currentClient != null) {
                        var res = await dbHelper.insert(currentClient.toMap());
                        List<String> data_current = currentClient.date.split('/');
                        int month = data_current[1][0] == 0 ? data_current[1][1] : int.parse(data_current[1]);
                        int year = int.parse(data_current[2][0] + data_current[2][1] + data_current[2][2] + data_current[2][3]);
                        await dbAccount.insert({
                          'key': currentClient.key,
                          'client': currentClient.client.toLowerCase().trim(),
                          'day': DateTime.parse(year.toString() + "-" + data_current[1].toString() + "-" + data_current[0]).weekday,
                          'month': month,
                          'year' : year,
                          'prezzo' : currentClient.prezzo,
                        });
                        getDatabase();
                        if(res == null || res == true) {
                          currentClient = null;
                        } 
                        _interstitialAd?.dispose();
                      }
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          'PERMESSO NEGATO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mainColor
                          ),
                          ),
                        content: Text('Per favore dare accesso ai contatti e calendario '
                                      'nell\' impostazioni di sistema'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('OK',),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                    );
                  }
                },
                icon: Icon(Icons.add,color: pageColor(),),
                label: Text(
                  'New',
                  style: TextStyle(
                    color: pageColor(),
                  ),
                )
              ) : null,
              bottomNavigationBar: SafeArea(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomAppBarColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: -10,
                        blurRadius: 60,
                        color: Colors.black.withOpacity(.4),
                        offset: Offset(0, 25),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                    child: GNav(
                      tabs: [
                        GButton(
                          gap: gap,
                          iconActiveColor: Colors.red,
                          iconColor: Colors.black,
                          textColor: Colors.red,
                          backgroundColor: Colors.red.withOpacity(.2),
                          iconSize: 24,
                          padding: padding,
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          gap: gap,
                          iconActiveColor: Colors.green,
                          iconColor: Colors.black,
                          textColor: Colors.green,
                          backgroundColor: Colors.green.withOpacity(.2),
                          iconSize: 24,
                          padding: padding,
                          icon: Icons.calendar_today,
                          text: 'Calendario',
                        ),
                        GButton(
                          gap: gap,
                          iconActiveColor: Colors.blue,
                          iconColor: Colors.black,
                          textColor: Colors.blue,
                          backgroundColor: Colors.blue.withOpacity(.2),
                          iconSize: 24,
                          padding: padding,
                          icon: Icons.account_circle_outlined,
                          text: 'Account',
                        ),
                      ],
                      onTabChange: _onItemTapped,
                    ),
                  ),
                ),
              ),     
          ) : Scaffold(body: Center(child:IntroSlider(
                slides: listSlides,
                onSkipPress: onPressedDone,
                onDonePress: onPressedDone,
              )
            )
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: mainColor,) ));
        }
      } 
    );
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

