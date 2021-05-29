//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:womensafety/home.dart';
import './dashboard.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './home.dart';
class Profile extends StatefulWidget {
  static const routename = 'profile=name';
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isSwitched;
  var contactTECs = <TextEditingController>[];
  var nameTECs = <TextEditingController>[];
  var cards = [];
  var placeTECs = <TextEditingController>[];
  var addressTECs=<TextEditingController>[];
  // var latitudeTECs = <TextEditingController>[];
  // var longitudeTECs = <TextEditingController>[];
  var locationCards = [];
  

 
  var currentUser = FirebaseAuth.instance.currentUser;
  String phoneNumber = "";
  String username = "";
  int currentValue = 2;
  LatLng currentPosition;
  @override
  void initState() {
    super.initState();
    addExistingCards();

    print(FirebaseAuth.instance.currentUser);
    _getUserLocation();
    getSwitch();
  }
 void _getUserLocation() async {
        var position = await GeolocatorPlatform.instance
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
//CREATE CARDS FOR EXISTING AND NEW SAVED CONTACTS
  createContactCards(String initialContact, String initialName) {
    print("reached");
    var contactController = TextEditingController(text: initialContact);
    var nameController = TextEditingController(text: initialName);
    contactTECs.add(contactController);
    nameTECs.add(nameController);
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(),
            width: 150,
            child: TextFormField(
              controller: nameController,
              cursorColor: Colors.blue,
              style: TextStyle(color: Colors.blue, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: "Name",
                  hintStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10)),
            width: 225,
            child: TextFormField(
              controller: contactController,
              cursorColor: Colors.blue,
              style: TextStyle(color: Colors.blue, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: "Contact",
                  hintStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 6,
          ),
        ],
      ),
    );
  }

  addExistingCards() async {
    cards.add(createContactCards("", ""));
    locationCards.add(createLocationCards("", ""));
    print("........................................................");
    var currentUser = FirebaseAuth.instance.currentUser;
    var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    List contacts = userData['saved_contacts'];
    List names = userData['saved_names'];
    List places = userData['saved_locations'];
    List lats = userData['latitudes'];
    List longs = userData['longitudes'];
    List actualAddresses=userData['addresses'];
    print(names);
    print("........................................................");

    for (int i = 0; i < contacts.length; i++)
      cards.add(createContactCards(contacts[i], names[i]));

    for (int i = 0; i < places.length; i++)
      locationCards.add(createLocationCards(places[i], actualAddresses[i]));
    if (contacts.length > 0) {
      cards.removeAt(0);
      nameTECs.removeAt(0);
      contactTECs.removeAt(0);
    }
    if (places.length > 0) {
      locationCards.removeAt(0);
      placeTECs.removeAt(0);
      // latitudeTECs.removeAt(0);
      // longitudeTECs.removeAt(0);
      addressTECs.removeAt(0);
    }
  }

  //CREATE CARDS FOR EXISTING AND NEW SAVED LOCATIONS
  Container createLocationCards(String place, String actual) {
    print("done");
    var placeController = TextEditingController(text: place);
    var addressController = TextEditingController(text: actual);
    // var latitudeController = TextEditingController(text: lat);
    // var longitudeController = TextEditingController(text: long);
    placeTECs.add(placeController);
    addressTECs.add(addressController);
    // latitudeTECs.add(latitudeController);
    // longitudeTECs.add(longitudeController);
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                //border: Border.all(color: Colors.blue),
                //borderRadius: BorderRadius.circular(10)
                ),
            width: 150,
            child: TextField(
              controller: placeController,
              cursorColor: Colors.blue,
              style: TextStyle(color: Colors.blue, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: "Place",
                  hintStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10)),
            width: 220,
            child: TextField(
              controller: addressController,
              cursorColor: Colors.blue,
              style: TextStyle(color: Colors.blue, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: "Address",
                  hintStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            width: 3,
          ),
          // Container(
          //   decoration: BoxDecoration(
          //       border: Border.all(color: Colors.blue),
          //       borderRadius: BorderRadius.circular(10)),
          //   width: 100,
          //   child: TextField(
          //     controller: longitudeController,
          //     cursorColor: Colors.blue,
          //     style: TextStyle(color: Colors.blue, fontSize: 18),
          //     textAlign: TextAlign.center,
          //     decoration: InputDecoration(
          //         floatingLabelBehavior: FloatingLabelBehavior.never,
          //         hintText: "Lon",
          //         hintStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
          //         border: InputBorder.none),
          //   ),
          // ),
          SizedBox(
            height: 6,
          ),
        ],
      ),
    );
  }

  _onSubmit(bool isSwitched, List names, List contacts, List places,
      List latitudes,List longitudes, List addresses) async {
    currentUser = FirebaseAuth.instance.currentUser;
    print(isSwitched);
     print(names);
      print(contacts);
       print(places);
        print(longitudes);
         print(latitudes);
      

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
      'is_switched': isSwitched,
      'saved_names': names,
      'saved_contacts': contacts,
      'phoneNumber': phoneNumber,
      'saved_locations': places,
      'latitudes': latitudes,
      'longitudes': longitudes,
      'addresses' : addresses,
    });
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(currentUser.uid)
    //     .update({
    //   'is_switched': isSwitched,
    // });
    currentUser
        .updateProfile(
      displayName: username,
    );
  }

  _onDone()async {
    List places = [];
    List latitudes = [];
    List longitudes = [];
    List contacts = [];
    List names = [];
    List actualAddresses=[];
    print(cards.length);
    print(contactTECs.length);
    print(nameTECs.length);
    print('onDOne');
    if(contactTECs[0].text!="")
    {
 for (int i = 0; i < cards.length; i++) {
      var contact = contactTECs[i].text;
      var name = nameTECs[i].text;
      contacts.add(contact);
      names.add(name);
    }
    }
   if(placeTECs[0].text!="")
   {
      for (int i = 0; i < locationCards.length; i++){
        var place = placeTECs[i].text;
        var address=addressTECs[i].text;
        actualAddresses.add(address);
        // var latitude = latitudeTECs[i].text;
        // var longitude = longitudeTECs[i].text;
          List<Location> locations = await locationFromAddress(address);
          latitudes.add((locations[0].latitude).toString());
          longitudes.add((locations[0].longitude).toString());
          //latitudes.add(locations.Latitude);
        places.add(place);
        // latitudes.add(latitude);
        // longitudes.add(longitude);
      }
    
   }
    
    _onSubmit(isSwitched, names, contacts, places, latitudes, longitudes, actualAddresses);
  }
  getSwitch(){
    Future.delayed(const Duration(milliseconds: 3000), () async{
    var currentUser=FirebaseAuth.instance.currentUser;
                    var userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .get();
                   isSwitched= userData['is_switched'];
                   setState(() {
                     
                   });
});

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 70,
        width: double.infinity,
        color: Colors.blue[800],
        child: FlatButton(
          onPressed: ()async{
await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (builder) => HomePage()));
        }, 
        child: Center(child: Text("LOGOUT",style: TextStyle(color: Colors.white,fontSize: 24),),
        )
        ),
        ),
      appBar: AppBar(
        elevation: 0,
        actions: [
              Transform.scale(
                scale: 1,
                child: Switch(
                   value: isSwitched == null ? true : isSwitched,
                  onChanged: (value)async { 
                    setState(() {
                      isSwitched = value;
                      print(isSwitched);
                    });
                    if ( isSwitched) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 2),
                        content: Container(
                            height: 15,
                            child: Center(
                                child: Text(
                              "Shake SOS On !",
                              style: TextStyle(color: Colors.white),
                            ))),
                        backgroundColor: Colors.blue,
                      ));
                    }
                    else{
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                           duration: Duration(seconds: 2),
                        content: Container(
                            height: 15,
                            child: Center(
                                child: Text(
                              "Shake SOS Off !",
                              style: TextStyle(color: Colors.white),
                            ))),
                        backgroundColor: Colors.blue,
                      ));

                    }
                  },
                   
                  activeTrackColor: Colors.white,
                  activeColor: Colors.blue[200],
                ),
              ),
              
          
          IconButton(
              icon: Icon(
                Icons.done_all,
                size: 30,
              ),
              onPressed: () {
                _onDone();
                Navigator.of(context).pop();
                 Navigator.of(context).pop();
            Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => DashBoard(currentPosition)));
              }),
        ],
        title: Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(75),
                      bottomRight: Radius.circular(75))),
              height: MediaQuery.of(context).size.height * 0.2,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(75),
                        bottomRight: Radius.circular(75))),
                child: Center(
                    child: Column(
                  children: [
                    TextFormField(
                      initialValue: currentUser.displayName,
                      onChanged: (name) {
                        username = name;
                      },
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: "Name",
                          hintStyle:
                              TextStyle(color: Colors.white60, fontSize: 24),
                          border: InputBorder.none),
                    ),
                    TextFormField(
                      initialValue: currentUser.phoneNumber,
                      onChanged: (phone) {
                        phoneNumber = phone;
                      },
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          //hintText: "cONTACT",
                          hintStyle:
                              TextStyle(color: Colors.white60, fontSize: 24),
                          border: InputBorder.none),
                    ),
                  ],
                )),
                color: Colors.blue[800],
                //elevation: 10,
              ),
            ),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTileCard(
                onExpansionChanged: (v) async {
                  setState(() {
                    print("refresh");
                  });
                },
                borderRadius: BorderRadius.circular(10),
                baseColor: Colors.blue[50],
                //expandedColor: Colors.blue[100],
                title: Text(
                  "Saved Contacts",
                  style: TextStyle(color: Colors.blue[800], fontSize: 20),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: Colors.blue[800],
                  size: 40,
                ),
                children: [
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (BuildContext context, int index) {
                        return cards[index];
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue[800],
                          size: 40,
                        ),
                        onPressed: () => setState(
                            () => cards.add(createContactCards("", ""))),
                      ))
                ],
              ),
            ),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTileCard(
                onExpansionChanged: (v) async {
                  setState(() {
                    print("refresh");
                  });
                },
                borderRadius: BorderRadius.circular(10),
                baseColor: Colors.blue[50],
                //expandedColor: Colors.blue[100],
                title: Text(
                  "Saved Locations",
                  style: TextStyle(color: Colors.blue[800], fontSize: 20),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: Colors.blue[800],
                  size: 40,
                ),
                children: [
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: locationCards.length,
                      itemBuilder: (BuildContext context, int index) {
                        return locationCards[index];
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue[800],
                          size: 40,
                        ),
                        onPressed: () => setState(() =>
                            locationCards.add(createLocationCards("", ""))),
                      ))
                ],
              ),
            ),
            Text("* You need to click on the tick marks to save your data",style: TextStyle(color: Colors.grey),)
          ],
        ),
      ),
    );
  }
}
