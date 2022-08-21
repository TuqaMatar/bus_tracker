import 'package:flutter/material.dart';
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
      decoration: const BoxDecoration(
        image :DecorationImage(
          image:AssetImage('assets/images/backgroundPicStreet.jpg'),
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
            const SizedBox(
              height: 130,
            ),
            GestureDetector(
              onTap: (){ Navigator.pushNamed(context, '/validateBus');},
              child: Container(
                width: size.width*0.9,
                height: size.height*0.25,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                      border: Border.all(
                        color: Colors.black,
                        width: 5
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20))
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bus_alert),
                  SizedBox(height:15),
                  Text("Record Bus Citation" ,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25 ,
                  ),)
                ],
              ),
              ),

            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: (){ Navigator.pushNamed(context, '/viewBusCitations');},
              child: Container(
                width: size.width*0.9,
                height: size.height*0.25,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.black,
                      width: 5
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search),
                    SizedBox(height:15),
                    Text("View Bus Citations" ,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25
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
