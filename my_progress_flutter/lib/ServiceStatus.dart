class ServiceStatus {

  final String Status;

  ServiceStatus({this.Status});

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
        Status: json['Status']
    );
  }

}