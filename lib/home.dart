import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './verify.dart';
import 'package:lottie/lottie.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController phoneNumberController = TextEditingController();
  String phoneNumber;
  String status;
  String countryCode="+91";
  AuthCredential phoneAuthCredential;
  var _firebaseUser;

  String verificationId;
  String verif;

  int code;

  @override
  void initState() {
    super.initState();
    _getFirebaseUser();
  }

  Future<void> _getFirebaseUser() async {
    // ignore: await_only_futures
    this._firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      status =
          (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
    });
  }

  void _handleError(e) {
    print(e.message);
    setState(() {
      status += e.message + '\n';
    });
  }

  Future<void> _submitPhoneNumber(String cc) async {
    print(
        "sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");

    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    phoneNumber ="+91 "+ phoneNumberController.text.toString().trim();
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
    Navigator.of(context).push(
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
            margin: EdgeInsets.only(top:size.height * 0.05),
            child: Lottie.asset(
              "assets/otp.json",
              height: size.height * 0.4,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
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
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10.0,
                  margin: EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.all(7.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(7.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Login with mobile number\n\n\n",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0278AE),
                                  ),
                                ),
                                TextSpan(
                                  text: "We will send you an",
                                  style: TextStyle(
                                    color: Color(0xFF373A40),
                                  ),
                                ),
                                TextSpan(
                                  text: " One Time Password (OTP) ",
                                  style: TextStyle(
                                    color: Color(0xFF373A40),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: "on this mobile number"),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.045),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: TextFormField(
                               onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                              controller: phoneNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFD4D4D4),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFD4D4D4),
                                    width: 1.0,
                                  ),
                                ),
                                hintText: "Enter Your Mobile Number.",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
             Center(
      child: Container(
        margin: EdgeInsets.only(top: size.height * 0.40),
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
              _submitPhoneNumber(countryCode);
            },
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
            ],
          )
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
  //             "Please enter your mobile number",
  //             style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
  //           ),
  //           SizedBox(height: 10),
  //           Text(
  //             "You'll receive a 4 digit code to verify text",
  //             style: TextStyle(color: Colors.grey,fontSize: 16),
  //           ),
  //           SizedBox(height: 10),
  //           Container(
  //             width: double.infinity,
  //             height: 70,
  //             decoration: BoxDecoration(
  //               border: Border.all(width: 1),
  //             ),
  //             child: Row(
  //               children: [
  //                 CountryListPick(

  //                     // if you need custome picker use this
  //                     pickerBuilder: (context, CountryCode countryCode) {
  //                       return Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Image.asset(
  //                             countryCode.flagUri,
  //                             package: 'country_list_pick',
  //                           ),
  //                           SizedBox(width: 10),
  //                           //Text(countryCode.code),
  //                           SizedBox(width: 10),
  //                           Text(
  //                             countryCode.dialCode,
  //                             style:
  //                                 TextStyle(color: Colors.black, fontSize: 20),
  //                           ),
  //                           Text("-",
  //                               style: TextStyle(
  //                                   color: Colors.black, fontSize: 20))
  //                         ],
  //                       );
  //                     },

  //                     // To disable option set to false
  //                     theme: CountryTheme(
  //                       isShowFlag: true,
  //                       isShowTitle: true,
  //                       isShowCode: true,
  //                       isDownIcon: true,
  //                       showEnglishName: true,
  //                     ),
  //                     // Set default value
  //                     initialSelection: '+91',
  //                     // or
  //                     // initialSelection: 'US'
  //                     onChanged: (CountryCode code) {
  //                       countryCode=code.dialCode;
  //                       print(code.name);
  //                       print(code.code);
  //                       print(code.dialCode);
  //                       print(code.flagUri);
  //                     },
  //                     // Whether to allow the widget to set a custom UI overlay
  //                     useUiOverlay: true,
  //                     // Whether the country list should be wrapped in a SafeArea
  //                     useSafeArea: false),
  //                 Container(
  //                   padding: EdgeInsets.all(4),
  //                   width: MediaQuery.of(context).size.width * 0.5,
  //                   child: TextField(
  //                     controller: phoneNumberController,
  //                     onTap: () {
  //                       FocusScopeNode currentFocus = FocusScope.of(context);
  //                       if (!currentFocus.hasPrimaryFocus) {
  //                         currentFocus.unfocus();
  //                       }
  //                     },
  //                     decoration: InputDecoration(
  //                       labelText: "Mobile Number",
  //                     ),
  //                     onChanged: (value) {},
  //                     keyboardType: TextInputType.number,
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //           SizedBox(
  //             height: 30,
  //           ),
  //           Container(
  //               width: double.infinity,
  //               height: 60,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   _submitPhoneNumber(countryCode);
  //                   // print("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG");
  //                   //  print(verif);
  //                   // print(phoneNumber);
  //                   // Navigator.of(context).pushReplacement(MaterialPageRoute(
  //                   // builder: (builder) =>
  //                   //     Verify(phoneNumber, verif)));
  //                 },
  //                 child: Text(
  //                   "CONTINUE",
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
