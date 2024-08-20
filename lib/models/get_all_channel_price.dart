class GetAllChannelPriceResponse {
  String? channel;
  double? price;
  String? username;
  String? password;
  int? id;

  GetAllChannelPriceResponse(
      {this.channel, this.price, this.username, this.password, this.id});

  GetAllChannelPriceResponse.fromJson(Map<String, dynamic> json) {
    channel = json['channel'];
    price = json['price'];
    username = json['username'];
    password = json['password'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channel'] = this.channel;
    data['price'] = this.price;
    data['username'] = this.username;
    data['password'] = this.password;
    data['id'] = this.id;
    return data;
  }
}
