class DocumentModel {
  int? id;
  String? description;
  String? requiredFor;

  DocumentModel({this.id, this.description, this.requiredFor});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    requiredFor = json['required_for'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['required_for'] = this.requiredFor;
    return data;
  }
}
