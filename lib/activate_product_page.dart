import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ActivateProductScreen extends StatefulWidget {
  final String email;
  final IO.Socket socket;

  ActivateProductScreen({required this.email, required this.socket});

  @override
  _ActivateProductScreenState createState() => _ActivateProductScreenState();
}

class _ActivateProductScreenState extends State<ActivateProductScreen> {
  TextEditingController _emailController = TextEditingController();
  String _confirmedEmail = '';

  bool get isEmailConfirmed => _confirmedEmail == widget.email;

  Future<void> _handleActivate(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/activate-product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final licenseKey = data['licenseKey'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Продукт активирован',
                style: TextStyle(color: Color.fromRGBO(119, 75, 36, 1)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Поздравляем!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(119, 75, 36, 1)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Продукт для вашего аккаунта "${widget.email}" успешно активирован ключом "$licenseKey".\nТеперь вы можете приступить к работе!',
                    style: TextStyle(fontSize: 16, color: Color.fromRGBO(119, 75, 36, 1)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(widget.socket)),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Color.fromRGBO(119, 75, 36, 1)),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Ошибка',
                style: TextStyle(color: Color.fromRGBO(119, 75, 36, 1)),
              ),
              content: Text(
                'Не удалось активировать продукт',
                style: TextStyle(fontSize: 16, color: Color.fromRGBO(119, 75, 36, 1)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Color.fromRGBO(239, 206, 173, 1)),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Активация продукта',
                style: TextStyle(fontSize: 24, color: Color.fromRGBO(119, 75, 36, 1)),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 206, 173, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Добро пожаловать!\nЧтобы пользоваться приложением для родительского контроля, пожалуйста, активируйте свой продукт.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color.fromRGBO(119, 75, 36, 1)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'На данный Email ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color.fromRGBO(119, 75, 36, 1)),
                    ),
                    Text(
                      '"${widget.email}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' будет активирована лицензия продукта. Введите Email в поле ниже вручную для подтверждения.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color.fromRGBO(119, 75, 36, 1)),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      onChanged: (value) {
                        setState(() {
                          _confirmedEmail = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Подтвердите Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isEmailConfirmed ? () => _handleActivate(context) : null,
                child: Text(
                  'Активировать',
                  style: TextStyle(color: Color.fromRGBO(239, 206, 173, 1)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
