import 'package:bus_tracker/screens/record-Bus-citation.dart';
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

class ValidateBusImage extends StatefulWidget {
  const ValidateBusImage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ValidateBusImage> createState() => _ValidateBusImageState();
}

class _ValidateBusImageState extends State<ValidateBusImage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? imageUrl;
  File? _image;
  bool _loading = false;
  List _outputs = [];

  // Initial Selected Value for drop down
  String dropdownvalue = 'Track 1';

  // List of items in our dropdown menu
  var items = [
    'Track 1',
    'Track 2',
    'Track 3',
  ];

  getImage() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;

      _image = File(image.path);
    });

    setState(() {
            _loading = false;
    });
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
        
    setState(() {
      _loading = false;
      _outputs = output!;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    print(_outputs);
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  //Get Image From Camera
  // Future getImage() async {
  //   final picker = ImagePicker();
  //   try {
  //     final image = await picker.pickImage(source: ImageSource.gallery);
  //     final String fileName = path.basename(image!.path);
  //     File imageFile = File(image.path);
  //
  //     UploadTask? uploadTask;
  //     var urlDownload;
  //     if (image == null) {
  //       print("image is null");
  //       return;
  //     }
  //     print("file Name ${fileName}");
  //     setState(() {
  //       //to preview image
  //       this._image = imageFile;
  //       // to save image to database
  //       uploadTask = storage.ref(fileName).putFile(
  //           imageFile,
  //           SettableMetadata(customMetadata: {
  //             'type': dropdownvalue,
  //             'location': location.toString(),
  //           }));
  //     });
  //
  //     print("after file name ");
  //     final data = await uploadTask?.whenComplete(() => () {});
  //     print("after datat");
  //     imageUrl = await data?.ref.getDownloadURL();
  //
  //     print("imageUrl ${imageUrl}");
  //   } on PlatformException catch (e) {
  //     // TODO
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              SizedBox(
                height: 50,
              ),
              _loading? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator())
                  : Container(
                      width: size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _image == null ? Container() : Image.file(_image!),
                          SizedBox(height: 20),

                          _outputs.length>0
                              ? Text("${_outputs[0]["label"]}")
                              : Container()
                        ],
                      ),
                    ),
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
                  onPressed: (){
                    setState(() {
                 classifyImage(_image!).then((after)=>{print(_outputs)});
                    });

                    if(_outputs[0]["label"]=="Bus"){
                      // Navigator.pushNamed(context, '/recordBusCitation');         

                      Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (__) => new RecordBus(title: 'Record Bus Citation',image: _image,)));             
                    }
                    else{
                       showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(" Not a Bus"),
                                content: SingleChildScrollView(
                                  child: Text("Image provided not a bus , thefore cant be recorded")
                                ),
                              );
                            });
  
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: Text("Validate"))
            ],
          ),
        ),
      ),
    );
  }
}