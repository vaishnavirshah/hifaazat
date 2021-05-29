import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './dashboard.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
// ignore: must_be_immutable
class Verify extends StatefulWidget {
  String phoneNumber;
  String verificationId;
  Verify(this.phoneNumber, this.verificationId);
  static const routeName = 'verify';
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  String otp;
    int code;
  LatLng currentPosition;
  String verif;
  String verificationId;
  AuthCredential phoneAuthCredential;
  var _firebaseUser;
  String status;
    
  void _getUserLocation() async {
  var position = await GeolocatorPlatform.instance
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
        }); 
      }
  @override
  void initState() {
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    print(widget.phoneNumber);
    print(widget.verificationId);
    super.initState();
    _getFirebaseUser();
    _getUserLocation();
  }

  void _handleError(e) {
    print(e.message);
    setState(() {
      status += e.message + '\n';
    });
  }

  Future<void> _getFirebaseUser() async {

    this._firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      status =
          (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
    });
  }

  Future<void> _login() async {
    print("hello I am inside login");

    /// This method is used to login the user
    /// `AuthCredential`(`phoneAuthCredential`) is needed for the signIn method
    /// After the signIn method from `AuthResult` we can get `FirebaserUser`(`_firebaseUser`)
    try {
      print("in hereee");
      await FirebaseAuth.instance
          .signInWithCredential(this.phoneAuthCredential)
          .then((UserCredential authRes)async {
            var currentUser=FirebaseAuth.instance.currentUser;
        print("dope");
        print(authRes);
        _firebaseUser = authRes.user;
        print(_firebaseUser.toString());
        List names=[];
        List contacts=[];
        List places=[];
        List latitudes=[];
        List longitudes=[];
        List addresses=[];
        await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
      'is_switched': true,
      'saved_names': names,
      'saved_contacts': contacts,
      'saved_locations': places,
      'latitudes': latitudes,
      'longitudes': longitudes,
      'addresses' : addresses,
    });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (builder) => DashBoard(currentPosition)));
      }).catchError((e) => _handleError(e));
      setState(() {
        status += 'Signed In\n';
      });
    } catch (e) {
      _handleError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
            height: 20,
            child: Center(
                child: Text(
              "Invalid",
              style: TextStyle(color: Colors.white),
            ))),
        backgroundColor: Colors.black,
      ));
    }
  }

  void _submitOTP(String otp) {
    /// get the `smsCode` from the user
    String smsCode = otp;

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    this.phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: smsCode);
    print("dude");
    print(widget.verificationId);
    print(smsCode);
    print(phoneAuthCredential);
    _login();
  }


   Future<void> _submitPhoneNumber(String cc) async {
    print(
        "sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");

    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = widget.phoneNumber;
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more redable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      setState(() {
        status += 'verificationCompleted\n';
      });
      this.phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
    }

    void verificationFailed(FirebaseAuthException error) {
      print('verificationFailed');
      _handleError(error);
    }

    void codeSent(String verificationId, [int code]) {
      print('codeSent');
      this.verificationId = verificationId;

      print(verificationId);
      print("hahahahahaha");
      verif = verificationId;
      print(verif);
      this.code = code;
      print(code.toString());
      setState(() {
        status += 'Code Sent\n';
      });
         print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    print(verif);
    print(phoneNumber);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (builder) => Verify(phoneNumber, verif)));
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      setState(() {
        status += 'codeAutoRetrievalTimeout\n';
      });
      print(verificationId);
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
      timeout: Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      /// When this function is called there is no need to enter the OTP, you can click on Login button to sigin directly as the device is now verified
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
 
  }
  @override
   Widget build(BuildContext context) {
     Size size=MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Lottie.asset(
              "assets/otpverification.json",
              height: 200.0,
              width: 250.0,
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10.0,
                      spreadRadius: 0.0,
                      offset: Offset(2.0, 5.0),
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 10.0,
                  margin: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        padding: EdgeInsets.all(21.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Verification\n\n",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0278AE),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Enter the OTP send to your mobile number",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF373A40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: PinEntryTextField(
                          fieldWidth: 35.0,
                          fontSize: 13.0,
                          showFieldAsBox: true,
                          fields: 6,
                          onSubmit: (String pin) {
                            otp = pin;
                            print(otp);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 14.0),
                child: Center(
      child: Container(
        margin: EdgeInsets.only(top:size.height * 0.40),
        child: SizedBox(
          width: size.width * 0.5,
          height: 50.0,
          // ignore: deprecated_member_use
          child: RaisedButton(
            elevation: 10.0,
            color: Color(0xFF4A90E2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
              side: BorderSide(color: Color(0xFF4A90E2)),
            ),
            onPressed:(){
              _submitOTP(otp);
            } ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                  ),
                ),
                Card(
                  color: Color(0xCDA3C5EC),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0)),
                  child: SizedBox(
                    width: 35.0,
                    height: 35.0,
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       body: Padding(
  //     padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
  //     child: Center(
  //       child: Column(
  //         children: [
  //           Text(
  //             "Verify Phone",
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Text(
  //             "Code is sent to ${widget.phoneNumber}",
  //             style: TextStyle(color: Colors.grey[800], fontSize: 16),
  //           ),
  //           SizedBox(
  //             height: 30,
  //           ),
  //           PinEntryTextField(
  //             fields: 6,
  //             showFieldAsBox: true,
  //             onSubmit: (String pin) {
  //               otp = pin;
  //               print(otp);
  //             }, // end onSubmit
  //           ),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 "Didn't receive the code? ",
  //                 style: TextStyle(color: Colors.grey[800], fontSize: 16),
  //               ),
  //               GestureDetector(
  //                 onTap: () {},
  //                 child: Text(
  //                   "Request Again",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           Container(
  //               width: double.infinity,
  //               height: 60,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   _submitOTP(otp);
  //                 },
  //                 child: Text(
  //                   "VERIFY AND CONTINUE",
  //                   style: TextStyle(color: Colors.white, fontSize: 20),
  //                 ),
  //                 style: ButtonStyle(
  //                     backgroundColor:
  //                         MaterialStateProperty.all<Color>(Colors.indigo[900])),
  //               ))
  //         ],
  //       ),
  //     ),
  //   ));
  // }
}
