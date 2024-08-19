class OtpStatusResponseModel {
  String? response;
  String? changeIn;
  String? otp;

  OtpStatusResponseModel({this.response, this.changeIn, this.otp});

  OtpStatusResponseModel.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    changeIn = json['change_in'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response'] = this.response;
    data['change_in'] = this.changeIn;
    data['otp'] = this.otp;
    return data;
  }
}
