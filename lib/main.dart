import 'package:bus_tracker/screens/home-page-screen.dart';
import 'package:bus_tracker/screens/record-Bus-citation.dart';
import 'package:bus_tracker/screens/view-bus-citations.dart';
import 'package:bus_tracker/screens/validate-bus-screen.dart';
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
            RecordBus(title: 'Record Bus Citation' , image:null,),
        '/viewBusCitations': (context) =>
            ViewBusCitations(title: 'Bus Citations'),
        '/home': (context) =>
          MyHomePage(title: 'Bus Tracker'),
        '/validateBus': (context) =>
            ValidateBusImage(title: 'Validate Bus'),  
      },
      home : const MyHomePage(title: 'Bus Tracker'),
      // home: const MyHomePage(title: 'Bus Tracker'),
    );
  }
}
