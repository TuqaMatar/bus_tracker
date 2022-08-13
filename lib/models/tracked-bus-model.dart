
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackedBus{
  String? id;
  String? imageUrl;
  String? type;
  GeoPoint? location ;

  TrackedBus({
    this.id,
    this.imageUrl,
    this.type,
    this.location
});

  // receiving data from database
  factory TrackedBus.fromMap(map){
    return TrackedBus(
        id: map['id'],
        imageUrl: map['imageUrl'],
        type: map['type'],
        location: map['location']
    );
  }

  //send data to database
  Map <String , dynamic> toMap() {
    return {
      'id' : id ,
      'imageUrl':imageUrl,
      'type': type,
      'location':location
    };
  }

}