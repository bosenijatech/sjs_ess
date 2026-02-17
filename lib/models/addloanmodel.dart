class AddLoanModel {
   bool? status;
   String? message;
   LoanData? data;

  AddLoanModel({
     this.status,
     this.message,
     this.data,
  });

  factory AddLoanModel.fromJson(Map<String, dynamic> json) {
    return AddLoanModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LoanData.fromJson(json['data'] ?? {}),
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
class LoanData {
   String? internalId;
   String? date;
   String? loanTypeId;
   String? loanType;
   int? loanAmount;
   int? repaymentMonth;
   int? emiAmount;
   String? reasonForLoan;
   DateTime? requiredDate;
   String? attachment;
   String? isStatus;
   int? createdBy;
   String? createdByEmpName;
   String? id;
   List<dynamic>? approvalHistory;
   DateTime? createdAt;
   DateTime? updatedAt;
   int? version;

  LoanData({
     this.internalId,
     this.date,
     this.loanTypeId,
     this.loanType,
     this.loanAmount,
     this.repaymentMonth,
     this.emiAmount,
     this.reasonForLoan,
     this.requiredDate,
     this.attachment,
     this.isStatus,
     this.createdBy,
     this.createdByEmpName,
     this.id,
     this.approvalHistory,
     this.createdAt,
     this.updatedAt,
     this.version,
  });

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      internalId: json['internalid'] ?? '',
      date: json['date'] ?? '',
      loanTypeId: json['loantypeId'] ?? '',
      loanType: json['loanType'] ?? '',
      loanAmount: json['loanAmount'] ?? 0,
      repaymentMonth: json['repaymentMonth'] ?? 0,
      emiAmount: json['emiAmount'] ?? 0,
      reasonForLoan: json['reasonforLoan'] ?? '',
      requiredDate: DateTime.parse(json['requiredDate']),
      attachment: json['attachment'] ?? '',
      isStatus: json['isstatus'] ?? '',
      createdBy: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      id: json['_id'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalid': internalId,
      'date': date,
      'loantypeId': loanTypeId,
      'loanType': loanType,
      'loanAmount': loanAmount,
      'repaymentMonth': repaymentMonth,
      'emiAmount': emiAmount,
      'reasonforLoan': reasonForLoan,
      'requiredDate': requiredDate!.toIso8601String(),
      'attachment': attachment,
      'isstatus': isStatus,
      'createdby': createdBy,
      'createdByEmpName': createdByEmpName,
      '_id': id,
      'approval_history': approvalHistory,
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
      '__v': version,
    };
  }
}
