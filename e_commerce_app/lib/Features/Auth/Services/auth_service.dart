import 'dart:convert';

import 'package:e_commerce_app/Constants/error_handling.dart';
import 'package:e_commerce_app/Constants/global_variables.dart';
import 'package:e_commerce_app/Constants/utils.dart';
import 'package:e_commerce_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Common/Widgets/bottom_bar.dart';
import '../../../Providers/user_provider.dart';

class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) {
    User user = User(
      id: '',
      name: name,
      password: password,
      email: email,
      address: '',
      type: '',
      token: '',
    );

    http.post(
      Uri.parse('$uri/api/signup'),
      body: user.toJson(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((res) {
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    }).catchError((e) {
      showSnackBar(context, e.toString());
    });
  }

  // sign in user
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) {
    http.post(
      Uri.parse('$uri/api/signin'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((res) {
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          SharedPreferences.getInstance().then((prefs) {
            Provider.of<UserProvider>(context, listen: false).setUser(res.body);
            prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
            Navigator.pushNamedAndRemoveUntil(
              context,
              BottomBar.routeName,
              (route) => false,
            );
          });
        },
      );
    }).catchError((e) {
      showSnackBar(context, e.toString());
    });
  }

  // get user data
  void getUserData(
    BuildContext context,
  ) {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      ).then((tokenRes) {
        var response = jsonDecode(tokenRes.body);

        if (response == true) {
          http.get(
            Uri.parse('$uri/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token,
            },
          ).then((userRes) {
            var userProvider =
                Provider.of<UserProvider>(context, listen: false);
            userProvider.setUser(userRes.body);
          });
        }
      }).catchError((e) {
        showSnackBar(context, e.toString());
      });
    });
  }
}
