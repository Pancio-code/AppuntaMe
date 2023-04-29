class Appuntamento {
  int key;
  String client;
  String phoneNumber;
  String email;
  String date;
  String servizio;
  String prezzo;
  int CalendarId;
  Appuntamento(this.key,this.client,this.phoneNumber,this.email,this.date,this.servizio,this.prezzo,this.CalendarId);
  
  int getKey() {return this.key;}
  String getClient() {return this.client;}
  String getPhoneNumber() {return this.phoneNumber;}
  String getDate() {return this.date;}
  String getMail() {return this.email;}
  String getPrezzo() {return this.prezzo;}
  String getServizio() {return this.servizio != '' ? this.servizio : 'Opzionale';}
  int getCalendarId() {return this.CalendarId;}

  void setKey(int key) {this.key = key;}
  void setClient(String client) {this.client = client;}
  void setPhoneNumber(String phoneNumber) {this.phoneNumber = phoneNumber;}
  void setDate(String date) {this.date = date;}
  void setMail(String email) {this.email = email;}
  void setServizio(String servizio) {this.servizio = servizio;}
  void setPrezzo(String prezzo) { this.prezzo = prezzo;}
  void setCalendarId(int id) {this.CalendarId = CalendarId;}


  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'client': client,
      'phoneNumber': phoneNumber,
      'email': email,
      'date': date,
      'servizio' : servizio,
      'prezzo' : prezzo,
      'calendar' : CalendarId,
    };
  }

  @override
  String toString() {
    String appuntamento = getKey().toString() + ";" + getClient() + ";" + getPhoneNumber() + ";" + getMail()+ ";" + getDate().toString() + ";" + getServizio() + ";"  + getPrezzo();
    return appuntamento;
  }
}

class Date implements Comparable{
  String month;
  String hour;
  String day;
  Date(this.day,this.month,this.hour);

  @override
  int compareTo(other) {
    if(this.month.compareTo(other.month) > 0) {
      return 1;
    }
    else if(this.month.compareTo(other.month) < 0) {
      return -1;
    }
    else {
      if(this.day.compareTo(other.day) > 0) {
        return 1;
      }
      else if(this.day.compareTo(other.day) < 0) {
        return -1;
      }
      else {
        if(this.hour.compareTo(other.hour) > 0) {
          return 1;
        }
        else if(this.hour.compareTo(other.hour) < 0) {
          return -1;
        }
        else {
          return 0;
        }         
      }      
    }
  }

  Date toDate(String date) {
    List<String> formtatted_date = date.split('/');
    Date newDate = Date(formtatted_date[0], formtatted_date[1], formtatted_date[2]);
    return newDate;
  }
  String toString() {
    String s = this.day + "/" + this.month + "/" + this.hour;
    return s;
  }
}