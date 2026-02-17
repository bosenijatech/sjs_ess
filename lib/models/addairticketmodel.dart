class AddAirTicketModel {
   bool status;
   String message;
   AirTicketData data;

  AddAirTicketModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddAirTicketModel.fromJson(Map<String, dynamic> json) {
    return AddAirTicketModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: AirTicketData.fromJson(json['data']),
    );
  }
}

class AirTicketData {
   String? internalId;
   String? date;
   String? purposeOfTravel;
   String? fromLocation;
   String? toLocation;
   String? departureDate;
   String? returnDate;
   String? preferenceTime;
   String? airTicketAttachment;
   String? status;
      String? remark;
   int? createdBy;
   String? createdByEmpName;
   String? id;
   List? approvalHistory;
   DateTime? createdAt;
   DateTime? updatedAt;

  AirTicketData({
     this.internalId,
     this.date,
     this.purposeOfTravel,
     this.fromLocation,
     this.toLocation,
     this.departureDate,
     this.returnDate,
     this.preferenceTime,
     this.airTicketAttachment,
     this.status,
     this.remark,
     this.createdBy,
     this.createdByEmpName,
     this.id,
     this.approvalHistory,
     this.createdAt,
     this.updatedAt,
  });

  factory AirTicketData.fromJson(Map<String, dynamic> json) {
    return AirTicketData(
      internalId: json['internalid'] ?? '',
      date: json['date'] ?? '',
      purposeOfTravel: json['purposeofTravel'] ?? '',
      fromLocation: json['fromlocation'] ?? '',
      toLocation: json['tolocation'] ?? '',
      departureDate: json['depaturedate'] ?? '',
      returnDate: json['returndate'] ?? '',
      preferenceTime: json['prefreenceTime'] ?? '',
      airTicketAttachment: json['airticketattachment'] ?? '',
      status: json['isstatus'] ?? '',
      remark: json['remark'] ?? '',
      createdBy: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      id: json['_id'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
