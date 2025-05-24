import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/viewModels/auth_view_model.dart';
import 'package:annora_survey/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginViewModel loginViewModel = LoginViewModel();
  bool rememberMe = false;

  void handleLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);

    if (rememberMe) {
      await prefs.setString('password', passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }

    final result = await loginViewModel.login(
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return;

    if (result['success']) {
      print(result['data']);
      User user = User(
        id: result['data'].id,
        name: result['data'].name,
        email: result['data'].email,
        phone: result['data'].phone,
        region: result['data'].region,
        token: result['data'].token,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(user: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _loadEmail() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString('email') ?? '';
    String password = sp.getString('password') ?? '';
    bool savedRememberMe = sp.getBool('rememberMe') ?? false;

    setState(() {
      emailController.text = email;
      passwordController.text = password;
      rememberMe = savedRememberMe;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset("assets/images/logo.png", height: 100),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.people),
                ),
                autofillHints: [AutofillHints.username, AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text("Remember Password"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text("Login", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
