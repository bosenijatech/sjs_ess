class AddPassportModel {
  bool? status;
  String? message;
  PassportData? data;

  AddPassportModel({
     this.status,
     this.message,
     this.data,
  });

  factory AddPassportModel.fromJson(Map<String, dynamic> json) {
    return AddPassportModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: PassportData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data!.toJson(),
    };
  }
}

class PassportData {
  String? internalid;
  String? date;
  String? requestTypeId;
  String? requestTypeName;
  String? purposeId;
  String? purposeName;
  String? passportExpiryDate;
  String? requiredDate;
  String? attachment;
  String? isstatus;
  int? createdby;
  String? createdByEmpName;
  String? id;
      String? remark;
  List<dynamic>? approvalHistory;
  String? createdAt;
  String? updatedAt;
  int? v;

  PassportData({
     this.internalid,
     this.date,
     this.requestTypeId,
     this.requestTypeName,
     this.purposeId,
     this.purposeName,
     this.passportExpiryDate,
     this.requiredDate,
     this.attachment,
     this.isstatus,
     this.createdby,
     this.createdByEmpName,
     this.id,
     this.remark,
     this.approvalHistory,
     this.createdAt,
     this.updatedAt,
     this.v,
  });

  factory PassportData.fromJson(Map<String, dynamic> json) {
    return PassportData(
      internalid: json['internalid'] ?? '',
      date: json['date'] ?? '',
      requestTypeId: json['requestTypeId'] ?? '',
      requestTypeName: json['requestTypeName'] ?? '',
      purposeId: json['purposeId'] ?? '',
      purposeName: json['purposeName'] ?? '',
      passportExpiryDate: json['passportExpiryDate'] ?? '',
      requiredDate: json['requiredDate'] ?? '',
      attachment: json['attachment'] ?? '',
      isstatus: json['isstatus'] ?? '',
      remark: json['remark'] ?? '',
      createdby: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      id: json['_id'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalid': internalid,
      'date': date,
      'requestTypeId': requestTypeId,
      'requestTypeName': requestTypeName,
      'purposeId': purposeId,
      'purposeName': purposeName,
      'passportExpiryDate': passportExpiryDate,
      'requiredDate': requiredDate,
      'attachment': attachment,
      'isstatus': isstatus,
      'createdby': createdby,
      'createdByEmpName': createdByEmpName,
      "remark": remark,
      '_id': id,
      'approval_history': approvalHistory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
