class LoanOffer {
  final int loanProductId;
  final int interestRate;
  final int duration;
  final int principal;
  final String dueOn;
  final num dueAmount;
  final int numberOfInstallments;

  LoanOffer({
    required this.loanProductId,
    required this.interestRate,
    required this.duration,
    required this.principal,
    required this.dueOn,
    required this.dueAmount,
    required this.numberOfInstallments,
  });

  factory LoanOffer.fromJson(Map<String, dynamic> json) {
    return LoanOffer(
      loanProductId: json['loan_product_id'],
      interestRate: json['interest_rate'],
      duration: json['duration'],
      principal: json['principal'],
      dueOn: json['due_on'],
      dueAmount: json['due_amount'],
      numberOfInstallments: json['number_of_installments'],
    );
  }
}
