//@dart=2.9
import 'package:flutter/material.dart';
import 'package:agenda/main.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

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
                  "Informazioni",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "manuale d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                ListTile(
                  leading: Icon(Icons.perm_device_information_outlined,color: mainColor,),
                  title: Text(
                    'Permessi',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: mainColor,),),
                      style: ElevatedButton.styleFrom(
                        primary: mainColor.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PermessiPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.contacts_sharp,color: mainColor,),
                  title: Text(
                    'Clienti',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: mainColor,),),
                      style: ElevatedButton.styleFrom(
                        primary: mainColor.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ClientiPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.settings,color: mainColor,),
                  title: Text(
                    'Impostazioni',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: mainColor,),),
                      style: ElevatedButton.styleFrom(
                        primary: mainColor.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ImpostPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.add,color: mainColor,),
                  title: Text(
                    'New',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: mainColor,),),
                      style: ElevatedButton.styleFrom(
                        primary: mainColor.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.home,color: Colors.red,),
                  title: Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: Colors.red,),),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.calendar_today,color: Colors.green,),
                  title: Text(
                    'Calendario',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: Colors.green,),),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarioPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ListTile(
                  leading: Icon(Icons.account_circle_outlined,color: Colors.blue,),
                  title: Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: Colors.blue,),),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountInfoPage()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } 
}

class PermessiPage extends StatefulWidget {
  @override
  _PermessiPageState createState() => _PermessiPageState();
}

class _PermessiPageState extends State<PermessiPage> {

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
                  "Permessi",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "motivi dei permessi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 

                Text(
                  "CALENDARIO",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\nL'app richiede il permesso di accedere al calendario per potere aggiungere/modificare/eliminare gli appuntamenti creati, inoltre, nelle impostazioni è possibile scegliere il calendario dove salvare gli appuntamenti.\nATTENZIONE: L'app non leggerà e modificherà in alcun modo gli altri appuntamenti esistenti.\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "CONTATTI",
                  style: TextStyle(
                    fontSize: 20,
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\nL'app richiede il permesso di accedere ai contatti per poter selezionare i contatti quando si sta creando un nuovo appuntamento, inoltre, l'app potrà aggiungere contatti alla rubrica, sempre chiedendo il permesso all'utente.\nATTENZIONE: L'app non leggerà e userà in alcun modo le informazioni dei contatti.\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClientiPage extends StatefulWidget {
  @override
  _ClientiPageState createState() => _ClientiPageState();
}

class _ClientiPageState extends State<ClientiPage> {

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
                  "Clienti",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "manuale d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Row(
                  children: [
                    Image.asset('assets/images/client.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/client1.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ),
                Row(
                  children: [
                    Image.asset('assets/images/client2.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/client4.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ),
                SizedBox(height: 30,), 
                Text(
                  "La pagina clienti, come si vede in figura, è divisa in tre parti:\n1. Nella prima parte c'è il box Search per cercare fra i clienti salvati soprattutto quando sono tanti." +
                  "\n2. Nella seconda parte c'è l'elenco dei clienti scrorrevole(scrollable), facendo uno swipe a destra sui box avremo due alternative come in figura: eliminare il cliente cliccando sul cestino o modificare il cliente cliccando sulla matita(quarta immagine).\n" +
                  "Inoltre cliccando sul box apparirà un pop-up (terza immagine) con un riassunto delle informazioni, con i pulsanti precedenti e , in più, un pulsante verde per chiudere il pop-up senza modificare i dati.\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30,),
                Text(
                  "3. Nella terza parte c'è il pulsante New, che ci permette di creare nuovi clienti, i campi obbligatori sono quelli del nome e del numero di telefono,gli altri sono opzionali. Una volta compilati i campi d'interesse basta cliccare su ADD per creare il cliente.\nIMPORTANTE: quando si crea un nuovo appuntamento se si usa un contatto esistente verranno riempiti automaticamente tutti i campi compilati nella pagina cliente.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30,),
                Image.asset('assets/images/client3.jpg'), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImpostPage extends StatefulWidget {
  @override
  _ImpostPageState createState() => _ImpostPageState();
}

class _ImpostPageState extends State<ImpostPage> {

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
                  "manuale d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Image.asset('assets/images/setting.jpg',), 
                SizedBox(height: 30,), 
                Text(
                  "Come si vede in figura nelle impostazioni ci sono 5 scelte possibili:\n" +
                  "1. TEMMA SCURO: abilitando il tema scuro, l' applicazione si adeguerà automaticamente al tema corrente del telefono, disabilitandolo invece l' applicazione rimarrà sempre in modalità chiara.\n" +
                  "2. seleziona calendario: cliccandoci sopra verranno mostrati tutti i calendari disponibili, si può scegliere in quale calendario salvare gli appuntamenti.\n" +
                  "3. Durata Appuntamento: cliccandoci sopra verranno mostrate delle scelte predefinite (Standard: 1h), si può scegliere la durata media di un appuntamento.\n" +
                  "4. Promemoria: cliccandoci sopra verranno mostrate delle scelte predefinite (Standard: Nessun Promemoria), si può scegliere quanto prima verrà ricordato un appuntamento.\n" +
                  "5. Numero di telefono da contattare quando crei/modifichi un appuntamento.\n" +
                  "6. Database: cliccando su Download l'applicazione genererà un riepilogo di tutti gli appuntamenti creati dall' installazione sotto forma di file di testo.\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {

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
                  "New",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "esempio d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Row(
                  children: [
                    Image.asset('assets/images/new.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/new1.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ), 
                SizedBox(height: 30,), 
                Text(
                  "Cliccando su new(prima immagine) verrà mostrata la pagina dove creare il nostro appuntamento(seconda immagine). I campi obbligatori da riempire sono nome, numero di telefono e data, gli altri campi sono opzionali. Una volta riempiti i campi d'interesse abbiamo tre scelte:\n"
                  + "1. EXIT: usciamo dalla pagina senza creare nessun appuntamento.\n" +
                  "2. INVIA: crea l'appuntamento e manda un messaggio di conferma al cliente.\n" + 
                  "3. SHARE: crea l'appuntamento e possiamo scegliere l'applicazione dove mandare la conferma: WhatsApp,Gmail...\n" +
                  "Nei casi 2. e 3. inoltre verrà creato un appuntamento sul calendario, e se il contatto è nuovo verrà mostrato un pop-up in cui possiamo scegliere di aggiungerlo alla rubrica.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
                  "Home",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "modalità d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: mainColor.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Row(
                  children: [
                    Image.asset('assets/images/home.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/home1.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ),
                Row(
                  children: [
                    Image.asset('assets/images/home2.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/home3.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ), 
                SizedBox(height: 30,),
                Text(
                  "La pagina Home, come si vede in figura, è divisa in tre parti:\n1. Nella prima parte c'è il box con la data odierna, se si vuole vedere un altro giorno basta cliccarci sopra e scegliere dal calendario un nuovo giorno(figura 3)." +
                  "\n2. Nella seconda parte c'è l'elenco degli appuntamenti scrorrevole(scrollable) in ordine cronologico, facendo uno swipe a destra sui box avremo due alternative come in figura 2: eliminare l'appuntamento cliccando sul cestino o modificare il cliente cliccando sulla matita.\n" +
                  "Inoltre cliccando sul box apparirà un pop-up (quarta immagine) con un riassunto delle informazioni, con i pulsanti precedenti e , in più, un pulsante verde per chiudere il pop-up senza modificare i dati.\n3. :\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.add,color: mainColor,),
                  title: Text(
                    'New',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: mainColor,),),
                      style: ElevatedButton.styleFrom(
                        primary: mainColor.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarioPage extends StatefulWidget {
  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {

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
                  "Calendario",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "modalità d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Row(
                  children: [
                    Image.asset('assets/images/calendar.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/calendar1.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ),
                Row(
                  children: [
                    Image.asset('assets/images/calendar2.jpg',width: MediaQuery.of(context).size.width/2.3,),
                    Image.asset('assets/images/calendar3.jpg',width: MediaQuery.of(context).size.width/2.3,),
                  ],
                ), 
                SizedBox(height: 30,),
                Text(
                  "La pagina Calendario, come si vede in figura, è divisa in tre parti:\n1. Nella prima parte c'è il calendario, che è possibile visualizzare per settimana o per mese cliccando sul bottone verde vicino alla data. Sotto ogni giorno c'è un riquadro con il numero di appuntamenti(almeno 1),cliccandoci sopra veranno mostrati tutti gli appuntamenti del giorno." +
                  "\n2. Sotto al pulsante annulla selezione verranno mostrati gli appuntamenti dei giorni selezionati.\n" +
                  "Inoltre cliccando sui box apparirà un pop-up (quarta immagine) con un riassunto delle informazioni.\n3. :\n",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.add,color: Colors.green,),
                  title: Text(
                    'New',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  trailing:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton(
                      child: Text("Click",style: TextStyle(color: Colors.green,),),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green.withOpacity(.4),
                        elevation: 0, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewPage()));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {

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
                  "Account",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "modalità d'uso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.withOpacity(.4),
                  ),
                ),
                SizedBox(height: 30,), 
                Image.asset('assets/images/account.jpg'), 
                SizedBox(height: 30,),
                Text(
                  "Nella pagina Account per il momento non è possibile eseguire nessuna azione,ma si possono vedere dei grafici riepilogativi degli appuntamenti mensili,appuntamenti giornalieri,i 10 clienti con più appuntamenti e i guadagni mensili.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
