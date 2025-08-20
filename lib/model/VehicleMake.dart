class VehicleMake {
  String? name;
  dynamic id;
  bool? isActive;
  String? vehicleType;

  VehicleMake({this.name, this.id, this.isActive});

  VehicleMake.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    isActive = json['isActive'] ?? false;
    vehicleType = json['vehicleTypeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isActive'] = this.isActive;
    data['vehicleTypeId'] = this.vehicleType;
    return data;
  }
}
