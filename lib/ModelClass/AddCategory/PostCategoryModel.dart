import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"name":"dinner","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764922175/categories/u7crvfrthwfeyfle63xx.png","sortOrder":0,"locationId":"6890d1700eb176a5bfc48b2a","shift":"hi","createdBy":"692529b1cce96462c4696340","_id":"69329386296aca5e5fe48491","createdAt":"2025-12-05T08:10:46.003Z","updatedAt":"2025-12-05T08:10:46.003Z","__v":0}

class PostCategoryModel {
  PostCategoryModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  PostCategoryModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse;
  PostCategoryModel copyWith({
    bool? success,
    Data? data,
  }) =>
      PostCategoryModel(
        success: success ?? _success,
        data: data ?? _data,
      );
  bool? get success => _success;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// name : "dinner"
/// isDefault : true
/// image : "https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764922175/categories/u7crvfrthwfeyfle63xx.png"
/// sortOrder : 0
/// locationId : "6890d1700eb176a5bfc48b2a"
/// shift : "hi"
/// createdBy : "692529b1cce96462c4696340"
/// _id : "69329386296aca5e5fe48491"
/// createdAt : "2025-12-05T08:10:46.003Z"
/// updatedAt : "2025-12-05T08:10:46.003Z"
/// __v : 0

class Data {
  Data({
    String? name,
    bool? isDefault,
    String? image,
    num? sortOrder,
    String? locationId,
    String? shift,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _name = name;
    _isDefault = isDefault;
    _image = image;
    _sortOrder = sortOrder;
    _locationId = locationId;
    _shift = shift;
    _createdBy = createdBy;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _isDefault = json['isDefault'];
    _image = json['image'];
    _sortOrder = json['sortOrder'];
    _locationId = json['locationId'];
    _shift = json['shift'];
    _createdBy = json['createdBy'];
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _name;
  bool? _isDefault;
  String? _image;
  num? _sortOrder;
  String? _locationId;
  String? _shift;
  String? _createdBy;
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? name,
    bool? isDefault,
    String? image,
    num? sortOrder,
    String? locationId,
    String? shift,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
        name: name ?? _name,
        isDefault: isDefault ?? _isDefault,
        image: image ?? _image,
        sortOrder: sortOrder ?? _sortOrder,
        locationId: locationId ?? _locationId,
        shift: shift ?? _shift,
        createdBy: createdBy ?? _createdBy,
        id: id ?? _id,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get name => _name;
  bool? get isDefault => _isDefault;
  String? get image => _image;
  num? get sortOrder => _sortOrder;
  String? get locationId => _locationId;
  String? get shift => _shift;
  String? get createdBy => _createdBy;
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['isDefault'] = _isDefault;
    map['image'] = _image;
    map['sortOrder'] = _sortOrder;
    map['locationId'] = _locationId;
    map['shift'] = _shift;
    map['createdBy'] = _createdBy;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}
