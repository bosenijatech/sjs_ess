class ViewAirTicketModel {
   bool? status;
   String? message;
   int? count;
   List<AirTicketData>? data;

  ViewAirTicketModel({
     this.status,
     this.message,
     this.count,
     this.data,
  });

  factory ViewAirTicketModel.fromJson(Map<String, dynamic> json) {
    return ViewAirTicketModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? List<AirTicketData>.from(
              json['data'].map((x) => AirTicketData.fromJson(x)),
            )
          : [],
    );
  }
}

class AirTicketData {
   String? id;
   String? internalId;
   String? date;
   String? purposeOfTravel;
   String? fromLocation;
   String? toLocation;
   String? departureDate;
   String? returnDate;
   String? preferenceTime;
   String? airTicketAttachment;
   String? isStatus;
   String? remark;
   int? createdBy;
   String? createdByEmpName;
   List<dynamic>? approvalHistory;
   DateTime? createdAt;
   DateTime? updatedAt;
   int? version;

  AirTicketData({
     this.id,
     this.internalId,
     this.date,
     this.purposeOfTravel,
     this.fromLocation,
     this.toLocation,
     this.departureDate,
     this.returnDate,
     this.preferenceTime,
     this.airTicketAttachment,
     this.isStatus,
     this.remark,
     this.createdBy,
     this.createdByEmpName,
     this.approvalHistory,
     this.createdAt,
     this.updatedAt,
     this.version,
  });

  factory AirTicketData.fromJson(Map<String, dynamic> json) {
    return AirTicketData(
      id: json['_id'] ?? '',
      internalId: json['internalid'] ?? '',
      date: json['date'] ?? '',
      purposeOfTravel: json['purposeofTravel'] ?? '',
      fromLocation: json['fromlocation'] ?? '',
      toLocation: json['tolocation'] ?? '',
      departureDate: json['depaturedate'] ?? '',
      returnDate: json['returndate'] ?? '',
      preferenceTime: json['prefreenceTime'] ?? '',
      airTicketAttachment: json['airticketattachment'] ?? '',
      isStatus: json['isstatus'] ?? '',
      remark: json['remark'] ?? '',
      createdBy: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'internalid': internalId,
      'date': date,
      'purposeofTravel': purposeOfTravel,
      'fromlocation': fromLocation,
      'tolocation': toLocation,
      'depaturedate': departureDate,
      'returndate': returnDate,
      'prefreenceTime': preferenceTime,
      'airticketattachment': airTicketAttachment,
      'isstatus': isStatus,
      'remark' : remark,
      'createdby': createdBy,
      'createdByEmpName': createdByEmpName,
      'approval_history': approvalHistory,
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
      '__v': version,
    };
  }
}
