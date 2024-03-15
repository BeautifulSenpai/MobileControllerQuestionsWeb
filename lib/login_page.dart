import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/activate_product_page.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/registration_page.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LoginPage extends StatefulWidget {
  final IO.Socket socket;

  LoginPage(this.socket);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ignore: unused_field
  bool _isLicenseValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Авторизация',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Электронная почта',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(
                'Войти',
                style: TextStyle(
                  color: Color.fromRGBO(239, 206, 173, 1),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage(widget.socket)),
                );
              },
              child: Text(
                'У вас нет аккаунта? Зарегистрируйтесь',
                style: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final licenseResponse = await http.post(
        Uri.parse('http://localhost:3000/check-license'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (licenseResponse.statusCode == 200) {
        setState(() {
          _isLicenseValid = true;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(widget.socket)),
          (route) => false,
        );
      } else {
        setState(() {
          _isLicenseValid = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ActivateProductScreen(email: email, socket: widget.socket)),
          (route) => false,
        );
      }
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ошибка входа'),
            content: Text('Неверная электронная почта или пароль. Пожалуйста, попробуйте еще раз.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ошибка входа'),
            content: Text('Не удалось войти. Пожалуйста, попробуйте позже.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
