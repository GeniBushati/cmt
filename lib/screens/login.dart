import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:smashhit_ui/data/data_provider.dart';

class LoginScreen extends StatefulWidget {
  final Function(int) changeScreen;

  LoginScreen(this.changeScreen);

  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  DataProvider dataProvider = new DataProvider();
  bool _signUp = false;
  bool loading = false;
  double smallSide = 10;

  TextEditingController city = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController country = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController name = new TextEditingController();
  TextEditingController surname = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController phone = new TextEditingController();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    getSmallerSide(screenHeight, screenWidth);

    return Material(
        child: Center(
          child: Container(
            width: screenWidth * 0.7,
            height: screenHeight,
            child: Stack(
              children: [
                Column(
                  children: [
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("smash",style: TextStyle(fontSize: smallSide * 0.12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        Text("Hit", style: TextStyle(fontSize: smallSide * 0.12, fontWeight: FontWeight.bold, color: Colors.blue))
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: smallSide * 0.10,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                          radius: smallSide * 0.098,
                          backgroundColor: Colors.white,
                          child: Container(
                            width: smallSide * 0.192,
                            height: smallSide * 0.192,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: ClipOval(
                              child: Icon(Icons.person, size: smallSide * 0.192, color: Colors.white),
                            ),
                          )
                      ),
                    ),
                    _signUp?
                    registrationForm(smallSide) : loginForm(smallSide),
                    Spacer(flex: 2),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _signUp?
                          Flexible(
                            flex: 2,
                            child: MaterialButton(
                              onPressed: () {
                                if (_registrationFormKey.currentState!.validate()) {
                                  _registerUser(name.text, (name.text + surname.text), address.text, city.text, country.text, state.text, phone.text, "Person", email.text);
                                }
                              },
                              child: Text('Register', style: TextStyle(color: Colors.white, fontSize: smallSide * 0.05), overflow: TextOverflow.ellipsis),
                              elevation: 10,
                              color: Colors.grey,
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            ),
                          ) :
                          Flexible(
                            flex: 2,
                            child: MaterialButton(
                              onPressed: () {
                                if(_loginFormKey.currentState!.validate()) {
                                  widget.changeScreen(0);
                                }
                              },
                              child: Text('Login', style: TextStyle(color: Colors.white, fontSize: smallSide * 0.05), overflow: TextOverflow.ellipsis),
                              elevation: 10,
                              color: Colors.grey,
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            ),
                          ),
                          Spacer(),
                          _signUp?
                          Flexible(
                            flex: 2,
                            child: MaterialButton(
                              onPressed: () {
                                _toggleSignUp();
                              },
                              child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: smallSide * 0.05), overflow: TextOverflow.ellipsis),
                              elevation: 10,
                              color: Colors.grey,
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            ),
                          ) :
                          Flexible(
                            flex: 2,
                            child: MaterialButton(
                              onPressed: () {
                                _toggleSignUp();
                              },
                              child: Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: smallSide * 0.05), overflow: TextOverflow.ellipsis),
                              elevation: 10,
                              color: Colors.grey,
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(flex: 4)
                  ],
                ),
                loading? Center(
                  child: CircularProgressIndicator()
                ) : Container()
              ],
            )
          ),
        ));
  }

  void getSmallerSide(double height, double width) {
    setState(() {
      if (height >= width) {
        smallSide = width;
      } else {
        smallSide = height;
      }
    });
  }

  Widget loginForm(double screenWidth) {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: screenWidth * 0.30,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(fontSize: 20)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                },
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )
          ),
        ],
      ),
    );
  }

  Widget registrationForm(double screenWidth) {
    return Form(
      key: _registrationFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: screenWidth * 0.30,
              height: screenWidth * 0.05,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(fontSize: screenWidth / 45)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                },
                controller: name,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth / 45),
              )
          ),
          Container(
              width: screenWidth * 0.30,
              height: screenWidth * 0.05,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Surname',
                    hintStyle: TextStyle(fontSize: screenWidth / 45)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your surname.';
                  }
                },
                controller: surname,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth / 45),
              )
          ),
          Container(
              width: screenWidth * 0.30,
              height: screenWidth * 0.05,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(fontSize: screenWidth / 45)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email.';
                  }
                },
                controller: email,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth / 45),
              )
          ),
          Container(
              width: screenWidth * 0.30,
              height: screenWidth * 0.05,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(fontSize: screenWidth / 45)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number.';
                  }
                },
                controller: phone,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth / 45),
              )
          ),
          cscDropdownPicker(screenWidth * 0.30),
          Container(
              width: screenWidth * 0.30,
              height: screenWidth * 0.05,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Street Address',
                    hintStyle: TextStyle(fontSize: screenWidth / 45)
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your street address.';
                  }
                },
                controller: address,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth / 45),
              )
          ),
        ],
      ),
    );
  }

  Widget cscDropdownPicker(double width) {
    return Container(
      width: width,
      child: CountryStateCityPicker(
        city: city,
        country: country,
        state: state,
        textFieldInputBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
      ),
    );
  }

  void _toggleSignUp() {
    setState(() {
      _signUp = !_signUp;
    });
  }

  void _toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  _registerUser(String name, String agentId, String address, String city,
      String country, String state, String phone, String agentType, String email) async {
    _toggleLoading();
    var result = await dataProvider.createAgent(name, agentId, address, city, country, state, phone, agentType, email);
    if (result == 1) {
      _toggleLoading();
      widget.changeScreen(0);
    } else if (result == -1){
      _toggleLoading();
      showUserAlreadyExistsDialog();
    } else {
    _toggleLoading();
    showRegisterErrorDialog();
    }
  }

  showUserAlreadyExistsDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Already have an account?', textAlign: TextAlign.center),
            contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            children: [
              Text('An account with that name already exists!', textAlign: TextAlign.center),
              MaterialButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  showRegisterErrorDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Oops!', textAlign: TextAlign.center),
            contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            children: [
              Icon(Icons.error, color: Colors.orange, size: 100),
              Text('An error occured while trying to register.', textAlign: TextAlign.center),
              MaterialButton(
                child: Text('Okay, try again!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

}
