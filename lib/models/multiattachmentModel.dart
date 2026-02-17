class AttachmentPayload {
  final String name;
  final String fileType;
  final String base64;

  AttachmentPayload({
    required this.name,
    required this.fileType,
    required this.base64,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "fileType": fileType,
        "content": base64,
      };
}
