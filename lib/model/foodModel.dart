class FoodData {
  final String foodName;
  final int servingQty;
  final String servingUnit;
  final double calories;
  final double fat;
  final double cholesterol;
  final double protein;
  final double sodium;
  final Photo? photo;

  FoodData({
    required this.foodName,
    required this.servingQty,
    required this.servingUnit,
    required this.calories,
    required this.fat,
    required this.cholesterol,
    required this.protein,
    required this.sodium,
    this.photo,
  });

  factory FoodData.fromJson(Map<String, dynamic> json) {
    return FoodData(
      foodName: json['food_name'] ?? '',
      servingQty: json['serving_qty'] ?? 0,
      servingUnit: json['serving_unit'] ?? '',
      calories: (json['nf_calories'] ?? 0).toDouble(),
      fat: (json['nf_total_fat'] ?? 0).toDouble(),
      cholesterol: (json['nf_cholesterol'] ?? 0).toDouble(),
      protein: (json['nf_protein'] ?? 0).toDouble(),
      sodium: (json['nf_sodium'] ?? 0).toDouble(),
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
    );
  }
}


class Photo {
  final String thumb;
  final String highres;

  Photo({
    required this.thumb,
    required this.highres,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      thumb: json['thumb'] ?? '',
      highres: json['highres'] ?? '',
    );
  }
}
