class AddMemoModel {
  bool? status;
  String? message;
  MemoData? data;

  AddMemoModel({this.status, this.message, this.data});

  factory AddMemoModel.fromJson(Map<String, dynamic> json) => AddMemoModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] != null ? MemoData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class MemoData {
  String? internalid;
  String? date;
  String? memoTypeId;
  String? memoType;
  String? subject;
  String? desciption;
  DateTime? effectiveDate;
  String? attachment;
  String? isstatus;
  int? createdby;
  String? createdByEmpName;
  String? id;
  List<dynamic>? approvalHistory;
  String? remark;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  MemoData({
    this.internalid,
    this.date,
    this.memoTypeId,
    this.memoType,
    this.subject,
    this.desciption,
    this.effectiveDate,
    this.attachment,
    this.isstatus,
    this.createdby,
    this.createdByEmpName,
    this.id,
    this.approvalHistory,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory MemoData.fromJson(Map<String, dynamic> json) => MemoData(
        internalid: json["internalid"],
        date: json["date"],
        memoTypeId: json["memoTypeId"],
        memoType: json["memoType"],
        subject: json["subject"],
        desciption: json["desciption"],
        effectiveDate: json["effectiveDate"] != null
            ? DateTime.parse(json["effectiveDate"])
            : null,
        attachment: json["attachment"],
        isstatus: json["isstatus"],
        remark: json["remark"],
        createdby: json["createdby"],
        createdByEmpName: json["createdByEmpName"],
        id: json["_id"],
        approvalHistory: json["approval_history"] ?? [],
        createdAt:
            json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt:
            json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "internalid": internalid,
        "date": date,
        "memoTypeId": memoTypeId,
        "memoType": memoType,
        "subject": subject,
        "desciption": desciption,
        "effectiveDate": effectiveDate?.toIso8601String(),
        "attachment": attachment,
        "isstatus": isstatus,
        "createdby": createdby,
        "createdByEmpName": createdByEmpName,
        "_id": id,
        "approval_history": approvalHistory,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
