// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:telephony/telephony.dart';
import './profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shake/shake.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
enum CustomMessage {vehicle,company,time,followingMe,callMe,area,pretending,other}

// ignore: must_be_immutable
class DashBoard extends StatefulWidget {
  LatLng currenPosition;
  DashBoard(this.currenPosition);
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
CustomMessage message ;
  AudioCache _audioCache;
  final player = AudioCache();
  int index = 0;
  var currentUser = FirebaseAuth.instance.currentUser;
  var address;
   getCurrentAddress() async{
    final coordinates = new Coordinates(widget.currenPosition.latitude, widget.currenPosition.longitude);
    print(coordinates);
    var results  = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print("*${results}");
    var first = results.first;
    print('---');
    print(first);
    if(first!=null) {
      address = first.featureName;
      address =   " $address, ${first.subLocality}" ;
      address =  " $address, ${first.subLocality}" ;
      address =  " $address, ${first.locality}" ;
      address =  " $address, ${first.countryName}" ;
      address = " $address, ${first.postalCode}" ;
      print('inside if');
      print(address);
      return address;
    }
  }

  void _makingPhoneCall() async {
    print('In phone call');
      var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    List contacts = userData['saved_contacts'];
     print("data fetched");
    Telephony telephony = Telephony.instance;
    bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    //address = getCurrentAddress();


    final coordinates = new Coordinates(widget.currenPosition.latitude, widget.currenPosition.longitude);
    print(coordinates);
    var results  = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print("*${results}");
    var first = results.first;
    print('---');
    print(first);
    if(first!=null) {
      address = first.featureName;
      address =   " $address, ${first.subLocality}" ;
      //address =  " $address, ${first.subLocality}" ;
      address =  " $address, ${first.locality}" ;
      address =  " $address, ${first.countryName}" ;
      address = " $address, ${first.postalCode}" ;
      print('inside if');
      print(address);
    }


    print('got address');
    print(address);
    for(int i=0;i<contacts.length;i++)
    {
      var mes = 'SOS!!! ' + currentUser.displayName +' is in danger! Currently at'+address+'.';
      await telephony.sendSms(
          to: contacts[i],
          message: mes
      );
    }
    print(address);
    print('sms');
    if(contacts.length==0)
      await telephony.dialPhoneNumber("100");
    else
      await telephony.dialPhoneNumber(contacts[0]);
    print("call done");
    // const url = 'tel:9920283682';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
  void _sendCustomMessage(String message,String inp)async{
    var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    List contacts = userData['saved_contacts'];
     print("data fetched");
    Telephony telephony = Telephony.instance;
    bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    getCurrentAddress();
    print(address);
    for(int i=0;i<contacts.length;i++)
    {
      var mes = message+inp;
      await telephony.sendSms(
          to: contacts[i],
          message: mes
      );
    }
  }
  void detectingShake() async{
    print("DETECTING SHAKE");
 ShakeDetector detector;
    var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    var isSwitched = userData['is_switched'];
    if(isSwitched){
      ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: (){
        _makingPhoneCall(); 
    });
       detector.startListening();
    }else{
      print("STOPPED LISTENING");
      detector.stopListening();
    }
      // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }
  void initState(){
    super.initState();
    print("INIT CALLED");
    //getUserData();
    detectingShake();
    var audioCache = _audioCache = AudioCache(
      prefix: 'audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
     _savedLocations();
  }
  
var userData;
  Set<Marker> _markers = {};
  BitmapDescriptor mapMarker;
getUserData()async{
   userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
}
  void _savedLocations()async{
  Future.delayed(const Duration(milliseconds: 5000), () {

// Here you can write your code
  setState(() async{
     var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
     print("MARKERRRS no yay");
    List locations = userData['saved_locations'];
    print(locations);
    List latitudes =   userData['latitudes'];
    List longitudes = userData['longitudes'];
      for (int i = 0; i < locations.length; i++) {
        print("adding marker");
        _markers.add(
          Marker(
            markerId: MarkerId('id-${i+1}'),
            position: LatLng(double.parse(latitudes[i]), double.parse(longitudes[i])),
            // icon: mapMarker,
            infoWindow: InfoWindow(title: locations[i]),
          ),
        );
        print("marker addeed");
      }
  });

});
  
  
    
  }

getDialouge(String message,String hint)
{
  var inp;
     showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  elevation: 10,
                  title: Text(message,style: TextStyle(color:Colors.blue[800]),),
                  content: Container( 
                    child: TextFormField(
                      cursorColor: Colors.blue[800],
                      onChanged: (val){
                        inp=val;
                      },
                    decoration: InputDecoration(hintText: hint,border: InputBorder.none),
                    )
                    ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.send), 
                      iconSize: 30, 
                      color: Colors.blue[800],
                      onPressed: () {
                        _sendCustomMessage(message,inp);
                        Navigator.of(ctx).pop();
                      },)
                  ],
                ),
              );
}
  

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          
          toolbarHeight: 80,
          shape: ContinuousRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
          backgroundColor: Colors.blue[800],
          title: Text('Dashboard'),
          actions: [
            IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: Icon(Icons.record_voice_over),
              onPressed:()=> _audioCache.play('my_audio.mp3'),
              )
            // ignore: deprecated_member_use
            // FlatButton(
            //   //onPressed: _savedLocations,
            //   onPressed:()=> _audioCache.play('my_audio.mp3'),
            //   child: Text('SCREAM!'),
            //   textColor: Colors.white,
            //   shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            // )
          ],
        ),
        body: GoogleMap(
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: false,
          //onMapCreated: _onMapCreated,
          markers: _markers,
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition:
              CameraPosition(target: widget.currenPosition, zoom: 15),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: Colors.blueGrey,
          currentIndex: index,
          onTap: (int selectedIndex) {
            setState(() {
              index = selectedIndex;
            });
            if(index==0)
            {
              showModalBottomSheet(
                context: context, 
                builder: (context) => Container(
                  child: ListView(
                padding: EdgeInsets.all(8.0),
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration( color: Colors.blue[800], borderRadius: BorderRadius.circular(5)),
                    child: Center(child: Text("Choose Custom Message",style: TextStyle(color: Colors.white,fontSize: 18),))),
                   ListTile(
                     onTap: (){
                        Navigator.of(context).pop();
                getDialouge("My Vehicle Number is:","MH02AQ2097");
                     },
            title: const Text('My Vehicle Number is:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.vehicle,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                   print(message);
                });
                Navigator.of(context).pop();
                getDialouge("My Vehicle Number is:","MH02AQ2097");
              },
            ),
          ),   ListTile(
            onTap: (){
               Navigator.of(context).pop();
                         getDialouge("I am with:","Sid & Vaish");
            },
            title: const Text('I am with:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.company,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                         getDialouge("I am with:","Sid & Vaish");
              },
            ),
          ),
          ListTile(
            onTap: (){
                Navigator.of(context).pop();
                         getDialouge("Time to reach Home:","30 mins/1 Hr");
            },
            title: const Text('Time to reach home:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.time,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                         getDialouge("Time to reach Home:","30 mins/1 Hr");
              },
            ),
          ),
          ListTile(
            onTap: (){
                Navigator.of(context).pop();
                         getDialouge("Call Me:","Asap");
            },
            title: const Text('Call Me:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.callMe,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                            getDialouge("Call Me:","Asap");
              },
            ),
          ),
           ListTile(
            onTap: (){
                Navigator.of(context).pop();
                         getDialouge("Someone is following me:","");
            },
            title: const Text('Someone is following me:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.followingMe,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                            getDialouge("Someone is following me:","");
              },
            ),
          ),
           ListTile(
            onTap: (){
                Navigator.of(context).pop();
                         getDialouge("I dont know the area I am in:","");
            },
            title: const Text('I dont know the area I am in:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.area,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                            getDialouge("I dont know the area I am in:","");
              },
            ),
          ),
           ListTile(
            onTap: (){
                Navigator.of(context).pop();
                         getDialouge("Pretending to text:","So ignore");
            },
            title: const Text('Pretending to Text:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.pretending,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                  print(message);
                });
                  Navigator.of(context).pop();
                            getDialouge("Pretending to Text:","So ignore");
              },
            ),
          ),
           ListTile(
                     onTap: (){
                        Navigator.of(context).pop();
                getDialouge("Other:","Type Custom message");
                     },
            title: const Text('Other:'),
            leading: Radio<CustomMessage>(
              activeColor: Colors.blue[800],
              value: CustomMessage.vehicle,
              groupValue: message,
              onChanged: (value) {
                setState(() {
                  message = value;
                   print(message);
                });
                Navigator.of(context).pop();
                getDialouge("Other:","Type Custom Message");
              },
            ),
          ),
                ],
             
            ),
                  
                )
              ); 
            }
            if (index == 1) Navigator.of(context).pushNamed(Profile.routename);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.message,
                  size: 30,
                  ),
                title: new Text(
                  'Custom Message',
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                   size: 30,
                ),
                title: new Text(
                  'Profile',
                )),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 80.0,
          width: 80.0,
          child: new FloatingActionButton(
            backgroundColor: Colors.red[900],
            onPressed: _makingPhoneCall,
            child: Text(
              'SOS',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
