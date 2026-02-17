class MultiAttachModel {
  String fileName;
  int fileId;
  String url;

  MultiAttachModel({
    required this.fileName,
    required this.fileId,
    required this.url,
  });

  factory MultiAttachModel.fromJson(Map<String, dynamic> json) {
    return MultiAttachModel(
      fileName: json['fileName'],
      fileId: json['fileId'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fileName": fileName,
      "fileId": fileId,
      "url": url,
    };
  }
}
