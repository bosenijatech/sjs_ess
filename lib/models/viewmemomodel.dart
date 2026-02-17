class ViewMemoModel {
  bool? status;
  String? message;
  int? count;
  List<MemoData>? data;

  ViewMemoModel({this.status, this.message, this.count, this.data});

  factory ViewMemoModel.fromJson(Map<String, dynamic> json) => ViewMemoModel(
        status: json["status"],
        message: json["message"],
        count: json["count"],
        data: json["data"] != null
            ? List<MemoData>.from(
                json["data"].map((x) => MemoData.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "count": count,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };
}

class MemoData {
  String? id;
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
    String? remark;
  List<dynamic>? approvalHistory;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  MemoData({
    this.id,
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
    this.remark,
    this.approvalHistory,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory MemoData.fromJson(Map<String, dynamic> json) => MemoData(
        id: json["_id"],
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
        remark: json["remark"],
        isstatus: json["isstatus"],
        createdby: json["createdby"],
        createdByEmpName: json["createdByEmpName"],
        approvalHistory: json["approval_history"] ?? [],
        createdAt:
            json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
        updatedAt:
            json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "internalid": internalid,
        "date": date,
        "memoTypeId": memoTypeId,
        "memoType": memoType,
        "subject": subject,
        "desciption": desciption,
        "effectiveDate": effectiveDate?.toIso8601String(),
        "attachment": attachment,
        "remark" : remark,
        "isstatus": isstatus,
        "createdby": createdby,
        "createdByEmpName": createdByEmpName,
        "approval_history": approvalHistory,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
