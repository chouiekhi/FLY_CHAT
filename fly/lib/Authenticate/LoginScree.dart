import 'package:fly/Authenticate/CreateAccount.dart';
import 'package:fly/Screens/HomeScreen.dart';
import 'package:fly/Authenticate/Methods.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController(text: "");
  final TextEditingController _password = TextEditingController();
  TextEditingController qrcontroller = TextEditingController();
  bool isLoading = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 6,
                  ),
                  Center(
                    child: Container(
                      height: 180,
                      child: Image.asset('images/descarga.png'),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 300,
                  ),
                  Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(size, "Email", Icons.email_outlined, _email),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: fieldContrasena(
                          size, "Contraseña", Icons.lock, _password),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 25,
                  ),
                  customButton(size),
                  SizedBox(
                    height: size.height / 40,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CreateAccount())),
                    child: Container(
                        height: size.height / 14,
                        width: size.width / 1.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(255, 10, 40, 152)),
                        alignment: Alignment.center,
                        child: const Text(
                          "Crear cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  /* QrImage(
                    //backgroundColor: Color.fromARGB(255, 168, 88, 143),
                    foregroundColor: Color.fromARGB(255, 66, 171, 245),
                    data: _email.text,
                    size: 100,
                  ),*/
                  SizedBox(
                    height: size.height / 20,
                  ),
                ],
              ),
            ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              print("Login Sucessfull");
              setState(() {
                isLoading = false;
              });
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomeScreen(_email.text)));
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error de inicio de sesión:'),
                      content: SingleChildScrollView(
                          child: ListBody(
                        children: const [Text('Verifica tus datos!')],
                      )),
                      actions: [
                        // ignore: deprecated_member_use
                        FlatButton(
                          child: const Text('Aceptar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Porfavor'),
                  content: SingleChildScrollView(
                      child: ListBody(
                    children: const [Text('introduce los datos de tu cuenta')],
                  )),
                  actions: [
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: const Text('Aceptar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      },
      child: Container(
          height: size.height / 14,
          width: size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 66, 171, 245)),
          alignment: Alignment.center,
          child: const Text(
            "Iniciar sesión",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }

  Widget field(Size size, String hintText, IconData icon,
      TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: size.height / 800,
        ),
        Container(
          width: size.width / 1.1,
          child: const Center(
            child: Text(
              "FLY",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Container(
          width: size.width / 1.1,
          child: const Text(
            "",
            style: TextStyle(
              color: Color.fromARGB(255, 199, 193, 193),
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: size.height / 100,
        ),
        Container(
          height: size.height / 14,
          width: size.width / 1.1,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 66, 171, 245),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 10, 40, 152), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget fieldContrasena(Size size, String hintText, IconData icon,
      TextEditingController controller) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        obscureText: _isObscure,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
          ),
          suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              }),
          hintText: hintText,
          hintStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 66, 171, 245),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 10, 40, 152), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
