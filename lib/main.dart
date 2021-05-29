import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './home.dart';
import './profile.dart';
import './dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:splashscreen/splashscreen.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // if(futuresnapshot.connectionState==ConnectionState.waiting)
    //  {
    //    return SplashScreen();
    // }
    return MaterialApp(
      title: 'Woman Safety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreenPage(),
      routes: {
        Profile.routename:(ctx)=>Profile(),
      },
    );
  }
}

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
    LatLng currentPosition;

   void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  firstLocation() { 
  FirebaseAuth auth = FirebaseAuth.instance;
  
  if (auth.currentUser != null) {
    //print(auth.currentUser.uid);
    _getUserLocation();
    return true;
  }else {
    return false;
  }
  
  // FirebaseAuth.instance
  //   .authStateChanges()
  //   .listen((User user) {
  //     if (user != null) {
  //       print(user.uid);
  //     }
//await FirebaseAuth.instance.signOut();
     // if (user == null) {
       // return 1;
     // } else {
      //  _getUserLocation();
        //return 0;
      //}
    //});
  }
  @override
  Widget build(BuildContext context) {
    // if(futuresnapshot.connectionState==ConnectionState.waiting)
    //  {
    //    return SplashScreen();
    // }
    return MaterialApp(
      title: 'Woman Safety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: firstLocation() ?DashBoard(currentPosition) : HomePage(),
      routes: {
        Profile.routename:(ctx)=>Profile(),
      },
    );
  }
}

class SplashScreenPage extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return SplashScreen(  
      seconds: 5,  
      navigateAfterSeconds: new HomeApp(),  
      backgroundColor: Colors.white,  
      image: new Image.network('https://i.postimg.cc/TwJPg5LN/Logo.jpg',alignment: Alignment.center,), 
      loadingText: Text("Loading...."),  
      photoSize: 150.0,  
      loaderColor: Colors.blue, 
    );  
  }  
}  