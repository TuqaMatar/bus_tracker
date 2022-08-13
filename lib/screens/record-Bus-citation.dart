import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bus_tracker/models/tracked-bus-model.dart';
class RecordBus extends StatefulWidget {
  const RecordBus({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RecordBus> createState() => _RecordBusState();
}

class _RecordBusState extends State<RecordBus> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? imageUrl;
  File? _image;
  final imagePicker = ImagePicker();
  String Address ='search';
  // Initial Selected Value for drop down
  String dropdownvalue = 'Track 1';
  GeoPoint location = GeoPoint(34, 35);
  // List of items in our dropdown menu
  var items = [
    'Track 1',
    'Track 2',
    'Track 3',
  ];

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    //print(placemarks);
    Placemark place = placemarks[0];
    Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

  }
  //Get Image From Camera
  Future getImage() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.camera);
      final String fileName = path.basename(image!.path);
      File imageFile = File(image.path);

      UploadTask? uploadTask;
      if (image == null) {
        print("image is null");
        return;
      }
      print("file Name ${fileName}");
      setState(() {
        //to preview image
        this._image = imageFile;
        // to save image to database
        uploadTask = storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'type': dropdownvalue,
              'location': location.toString(),
            }));
      });

      print("after file name ");
      final data = await uploadTask?.whenComplete(() => () {});
      print("after datat");
      imageUrl = await data?.ref.getDownloadURL();

      print("imageUrl ${imageUrl}");
    } on PlatformException catch (e) {
      // TODO
    }

  }

  Future addNewBus(String imageUrl, String type, [GeoPoint? location]) async {
    TrackedBus trackedBus = TrackedBus();

    //writing all the values
    trackedBus.imageUrl = imageUrl;
    trackedBus.type = type;
    trackedBus.location = location;

    await firebaseFirestore.collection("Bus").doc().set(trackedBus.toMap());
    await firebaseFirestore.collection("Bus").get().then((value) {
      value.docs.forEach((element) {
        if (element['type'] == trackedBus.type &&
            element['imageUrl'] == trackedBus.imageUrl &&
            element['location'] == trackedBus.location) {
          trackedBus.id = element.id;
        }
      });
    });
    print("trackedbus id : ${trackedBus.id}");
    await firebaseFirestore
        .collection('Bus')
        .doc(trackedBus.id)
        .update({
      'id': trackedBus.id,
      'imageUrl': trackedBus.imageUrl,
      'type':trackedBus.type,
      'location': trackedBus.location
    })
        .then((_) => print('updated'))
        .catchError((error) => print('update failed: $error'));

  }

  Future<GeoPoint> getDeviceLatLn() async{
    Position position = await _getGeoLocationPosition();
    String currentlocation = 'Lat : ${position.latitude} , Long:${position.longitude} ';
    GetAddressFromLatLong(position);
    return  GeoPoint(position.latitude,position.longitude) ;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Select Track :"),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                    value: dropdownvalue,
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  child: _image == null
                      ? Text("No Image Selected")
                      : Image.file(_image!,
                      width: size.width, height: size.height * 0.4)),
              SizedBox(
                height: 20,
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("choose option"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      InkWell(
                                        onTap: getImage,
                                        splashColor: Colors.blue,
                                        child: Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Text(
                                            "Camera",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _image = null;
                                          });
                                          _image = null;
                                        },
                                        splashColor: Colors.blue,
                                        child: Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            "Remove",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ]),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Icon(Icons.download_rounded),
                      label: Text("Upload Bus Image"))),
              ElevatedButton(
                  onPressed: () async{
                    print("imageUrl ${imageUrl}");
                    print("type ${dropdownvalue}");
                     GeoPoint locationtest = await getDeviceLatLn() ;
                    print("location lat :${locationtest.latitude} long :${locationtest.longitude}");

                    location = await getDeviceLatLn();
                    addNewBus(imageUrl!, dropdownvalue, location);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }


}
