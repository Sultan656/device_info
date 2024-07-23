class IpWhoIsModel {
  String? ip;
  bool? success;
  String? type;
  String? continent;
  String? continentCode;
  String? country;
  String? countryCode;
  String? countryFlag;
  String? countryCapital;
  String? countryPhone;
  String? countryNeighbours;
  String? region;
  String? city;
  double? latitude;
  double? longitude;
  String? asn;
  String? org;
  String? isp;
  String? timezone;
  String? timezoneName;
  int? timezoneDstOffset;
  int? timezoneGmtOffset;
  String? timezoneGmt;
  String? currency;
  String? currencyCode;
  String? currencySymbol;
  double? currencyRates;
  String? currencyPlural;

  IpWhoIsModel(
      {this.ip,
        this.success,
        this.type,
        this.continent,
        this.continentCode,
        this.country,
        this.countryCode,
        this.countryFlag,
        this.countryCapital,
        this.countryPhone,
        this.countryNeighbours,
        this.region,
        this.city,
        this.latitude,
        this.longitude,
        this.asn,
        this.org,
        this.isp,
        this.timezone,
        this.timezoneName,
        this.timezoneDstOffset,
        this.timezoneGmtOffset,
        this.timezoneGmt,
        this.currency,
        this.currencyCode,
        this.currencySymbol,
        this.currencyRates,
        this.currencyPlural});

  IpWhoIsModel.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    success = json['success'];
    type = json['type'];
    continent = json['continent'];
    continentCode = json['continent_code'];
    country = json['country'];
    countryCode = json['country_code'];
    countryFlag = json['country_flag'];
    countryCapital = json['country_capital'];
    countryPhone = json['country_phone'];
    countryNeighbours = json['country_neighbours'];
    region = json['region'];
    city = json['city'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    asn = json['asn'];
    org = json['org'];
    isp = json['isp'];
    timezone = json['timezone'];
    timezoneName = json['timezone_name'];
    timezoneDstOffset = json['timezone_dstOffset'];
    timezoneGmtOffset = json['timezone_gmtOffset'];
    timezoneGmt = json['timezone_gmt'];
    currency = json['currency'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyRates = json['currency_rates'];
    currencyPlural = json['currency_plural'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ip'] = this.ip;
    data['success'] = this.success;
    data['type'] = this.type;
    data['continent'] = this.continent;
    data['continent_code'] = this.continentCode;
    data['country'] = this.country;
    data['country_code'] = this.countryCode;
    data['country_flag'] = this.countryFlag;
    data['country_capital'] = this.countryCapital;
    data['country_phone'] = this.countryPhone;
    data['country_neighbours'] = this.countryNeighbours;
    data['region'] = this.region;
    data['city'] = this.city;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['asn'] = this.asn;
    data['org'] = this.org;
    data['isp'] = this.isp;
    data['timezone'] = this.timezone;
    data['timezone_name'] = this.timezoneName;
    data['timezone_dstOffset'] = this.timezoneDstOffset;
    data['timezone_gmtOffset'] = this.timezoneGmtOffset;
    data['timezone_gmt'] = this.timezoneGmt;
    data['currency'] = this.currency;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_rates'] = this.currencyRates;
    data['currency_plural'] = this.currencyPlural;
    return data;
  }
}
