
import 'dart:ffi';
import 'dart:math';

class PlaceData {
  String? place_id;
  String? name;
  List<Photos>? photos;
  double? rating;
  int? userRatingsTotal;
  int? priceLevel;
  int? harga;

  PlaceData({
      this.place_id,
      this.name,
      this.photos,
      this.rating,
      this.userRatingsTotal,
      this.priceLevel,
      this.harga
  });

  PlaceData.fromJson(Map<String, dynamic> json) {
    place_id = json['place_id'];
    name = json['name'];
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(new Photos.fromJson(v));
      });
    }
    rating = (json['rating'] as num).toDouble();
    userRatingsTotal = json['user_ratings_total'];
    priceLevel = json['price_level'];
    harga = Random().nextInt(500000) + 10000; // Angka random sj karena tdk di sediakan sama gogel

  }



}

class Photos {
  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;

  Photos({this.height, this.htmlAttributions, this.photoReference, this.width});

  Photos.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    htmlAttributions = json['html_attributions'].cast<String>();
    photoReference = json['photo_reference'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['html_attributions'] = this.htmlAttributions;
    data['photo_reference'] = this.photoReference;
    data['width'] = this.width;
    return data;
  }
}
