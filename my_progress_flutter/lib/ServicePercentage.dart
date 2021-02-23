class ServicePercentage {

  final String Percentage1;
  final String Percentage2;

  ServicePercentage({
    this.Percentage1,
    this.Percentage2
  });

  factory ServicePercentage.fromJson(Map<String, dynamic> json) {
    return ServicePercentage(
        Percentage1: json['Percentage1'],
        Percentage2: json['Percentage2']
    );
  }

}