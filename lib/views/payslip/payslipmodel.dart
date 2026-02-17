class PaySlipModel {
  final String employeeId;
  final String employeeName;
  final List<PayslipDetail> payslips;

  PaySlipModel({
    required this.employeeId,
    required this.employeeName,
    required this.payslips,
  });

  factory PaySlipModel.fromJson(Map<String, dynamic> json) {
    return PaySlipModel(
      employeeId: json['employeeId'].toString(),
      employeeName: json['employeeName'] ?? '',
      payslips: (json['payslips'] as List<dynamic>?)
              ?.map((p) => PayslipDetail.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class PayslipDetail {
  final String payMonth;
  final String payslipUrl;

  PayslipDetail({
    required this.payMonth,
    required this.payslipUrl,
  });

  factory PayslipDetail.fromJson(Map<String, dynamic> json) {
    return PayslipDetail(
      payMonth: json['paymonth'] ?? '',
      payslipUrl: json['payslip'] ?? '',
    );
  }
}
