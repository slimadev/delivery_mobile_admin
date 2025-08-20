class VehicleModel {
  String? name;
  dynamic id;
  bool? isActive;
  String? vehicleMakeId;

  VehicleModel({this.name, this.id, this.isActive, this.vehicleMakeId});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    isActive = json['isActive'] ?? false;
    vehicleMakeId = json['vehicleMakeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['isActive'] = this.isActive;
    data['vehicleMakeId'] = this.vehicleMakeId;
    return data;
  }
}
