// @dart=2.9
import 'package:agenda/main.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'database_account.dart';

List<String> months = ['Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno','Luglio','Agosto','Settembre','Ottobre','Novembre','Dicembre'];
List<NumberData> dataMonth = [];
List<NumberData> dataDay = [];
List<NumberData> dataClient = [];
List<NumberData> dataPrice = [];
int num_tot = 0;

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {  
  final dbAccount = DatabaseAccount.instance;

  _getMonthData() {
   List<charts.Series<NumberData, String>> series = [
      charts.Series(
        id: "Mesi",
        data: dataMonth,
        domainFn: (NumberData series, _) => series.date.toString(),
        measureFn: (NumberData series, _) => series.number,
      ),
    ];
    return series;
  }

  _getDayData() {
   List<charts.Series<NumberData, String>> series = [
      charts.Series(
        id: "Giorni",
        data: dataDay,
        domainFn: (NumberData series, _) => series.date.toString(),
        measureFn: (NumberData series, _) => series.number,
      ),
    ];
    return series;
  }

  _getClientData() {
   List<charts.Series<NumberData, String>> series = [
      charts.Series(
        id: "Clienti",
        data: dataClient,
        domainFn: (NumberData series, _) => series.date.toString(),
        measureFn: (NumberData series, _) => series.number,
      ),
    ];
    return series;
  }

  _getMonthPrice() {
   List<charts.Series<NumberData, String>> series = [
      charts.Series(
        id: "Guadagni",
        data: dataPrice,
        domainFn: (NumberData series, _) => series.date.toString(),
        measureFn: (NumberData series, _) => series.number,
      ),
    ];
    return series;
  }
  
  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Container(
        height:1500, //try to sum the height of the other widgets
        child: Column(
          children: [
            Text(
              "Account",
              style: TextStyle(
                color: mainColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "statistiche e data",
              style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: mainColor.withOpacity(.4),
              ),
            ),
            SizedBox(height: 30,),  
            Text(
              "Appuntamenti totali: " + num_tot.toString(),
              style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: mainColor,
              ),
            ),
            Text(
              "Clienti salvati: " + list_of_client.length.toString(),
              style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: mainColor.withOpacity(.4),
              ),
            ),
            SizedBox(height: 30,), 
            Expanded(
              child: charts.BarChart(
                _getMonthData(), 
                animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 60,
                    labelStyle: new charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    lineStyle: new charts.LineStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                  ),
                ),
                behaviors: [
                  new charts.ChartTitle('Appuntamenti Mensili',
                    titleStyleSpec: charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    innerPadding: 25,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,), 
            Expanded(
              child: charts.BarChart(
                _getDayData(), 
                animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 60,
                    labelStyle: new charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    lineStyle: new charts.LineStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                  ),
                ),
                behaviors: [
                  new charts.ChartTitle('Appuntamenti Settimanali',
                    titleStyleSpec: charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    innerPadding: 25,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,), 
            Expanded(
              child: charts.BarChart(
                _getClientData(), 
                animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 60,
                    labelStyle: new charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    lineStyle: new charts.LineStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                  ),
                ),
                behaviors: [
                  new charts.ChartTitle('Clienti Abitudinari',
                    titleStyleSpec: charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    innerPadding: 25,
                  ),
                ],
              ),
            ),
            Expanded(
              child: charts.BarChart(
                _getMonthPrice(), 
                animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 60,
                    labelStyle: new charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    lineStyle: new charts.LineStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                  ),
                ),
                behaviors: [
                  new charts.ChartTitle('Guadagni Mensili: ',
                    titleStyleSpec: charts.TextStyleSpec(
                      color: charts.MaterialPalette.blue.shadeDefault.darker,
                    ),
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    innerPadding: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppuntamentiData {
  String client;
  int year;
  int month;
  int day;
  double prezzo;
  AppuntamentiData({
    @required this.client,
    @required this.day, 
    @required this.month,
    @required this.year,
    @required this.prezzo,
  });
}

class NumberData {
  String date;
  int number;
  NumberData({
    @required this.date,
    @required this.number,
  });

  int compareTo(other) {
    if(this.number.compareTo(other.number) > 0) {
      return 1;
    }
    else if(this.number.compareTo(other.number) < 0) {
      return -1;
    }
    else {
     return 0;
    }
  }
}