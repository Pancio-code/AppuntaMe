//@dart=2.9
import 'package:agenda/Clientes.dart';
import 'package:agenda/UpdateClient.dart';
import 'package:agenda/database_client.dart';
import 'package:flutter/material.dart';
import 'package:agenda/main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Client current_client;

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final dbClient = DatabaseClient.instance;
  List<Map<String, dynamic>> clienti;
  TextEditingController searchController = TextEditingController();
  Future<int> _future; 
  List<Widget> _cardList = [];
  int num;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    _future = getClientes();
    _createInterstitialAd();
    searchController.addListener(() {
      getClientes();
    });
    super.initState();
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
    BannerAd bAd = new BannerAd(size: AdSize.largeBanner, adUnitId: 'ca-app-pub-4105105189383277/9392805214' , listener: BannerAdListener(
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

  Future<int> getClientes() async {
    clienti = await dbClient.queryAllRows();
    _cardList = [];
    int num_of_client = clienti.length;
    setState(() {
      for(int i = 0; i < num_of_client;i++) {
       if((clienti[i]['client']).toLowerCase().contains(searchController.text.toLowerCase())) {
        _addCardWidget(clienti[i]);
        }
      }
    });
    num = _cardList.length;
    return num;
  }

  void _addCardWidget(Map<String, dynamic> client) {
    _cardList.add(_card(client));
  }

  Widget _card(Map<String, dynamic> client) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Slidable(
        direction: Axis.horizontal,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          height: 120,
          decoration: new BoxDecoration(
            color:  mainColor.withOpacity(.2),
            border: Border.all(
              color: mainColor,
            )
          ),
          child: Center(
            child: ListTile(
              onTap: () { 
                String description = "Nome: " + client['client'] + "\nNumero: " + (client['phoneNumber']).toString() + ((client['email']).toString() != '' ? "\nEmail: " + (client['email']).toString() : '') + (client['Servizio'].toString() != '' ? "\nServizio: " + (client['Servizio']).toString() : '') + (client['prezzo'].toString() != '' ? "\nPrezzo: " + (client['prezzo']).toString() + '€' : '');
                _onClientPressed(context,client,description);
              },
              title: Text(
                client['client'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainColor),
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
              _onDeletePressed(context, client);
            },
          ),
          IconSlideAction(
            caption: 'Modifica',
            color: Colors.blue,
            icon: Icons.create_rounded,
            onTap: () async {
              var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateClient(client)));
              if(res == null || res == true) {
                if(current_client != null) {
                  await dbClient.update({
                    'key': current_client.key,
                    'client': current_client.client.toLowerCase(),
                    'phoneNumber' : current_client.phoneNumber,
                    'email' : current_client.email,
                    'Servizio' : current_client.servizio,
                    'prezzo' : current_client.prezzo,
                  });
                  getClientes();
                  if(res == null || res == true) {
                    current_client = null;
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
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
                  physics: ScrollPhysics(),
                  child: Container(
                    height : num * 100.0 + 800,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Contatti",
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "gestisci i clienti",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: mainColor.withOpacity(.4),
                          ),
                        ),
                        SizedBox(height: 50,),
                        Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.fromSwatch(
                                primarySwatch: mainColor,
                              ),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: mainColor
                                  )
                                ),
                                prefixIcon: Icon(
                                  Icons.search_sharp,
                                  color: mainColor,
                                )
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Container(
                          child: AdWidget(
                            ad: getBannerAd()..load(),
                            key: UniqueKey(),
                          ),
                          height: 120,
                        ),
                        SizedBox(height: 30,),
                        Expanded(
                          child: num > 0 ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: num,
                            itemBuilder: (context, index) {
                              return _cardList[index];
                            },
                          ) : Text(
                            "Nessun cliente\nclicca su New",
                            textAlign: TextAlign.center,
                            style: TextStyle(  
                              fontWeight: FontWeight.bold,
                              color: mainColor, 
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: mainColor.withOpacity(.2),
              onPressed: () async {
                current_client = null;
                final PermissionStatus permissionContact = await Permission.contacts.request();
                if (permissionContact == PermissionStatus.granted) {
                  var nav = await Navigator.push(context, MaterialPageRoute(builder: (context) => ClientesPage()));
                  if(nav == null || nav == true) {
                    if (_interstitialAd != null) _showInterstitialAd();
                    if(current_client != null) {
                      var res = await dbClient.insert(current_client.toMap());
                      getClientes();
                      if(res == null || res == true) {
                        current_client = null;
                      }
                    }
                  }
                }
              },
              icon: Icon(Icons.contact_page_sharp,color: mainColor,),
              label: Text(
                'New',
                style: TextStyle(
                  color: mainColor,
                ),
              )
            ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 10,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          );
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      }
    );
  }

  _onClientPressed(context,app,description) {
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
      title: "Cliente",
      desc: description, 
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
            var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateClient(app)));
            if(res == null || res == true) {
              if(current_client != null) {
                var res = await dbClient.update(current_client.toMap());
                getClientes();
                if(res == null || res == true) {
                  current_client = null;
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
            await dbClient.delete(app['key']);
            getClientes();
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

class Client {
  int key;
  String client;
  String phoneNumber;
  String email;
  String servizio;
  String prezzo;

  Client(this.key,this.client,this.phoneNumber,this.email,this.servizio,this.prezzo);
  
  int getKey() {return this.key;}
  String getClient() {return this.client;}
  String getPhoneNumber() {return this.phoneNumber;}
  String getMail() {return this.email;}
  String getPrezzo() {return this.prezzo;}
  String getServizio() {return this.servizio != '' ? this.servizio : 'Opzionale';}

  void setKey(int key) {this.key = key;}
  void setClient(String client) {this.client = client;}
  void setPhoneNumber(String phoneNumber) {this.phoneNumber = phoneNumber;}
  void setMail(String email) {this.email = email;}
  void setServizio(String servizio) {this.servizio = servizio;}
  void setPrezzo(String prezzo) { this.prezzo = prezzo;}


  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'client': client,
      'phoneNumber': phoneNumber,
      'email': email,
      'Servizio' : servizio,
      'prezzo' : prezzo,
    };
  }

  @override
  String toString() {
    String appuntamento = getKey().toString() + ";" + getClient() + ";" + getPhoneNumber() + ";" + getMail() + ";" + getServizio() + ";" + getPrezzo();
    return appuntamento;
  }
}