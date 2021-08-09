import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instashare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String username;

  submit(context) {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      final snackbar = SnackBar(content: Text("Welcome $username"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: "Set up your profile", removeBackButton: true),
        body: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Text(
                      "Create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: TextFormField(
                            validator: (val) {
                              if (val.trim().length < 3 || val.isEmpty) {
                                return "Username too short";
                              } else if (val.trim().length > 14) {
                                return "Username too long";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => username = val,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be at least 3 characters",
                            ),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => submit(context),
                    child: Container(
                      height: 50,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
