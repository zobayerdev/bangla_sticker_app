class PacksResponseModel {
  final bool? success;
  final int? count;
  final List<PackModel>? data;

  PacksResponseModel({this.success, this.count, this.data});

  factory PacksResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return PacksResponseModel();
    return PacksResponseModel(
      success: json['success'] as bool?,
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PackModel.fromJson(e as Map<dynamic, dynamic>?))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class PackModel {
  final int? id;
  final String? name;
  final String? identifier;
  final String? trayIcon;
  final int? stickerCount;
  final String? status;
  final List<String>? stickers;

  PackModel({
    this.id,
    this.name,
    this.identifier,
    this.trayIcon,
    this.stickerCount,
    this.status,
    this.stickers,
  });

  factory PackModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return PackModel();
    return PackModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      identifier: json['identifier'] as String?,
      trayIcon: json['tray_icon'] as String?,
      stickerCount: json['sticker_count'] as int?,
      status: json['status'] as String?,
      stickers: (json['stickers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identifier': identifier,
      'tray_icon': trayIcon,
      'sticker_count': stickerCount,
      'status': status,
      'stickers': stickers,
    };
  }
}
