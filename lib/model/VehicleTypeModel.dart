class VehicleTypeModel {
  String? name;
  String? value;
  bool? isActive;

  VehicleTypeModel({this.name, this.value, this.isActive});

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    name = json['label'];
    value = json['value'];
    isActive = json['isActive'] ?? true; // Padrão true se não especificado
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    data['isActive'] = this.isActive;
    return data;
  }
}
