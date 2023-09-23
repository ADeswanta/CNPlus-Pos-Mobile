import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "api.dart";

class FormField extends StatefulWidget {
  const FormField(this.label, this.formData, this.iconName,
      {super.key, this.obscure = false});

  final String label;
  final Map<String, String> formData;
  final IconData iconName;
  final bool obscure;

  @override
  State<FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<FormField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please fill this field';
          }
          return null;
        },
        onChanged: (val) {
          widget.formData[widget.label] = val;
          debugPrint(widget.formData.toString());
        },
        obscureText: widget.obscure && _isHidden,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.iconName),
          border: const OutlineInputBorder(),
          labelText: widget.label,
          suffix: widget.obscure
              ? InkWell(
                  onTap: () => setState(() {
                    _isHidden = !_isHidden;
                  }),
                  child: Icon(
                    _isHidden ? Icons.visibility : Icons.visibility_off,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool disabledForm = false;
  Map<String, String> formController = {"Username": "", "Password": ""};

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    onLogin(BuildContext context) async {
      SharedPreferences pref = await SharedPreferences.getInstance();

      if (_formKey.currentState!.validate()) {
        ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
        setState(() => disabledForm = true);
        showDialog(
          barrierDismissible: false,
          context: context,
          useRootNavigator: false,
          builder: (_) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  Container(
                    margin: EdgeInsets.only(
                      left: 7,
                    ),
                    child: Text("Logging in..."),
                  ),
                ],
              ),
            );
          },
        );
        dynamic authResponse = await ServerAPI().authenticate(
            formController['Username']!, formController['Password']!);
        debugPrint("$authResponse");
        if (authResponse != null) {
          if (authResponse['karyawan'] != null) {
            pref.setBool("isLoggedIn", true);
            pref.setString(
                "loggedUserName", authResponse['karyawan']['nama_lengkap']);
            pref.setStringList("loggedProfile", [
              authResponse['karyawan']['nama_lengkap'],
              authResponse['karyawan']['email'],
              authResponse['karyawan']['level'],
              authResponse['karyawan']['alamat'],
              authResponse['karyawan']['nomor_telepon'],
            ]);
            Navigator.of(context).pop();
            messengerState.showSnackBar(
              SnackBar(
                content: Text(
                  "Welcome ${authResponse['karyawan']['nama_lengkap']}",
                ),
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil("home", (r) => false);
          } else {
            Navigator.of(context).pop();
            showDialog(
              barrierDismissible: false,
              context: context,
              useRootNavigator: false,
              builder: (_) {
                return AlertDialog(
                  content: Container(
                    margin: EdgeInsets.only(
                      left: 7,
                    ),
                    child:
                        Text("Invalid username of password. Please try again"),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            setState(() => disabledForm = false);
          }
        } else {
          Navigator.of(context).pop();
          showDialog(
            barrierDismissible: false,
            context: context,
            useRootNavigator: false,
            builder: (_) {
              return AlertDialog(
                content: Container(
                  margin: EdgeInsets.only(
                    left: 7,
                  ),
                  child: Text("An error occurred"),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          setState(() => disabledForm = false);
        }
      }
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Opacity(
          opacity: disabledForm ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: disabledForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    SvgPicture.asset(
                      isDarkMode
                          ? "assets/logo-dark.svg"
                          : "assets/logo-light.svg",
                      semanticsLabel: 'CNPlus POS Logo',
                      height: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Sign in to your account",
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ]),
                ),
                FormField("Username", formController, Symbols.person),
                FormField("Password", formController, Symbols.lock,
                    obscure: true),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () => onLogin(context),
                      child: const Text("Login"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
