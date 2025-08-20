class VendorCategory {
  dynamic id;
  String? title;
  bool? active;
  bool? delected;
  bool? publish;
  int? session;

  VendorCategory({
    this.id,
    this.title,
    this.active,
    this.delected,
    this.publish,
    this.session,
  });

  VendorCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    active = json['active'];
    delected = json['delected'];
    publish = json['publish'];
    session = json['session'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['active'] = active;
    data['delected'] = delected;
    data['publish'] = publish;
    data['session'] = session;
    return data;
  }
}
