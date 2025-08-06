class VehicleTypes {
  String? name;
  String? id;
  bool? isActive;


  VehicleTypes({this.name, this.id, this.isActive});

  VehicleTypes.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    id = json['id'];
    isActive = json['isActive'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['isActive'] = this.isActive;
    return data;
  }
}
