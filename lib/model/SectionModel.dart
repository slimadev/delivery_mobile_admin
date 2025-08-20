import 'package:emartdriver/model/VendorCategory.dart';

class SectionModel {
  dynamic id;
  String? name;
  bool? isActive;
  bool? delected;
  String? serviceTypeFlag;

  List<VendorCategory>? categories;

  SectionModel({
    this.id,
    this.name,
    this.isActive,
    this.delected,
    this.serviceTypeFlag,
    this.categories,
  });

  SectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isActive = json['active']; // API usa 'active', não 'isActive'
    delected = json['delected'];
    serviceTypeFlag = json['service_type_flag'];

    // Processar categories se existir
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((category) => VendorCategory.fromJson(category))
          .toList();
    }

    // Campo opcional de comissão
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['active'] = isActive;
    data['delected'] = delected;
    data['service_type_flag'] = serviceTypeFlag;

    if (categories != null) {
      data['categories'] =
          categories!.map((category) => category.toJson()).toList();
    }

    return data;
  }
}
