import 'package:fly/Authenticate/Methods.dart';
import 'package:fly/Screens/ChatRoom.dart';
import 'package:fly/group_chats/group_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final String texto;

  const HomeScreen(this.texto, {Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final TextEditingController _searchCamara = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController controller = TextEditingController();
  final myController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  void methodo() {
    bool saber = true;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });
    if (isLoading = true) {
      _firestore
          .collection('users')
          .where("email", isNotEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });

        print(userMap);
      });
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    if (_search.text.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: _search.text)
          .get();
      setState(() {
        isLoading = true;
      });

      if (snapshot.size != 0) {
        await _firestore
            .collection('users')
            .where("email", isEqualTo: _search.text)
            .get()
            .then((value) {
          setState(() {
            userMap = value.docs[0].data();
            isLoading = false;
          });
          print(userMap);
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: const [
                    Text('Email que buscas no es valido o no esta registrado')
                  ],
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
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Porfavor'),
              content: SingleChildScrollView(
                  child: ListBody(
                children: const [Text('introduce email para buscar')],
              )),
              actions: [
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
  }

  void onSearchCameraEscanear() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: _scanBarcode)
        .get();
    setState(() {
      isLoading = true;
    });

    if (snapshot.size != 0) {
      await _firestore
          .collection('users')
          .where("email", isEqualTo: _scanBarcode)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: SingleChildScrollView(
                  child: ListBody(
                children: const [
                  Text(
                      'Email que estas Eascaneado no es valido o no esta registrado')
                ],
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
  }

  String _scanBarcode = '';

  @override
  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      controller = _searchCamara;
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    onSearchCameraEscanear();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String valor = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 105, 225),
        title: const Text("Chats"),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => logOut(context))
        ],
      ),
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
                    height: size.height / 15,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: Container(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: TextField(
                        /* onChanged: (barcodeScanRes) {
                  
                        _scanBarcode = barcodeScanRes;
                      },*/
                        controller: _search,
                        decoration: InputDecoration(
                          prefixIcon: const Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Icon(Icons.search)),
                          hintText: "Buscar...",
                          // labelText: _scanBarcode,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(162, 85, 57, 225),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 26, 7, 232),
                                width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 20,
                  ),
                  ElevatedButton(
                    onPressed: onSearch,
                    child: const Text("Buscar"),
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 29, 19, 218)),
                  ),
                  SizedBox(
                    height: size.height / 100,
                  ),
                  ElevatedButton(
                      onPressed: () => scanQR(),
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 29, 19, 218)),
                      child: const Text('ESCANEAR CÓDIGO')),
                  SizedBox(
                    height: size.height / 10,
                  ),
                  userMap != null
                      ? ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName!,
                                userMap!['name']);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap!,
                                ),
                              ),
                            );
                          },
                          leading: const Icon(Icons.account_box,
                              color: Colors.black),
                          title: Text(
                            userMap!['name'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(userMap!['email']),
                          //enabled: false,
                          trailing: const Icon(Icons.chat, color: Colors.black),
                        )
                      : Container(),
                  Container(
                      alignment: Alignment.center,
                      child: Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[])),
                  QrImage(
                    //backgroundColor: Color.fromARGB(255, 168, 88, 143),
                    foregroundColor: Color.fromARGB(255, 66, 171, 245),
                    data: widget.texto,
                    size: 110,
                  ),
                  SizedBox(
                    height: size.height / 10,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        backgroundColor: const Color.fromARGB(255, 54, 46, 143),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(widget.texto),
          ),
        ),
      ),
    );
  }
}
