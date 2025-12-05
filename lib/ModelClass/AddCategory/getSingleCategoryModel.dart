import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"6932a2a5296aca5e5fe4855b","name":"Lunch","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764926046/categories/g35ijunjhaq5a50bxtyq.png","sortOrder":0,"locationId":{"_id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"shift":"hello","createdBy":{"_id":"692529b1cce96462c4696340","name":"Mathan"},"createdAt":"2025-12-05T09:15:17.729Z","updatedAt":"2025-12-05T09:15:17.729Z","__v":0}

class GetSingleCategoryModel {
  GetSingleCategoryModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  GetSingleCategoryModel.fromJson(dynamic json) {
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
  GetSingleCategoryModel copyWith({
    bool? success,
    Data? data,
  }) =>
      GetSingleCategoryModel(
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

/// _id : "6932a2a5296aca5e5fe4855b"
/// name : "Lunch"
/// isDefault : true
/// image : "https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764926046/categories/g35ijunjhaq5a50bxtyq.png"
/// sortOrder : 0
/// locationId : {"_id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"}
/// shift : "hello"
/// createdBy : {"_id":"692529b1cce96462c4696340","name":"Mathan"}
/// createdAt : "2025-12-05T09:15:17.729Z"
/// updatedAt : "2025-12-05T09:15:17.729Z"
/// __v : 0

class Data {
  Data({
    String? id,
    String? name,
    bool? isDefault,
    String? image,
    num? sortOrder,
    LocationId? locationId,
    String? shift,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _name = name;
    _isDefault = isDefault;
    _image = image;
    _sortOrder = sortOrder;
    _locationId = locationId;
    _shift = shift;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _isDefault = json['isDefault'];
    _image = json['image'];
    _sortOrder = json['sortOrder'];
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    _shift = json['shift'];
    _createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _name;
  bool? _isDefault;
  String? _image;
  num? _sortOrder;
  LocationId? _locationId;
  String? _shift;
  CreatedBy? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? id,
    String? name,
    bool? isDefault,
    String? image,
    num? sortOrder,
    LocationId? locationId,
    String? shift,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        isDefault: isDefault ?? _isDefault,
        image: image ?? _image,
        sortOrder: sortOrder ?? _sortOrder,
        locationId: locationId ?? _locationId,
        shift: shift ?? _shift,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get id => _id;
  String? get name => _name;
  bool? get isDefault => _isDefault;
  String? get image => _image;
  num? get sortOrder => _sortOrder;
  LocationId? get locationId => _locationId;
  String? get shift => _shift;
  CreatedBy? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['isDefault'] = _isDefault;
    map['image'] = _image;
    map['sortOrder'] = _sortOrder;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    map['shift'] = _shift;
    if (_createdBy != null) {
      map['createdBy'] = _createdBy?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "692529b1cce96462c4696340"
/// name : "Mathan"

class CreatedBy {
  CreatedBy({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  CreatedBy.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  CreatedBy copyWith({
    String? id,
    String? name,
  }) =>
      CreatedBy(
        id: id ?? _id,
        name: name ?? _name,
      );
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    return map;
  }
}

/// _id : "6890d1700eb176a5bfc48b2a"
/// name : "Tenkasi"

class LocationId {
  LocationId({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  LocationId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  LocationId copyWith({
    String? id,
    String? name,
  }) =>
      LocationId(
        id: id ?? _id,
        name: name ?? _name,
      );
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    return map;
  }
}
