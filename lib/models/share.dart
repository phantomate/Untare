class ShareModel {
  final String? link;

  ShareModel({
    this.link
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      link: json['link'] as String?
    );
  }
}