import 'package:bus_tracker/screens/record-Bus-citation.dart';
import 'package:bus_tracker/screens/view-bus-citations.dart';
import 'package:bus_tracker/validate-bus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'models/tracked-bus-model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print("Unknown error.");
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/recordBusCitation': (context) =>
            RecordBus(title: 'Record Bus Citation'),
        '/viewBusCitations': (context) =>
            ViewBusCitations(title: 'Bus Citations'),
      },
      home: const ValidateBusImage(title:'Validate Image')//MyHomePage(title: 'Bus Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        image :DecorationImage(
          image:AssetImage('assets/images/backgroundImage.png'),
          fit: BoxFit.fill,
        )
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
          children: [
            SizedBox(
              height: 130,
            ),
            GestureDetector(
              onTap: (){ Navigator.pushNamed(context, '/recordBusCitation');},
              child: Container(
                width: size.width*0.5,
                height: size.height*0.25,
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                      border: Border.all(
                        color: Colors.white,
                        width: 8
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bus_alert),
                  SizedBox(height:15),
                  Text("Record Bus Citation" ,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
              ),

            ),

            SizedBox(height: 20),
            GestureDetector(
              onTap: (){ Navigator.pushNamed(context, '/viewBusCitations');},
              child: Container(
                width: size.width*0.5,
                height: size.height*0.25,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.white,
                      width: 8
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search),
                    SizedBox(height:15),
                    Text("View Bus Citations" ,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),)
                  ],
                ),
              ),

            ),
          ],
        )),
      ),
    );
  }
}
