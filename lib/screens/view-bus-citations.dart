import 'package:bus_tracker/models/tracked-bus-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewBusCitations extends StatefulWidget {
  const ViewBusCitations({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ViewBusCitations> createState() => _ViewBusCitationsState();
}

class _ViewBusCitationsState extends State<ViewBusCitations> {
  late GoogleMapController mapController;
  late LatLng _center = LatLng(32.524301, 35.841887); //initial center
  Set<Marker> _markers = Set();
  List<TrackedBus> trackedbusses = [];
  bool loaded = false;

  String dropdownvalue = 'Track 1';
  var items = [
    'Track 1',
    'Track 2',
    'Track 3',
  ];

  Future getBusses() async {
    trackedbusses.clear();
    print("dropdown value : ${dropdownvalue}");
    await FirebaseFirestore.instance
        .collection("Bus")
        .where("type", isEqualTo: dropdownvalue)
        .get()
        .then((Busses) {
      if (Busses != null) {
        Busses.docs.forEach((bus) {
          TrackedBus trackedBus = TrackedBus.fromMap(bus);
          trackedbusses.add(trackedBus);
        });
      }
    });

    print("Bus List !");
    trackedbusses.forEach((element) {
      print(element.type);
    });
  }

  void setMarkers(){
    setState(() {
      _markers.clear();
      for (final bus in trackedbusses) {
        final marker = Marker(
          markerId: MarkerId(bus.id!),
          position:
          LatLng((bus.location?.latitude)!, (bus.location?.longitude)!),
          infoWindow: InfoWindow(title: bus.type),
        );
        LatLng testpositions =
        LatLng((bus.location?.latitude)!, (bus.location?.longitude)!);
        print(
            "testlat: ${testpositions.latitude}  testlong ${testpositions.longitude}");
        _markers.add(marker);
      }
      print("before marker");
    });
  }

  void updateMarkers()
  {
    _markers.clear();
    _onMapCreated(mapController);

  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await getBusses();
    setMarkers();
    setState(() {});
    //set marker location
  }

  @override
  void initState() {
    // TODO: implement initState
    getBusses();
    setMarkers();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: size.height * 0.8,
              child: GoogleMap(
                zoomGesturesEnabled: true,
                onMapCreated: _onMapCreated,
                markers: _markers,
                initialCameraPosition:
                    CameraPosition(target: _center, zoom: 15),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select Track :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  value: dropdownvalue,
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(
                        items,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                      //getBusses();
                      _onMapCreated(mapController);

                    });
                  },
                ),
              ],
            )
            // ElevatedButton(onPressed: () {
            //   getBusses();
            // }, child: Text("test"))
          ],
        ),
      ),
    );
  }
}
