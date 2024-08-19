class OtpStatusRequestModel {
  String? brand;
  String? manufacturer;
  String? modelNo;
  String? fingerprint;
  String? hardware;
  String? androidID;
  String? iP;
  String? geoLocation;
  String? macAddress;
  String? iEMI;
  String? userName;
  String? phoneNo;
  String? emailId;
  String? city;
  OtpStatusRequestModel(
      {this.brand,
        this.manufacturer,
        this.modelNo,
        this.fingerprint,
        this.hardware,
        this.androidID,
        this.iP,
        this.geoLocation,
        this.macAddress,
        this.iEMI,
        this.userName,
        this.phoneNo,
      this.emailId,
        this.city,
      });

  OtpStatusRequestModel.fromJson(Map<String, dynamic> json) {
    brand = json['Brand'];
    manufacturer = json['Manufacturer'];
    modelNo = json['ModelNo'];
    fingerprint = json['Fingerprint'];
    hardware = json['Hardware'];
    androidID = json['AndroidID'];
    iP = json['IP'];
    geoLocation = json['GeoLocation'];
    macAddress = json['MacAddress'];
    iEMI = json['IEMI'];
    userName = json['UserName'];
    phoneNo = json['PhoneNo'];
    emailId = json['EmailId'];
    city = json['City'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Brand'] = this.brand;
    data['Manufacturer'] = this.manufacturer;
    data['ModelNo'] = this.modelNo;
    data['Fingerprint'] = this.fingerprint;
    data['Hardware'] = this.hardware;
    data['AndroidID'] = this.androidID;
    data['IP'] = this.iP;
    data['GeoLocation'] = this.geoLocation;
    data['MacAddress'] = this.macAddress;
    data['IEMI'] = this.iEMI;
    data['UserName'] = this.userName;
    data['PhoneNo'] = this.phoneNo;
    data['EmailId'] = this.emailId;
    data['City'] = this.city;
    return data;
  }
}
