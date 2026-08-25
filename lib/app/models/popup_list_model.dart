// To parse this JSON data, do
//
//     final popupListModel = popupListModelFromJson(jsonString);

import 'dart:convert';

PopupListModel popupListModelFromJson(String str) => PopupListModel.fromJson(json.decode(str));

String popupListModelToJson(PopupListModel data) => json.encode(data.toJson());

class PopupListModel {
  bool? success;
  String? status;
  String? message;
  Data? data;

  PopupListModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  factory PopupListModel.fromJson(Map<String, dynamic> json) => PopupListModel(
    success: json["success"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<PopupList>? popupList;

  Data({
    this.popupList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    popupList: json["popup_list"] == null ? [] : List<PopupList>.from(json["popup_list"]!.map((x) => PopupList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "popup_list": popupList == null ? [] : List<dynamic>.from(popupList!.map((x) => x.toJson())),
  };
}

class PopupList {
  String? imageUrl;
  String? url;

  PopupList({
    this.imageUrl,
    this.url,
  });

  factory PopupList.fromJson(Map<String, dynamic> json) => PopupList(
    imageUrl: json["image_url"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "image_url": imageUrl,
    "url": url,
  };
}