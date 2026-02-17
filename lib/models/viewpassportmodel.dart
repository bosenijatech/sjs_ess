class ViewPassportModel {
  bool? status;
  String? message;
  int? count;
  List<PassportData>? data;

  ViewPassportModel({
    this.status,
    this.message,
    this.count,
    this.data,
  });

  factory ViewPassportModel.fromJson(Map<String, dynamic> json) {
    return ViewPassportModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? List<PassportData>.from(
              json['data'].map((x) => PassportData.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status ?? false,
      'message': message ?? '',
      'count': count ?? 0,
      'data': data != null
          ? data!.map((x) => x.toJson()).toList()
          : [],
    };
  }
}

class PassportData {
  String? id;
  String? internalId;
  String? date;
  String? requestTypeId;
  String? requestTypeName;
  String? purposeId;
  String? purposeName;
  DateTime? passportExpiryDate;
  DateTime? requiredDate;
  String? attachment;
  String? isStatus;
  String? remark;
  int? createdBy;
  String? createdByEmpName;
  List<dynamic>? approvalHistory;
  DateTime? createdAt;
  DateTime? updatedAt;

  PassportData({
    this.id,
    this.internalId,
    this.date,
    this.requestTypeId,
    this.requestTypeName,
    this.purposeId,
    this.purposeName,
    this.passportExpiryDate,
    this.requiredDate,
    this.attachment,
    this.isStatus,
    this.remark,
    this.createdBy,
    this.createdByEmpName,
    this.approvalHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory PassportData.fromJson(Map<String, dynamic> json) {
    return PassportData(
      id: json['_id'] ?? '',
      internalId: json['internalid'] ?? '',
      date: json['date'] ?? '',
      requestTypeId: json['requestTypeId'] ?? '',
      requestTypeName: json['requestTypeName'] ?? '',
      purposeId: json['purposeId'] ?? '',
      purposeName: json['purposeName'] ?? '',
      passportExpiryDate: json['passportExpiryDate'] != null
          ? DateTime.tryParse(json['passportExpiryDate'])
          : null,
      requiredDate: json['requiredDate'] != null
          ? DateTime.tryParse(json['requiredDate'])
          : null,
      attachment: json['attachment'] ?? '',
      isStatus: json['isstatus'] ?? '',
      remark: json['remark'] ?? '',
      createdBy: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id ?? '',
      'internalid': internalId ?? '',
      'date': date ?? '',
      'requestTypeId': requestTypeId ?? '',
      'requestTypeName': requestTypeName ?? '',
      'purposeId': purposeId ?? '',
      'purposeName': purposeName ?? '',
      'passportExpiryDate': passportExpiryDate?.toIso8601String() ?? '',
      'requiredDate': requiredDate?.toIso8601String() ?? '',
      'attachment': attachment ?? '',
      'isstatus': isStatus ?? '',
      'remark': remark ?? '',
      'createdby': createdBy ?? 0,
      'createdByEmpName': createdByEmpName ?? '',
      'approval_history': approvalHistory ?? [],
      'createdAt': createdAt?.toIso8601String() ?? '',
      'updatedAt': updatedAt?.toIso8601String() ?? '',
    };
  }
}
