import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/http_service.dart';

class AccountManagement extends StatefulWidget {
  const AccountManagement({Key? key, required this.userID, required this.callback}) : super(key: key);
  final int userID;
  final void Function(String) callback;

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  String countryCode = '', mobileNo = '', userName = '', emailId = '', password = '';
  final TextEditingController controllerMblNo = TextEditingController();
  final TextEditingController controllerUsrName = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPwd = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserAccountDetails();
  }

  Future<void> getUserAccountDetails() async {
    final prefs = await SharedPreferences.getInstance();
    countryCode = prefs.getString('countryCode')!;
    controllerMblNo.text = prefs.getString('mobileNumber')!;
    controllerUsrName.text = prefs.getString('userName')!;
    controllerEmail.text = prefs.getString('email')!;
    controllerPwd.text = prefs.getString('password')!;
  }

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )
            ),
            child: const ListTile(
              title: Text("Account Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blueGrey.shade50,
              child: Row(
                children: [
                  Flexible(
                    flex :1,
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 330,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        flex :1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            InternationalPhoneNumberInput(
                                              onInputChanged: (PhoneNumber number) {
                                                //print(number.phoneNumber);
                                              },
                                              selectorConfig: const SelectorConfig(
                                                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                                setSelectorButtonAsPrefixIcon: true,
                                                leadingPadding: 10,
                                                useEmoji: false,
                                              ),
                                              ignoreBlank: false,
                                              inputDecoration: InputDecoration(
                                                labelText: 'Mobile Number',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0), // Border radius
                                                ),
                                              ),
                                              autoValidateMode: AutovalidateMode.disabled,
                                              selectorTextStyle: const TextStyle(color: Colors.black),
                                              initialValue: PhoneNumber(isoCode: 'IN'),
                                              textFieldController: controllerMblNo,
                                              formatInput: false,
                                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                              onSaved: (PhoneNumber number) {
                                                //print('On Saved: $number');
                                              },
                                            ),
                                            Form(
                                              key: formKey,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  const SizedBox(height: 20),
                                                  TextFormField(
                                                    controller: controllerUsrName,
                                                    decoration: InputDecoration(
                                                      labelText: 'Name',
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0), // Border radius
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter your name';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //_name = value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextFormField(
                                                    controller: controllerPwd,
                                                    decoration: InputDecoration(
                                                      labelText: 'Password',
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0), // Border radius
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //_name = value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextFormField(
                                                    controller: controllerEmail,
                                                    decoration: InputDecoration(
                                                      labelText: 'Email Id',
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0), // Border radius
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter your email id';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //_name = value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      MaterialButton(
                                                        color: Colors.grey,
                                                        textColor: Colors.white,
                                                        child: const Text('CANCEL'),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                      const SizedBox(width: 20,),
                                                      MaterialButton(
                                                        color: Colors.blue,
                                                        textColor: Colors.white,
                                                        child: const Text('SAVE CHANGES'),
                                                        onPressed: () async {
                                                          try {
                                                            if (formKey.currentState!.validate()) {
                                                              final body = {"userId": widget.userID, "userName": controllerUsrName.text, "countryCode": countryCode, "mobileNumber": controllerMblNo.text,
                                                                "emailAddress": controllerEmail.text,"password": controllerPwd.text,"modifyUser": widget.userID,};
                                                              final response = await HttpService().putRequest("updateUserDetails", body);
                                                              if (response.statusCode == 200) {
                                                                final jsonResponse = json.decode(response.body);
                                                                widget.callback(jsonResponse['message']);
                                                              }
                                                            }
                                                          } catch (e) {
                                                            print('Error: $e');
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Flexible(
                                        flex :1,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('When Mobile Number and Email update', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text("OTP (One-Time Password) is crucial when changing your "
                                                        "mobile number or email associated with the account"
                                                      , style: TextStyle(fontWeight: FontWeight.normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text("When you initiate such changes, the app often sends"
                                                        " an OTP to your current registered mobile number or email address."
                                                        " You need to enter this OTP to confirm and complete the update"
                                                      , style: TextStyle(fontWeight: FontWeight.normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20,),
                                              Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Text('1.'),
                                                  SizedBox(width: 10,),
                                                  Text('at least 6 characters password', style: TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Text('2.'),
                                                  SizedBox(width: 10,),
                                                  Text('at least one uppercase letter', style: TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Text('3.'),
                                                  SizedBox(width: 10,),
                                                  Text('at least one number', style: TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
