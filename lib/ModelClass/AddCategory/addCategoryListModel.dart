import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"id":"6925478dcce96462c4697001","name":"Pop chicken","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764050829/categories/i4t0zhfsjwtvlbnmcmib.jpg","locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Saranya","createdAt":"2025-11-25","updatedAt":"2025-11-26T04:09:40.432Z","statusText":"Available","productCount":2},{"id":"69326a06bbcaf6bf506f63bc","name":"Briyanii","isDefault":false,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764911620/categories/scmckswepvdw12wmyrmn.webp","locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Mathan","createdAt":"2025-12-05","updatedAt":"2025-12-05T05:26:27.789Z","statusText":"Unavailable","productCount":2},{"id":"693274de66e3690c1607e145","name":"Rice","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764914327/categories/hiszfz8jyj1xad0mroci.png","locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Mathan","createdAt":"2025-12-05","updatedAt":"2025-12-05T05:59:58.162Z","statusText":"Available","productCount":1},{"id":"69329386296aca5e5fe48491","name":"dinner","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764922175/categories/u7crvfrthwfeyfle63xx.png","locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Mathan","createdAt":"2025-12-05","updatedAt":"2025-12-05T08:10:46.003Z","statusText":"Available","productCount":0},{"id":"6932a2a5296aca5e5fe4855b","name":"Lunch","isDefault":true,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764926046/categories/g35ijunjhaq5a50bxtyq.png","locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Mathan","createdAt":"2025-12-05","updatedAt":"2025-12-05T09:15:17.729Z","statusText":"Available","productCount":0},{"id":"69254773cce96462c4696ff1","name":"Demo","isDefault":true,"locationId":{"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"},"createdBy":"Saranya","createdAt":"2025-11-25","updatedAt":"2025-11-26T04:09:40.500Z","statusText":"Available","productCount":2}]
/// totalCount : 6

class AddCategoryListModel {
  AddCategoryListModel({
    bool? success,
    List<Data>? data,
    num? totalCount,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _totalCount = totalCount;
  }

  AddCategoryListModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _totalCount = json['totalCount'];
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  List<Data>? _data;
  num? _totalCount;
  ErrorResponse? errorResponse;
  AddCategoryListModel copyWith({
    bool? success,
    List<Data>? data,
    num? totalCount,
  }) =>
      AddCategoryListModel(
        success: success ?? _success,
        data: data ?? _data,
        totalCount: totalCount ?? _totalCount,
      );
  bool? get success => _success;
  List<Data>? get data => _data;
  num? get totalCount => _totalCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['totalCount'] = _totalCount;
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// id : "6925478dcce96462c4697001"
/// name : "Pop chicken"
/// isDefault : true
/// image : "https://res.cloudinary.com/dm6wrm7vf/image/upload/v1764050829/categories/i4t0zhfsjwtvlbnmcmib.jpg"
/// locationId : {"id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"}
/// createdBy : "Saranya"
/// createdAt : "2025-11-25"
/// updatedAt : "2025-11-26T04:09:40.432Z"
/// statusText : "Available"
/// productCount : 2

class Data {
  Data({
    String? id,
    String? name,
    bool? isDefault,
    String? image,
    LocationId? locationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    String? statusText,
    num? productCount,
  }) {
    _id = id;
    _name = name;
    _isDefault = isDefault;
    _image = image;
    _locationId = locationId;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _statusText = statusText;
    _productCount = productCount;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _isDefault = json['isDefault'];
    _image = json['image'];
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _statusText = json['statusText'];
    _productCount = json['productCount'];
  }
  String? _id;
  String? _name;
  bool? _isDefault;
  String? _image;
  LocationId? _locationId;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  String? _statusText;
  num? _productCount;
  Data copyWith({
    String? id,
    String? name,
    bool? isDefault,
    String? image,
    LocationId? locationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    String? statusText,
    num? productCount,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        isDefault: isDefault ?? _isDefault,
        image: image ?? _image,
        locationId: locationId ?? _locationId,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        statusText: statusText ?? _statusText,
        productCount: productCount ?? _productCount,
      );
  String? get id => _id;
  String? get name => _name;
  bool? get isDefault => _isDefault;
  String? get image => _image;
  LocationId? get locationId => _locationId;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get statusText => _statusText;
  num? get productCount => _productCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['isDefault'] = _isDefault;
    map['image'] = _image;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['statusText'] = _statusText;
    map['productCount'] = _productCount;
    return map;
  }
}

/// id : "6890d1700eb176a5bfc48b2a"
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
    _id = json['id'];
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
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }
}
