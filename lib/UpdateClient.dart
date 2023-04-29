// @dart=2.9
import 'package:agenda/client.dart';
import 'package:agenda/helperFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:agenda/main.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UpdateClient extends StatefulWidget {
  Map<String, dynamic> oldApp;
  UpdateClient(this.oldApp);
  @override
  _UpdateClientState createState() => _UpdateClientState(oldApp);
}

class _UpdateClientState extends State<UpdateClient> {
  Map<String, dynamic> oldApp;
  Iterable<Contact> _contacts;
  TextEditingController numberController;
  TextEditingController nameController;
  TextEditingController serviziController;
  TextEditingController mailController;
  TextEditingController prezzoController;
  final _formKey = GlobalKey<FormState>();

  _UpdateClientState(this.oldApp);

  @override
  void initState() {
    numberController = new TextEditingController(text: oldApp['phoneNumber']);
    nameController = new TextEditingController(text: oldApp['client']);
    serviziController = new TextEditingController(text: oldApp['Servizio']);
    mailController = new TextEditingController(text: oldApp['email']);
    prezzoController = TextEditingController(text: oldApp['prezzo'].toString());
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
                    "modifica cliente",
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
                          fillColor: mainColor,
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
                            icon: Icon(Icons.person_outline_sharp),
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
                                current_client = new Client(oldApp['key'], nameController.text, numberController.text,mailController.text,serviziController.text,prezzoController.text);
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
                      ],
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
          ContactsService.addContact(Contact(givenName: current_client.client,androidAccountName: current_client.client, displayName: current_client.client,phones:[Item(label: current_client.phoneNumber, value: current_client.phoneNumber)],emails:[Item(label: current_client.email, value: current_client.email)])); 
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