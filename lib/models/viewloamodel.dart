class ViewLoanModel {
   bool? status;
   String? message;
   int? count;
   List<LoanData>? data;

  ViewLoanModel({
     this.status,
     this.message,
     this.count,
     this.data,
  });

  factory ViewLoanModel.fromJson(Map<String, dynamic> json) {
    return ViewLoanModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? List<LoanData>.from(
              json['data'].map((x) => LoanData.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'count': count,
      'data': data!.map((x) => x.toJson()).toList(),
    };
  }
}
class LoanData {
   String? id;
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
   String? remark;
   int? createdBy;
   String? createdByEmpName;
   List<dynamic>? approvalHistory;
   DateTime? createdAt;
   DateTime? updatedAt;

  LoanData({
     this.id,
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
     this.remark,
     this.createdBy,
     this.createdByEmpName,
     this.approvalHistory,
     this.createdAt,
     this.updatedAt,
  });

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      id: json['_id'] ?? '',
      internalId: json['internalid'] ?? '',
      date: json['date'] ?? '',
      loanTypeId: json['loantypeId'] ?? '',
      loanType: json['loanType'] ?? '',
      loanAmount: json['loanAmount'] ?? 0,
      repaymentMonth: json['repaymentMonth'] ?? 0,
      emiAmount: json['emiAmount'] ?? 0,
      reasonForLoan: json['reasonforLoan'] ?? '',
      remark: json['remark'] ?? '',
      requiredDate: DateTime.parse(json['requiredDate']),
      attachment: json['attachment'] ?? '',
      isStatus: json['isstatus'] ?? '',
      createdBy: json['createdby'] ?? 0,
      createdByEmpName: json['createdByEmpName'] ?? '',
      approvalHistory: json['approval_history'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'internalid': internalId,
      'date': date,
      'loantypeId': loanTypeId,
      'loanType': loanType,
      'loanAmount': loanAmount,
      'repaymentMonth': repaymentMonth,
      'emiAmount': emiAmount,
      "remark": remark,
      'reasonforLoan': reasonForLoan,
      'requiredDate': requiredDate!.toIso8601String(),
      'attachment': attachment,
      'isstatus': isStatus,
      'createdby': createdBy,
      'createdByEmpName': createdByEmpName,
      'approval_history': approvalHistory,
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
