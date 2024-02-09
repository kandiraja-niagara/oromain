class DataModel {
  List<DataItemModel> data;

  DataModel({required this.data});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? dataList = json['data'];
    if (dataList == null) {
      return DataModel(data: []);
    }

    List<DataItemModel> dataItems = dataList.map((item) => DataItemModel.fromJson(item)).toList();
    return DataModel(data: dataItems);
  }

  List<Map<String, dynamic>> toJson() {
    return data.map((item) => item.toJson()).toList();
  }

  List toMqtt() {
    return data.map((item) => item.toMqtt()).toList();
  }
}

class DataItemModel {
  int nameTypeId;
  String name;
  String nameDescription;
  List<DataAcquisitionModel> dataAcquisition;

  DataItemModel({
    required this.nameTypeId,
    required this.name,
    required this.nameDescription,
    required this.dataAcquisition,
  });

  factory DataItemModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataAcquisitionList = json['dataAcquisition'];
    List<DataAcquisitionModel> dataAcquisitionItems =
    dataAcquisitionList.map((item) => DataAcquisitionModel.fromJson(item)).toList();

    return DataItemModel(
      nameTypeId: json['nameTypeId'],
      name: json['name'],
      nameDescription: json['nameDescription'],
      dataAcquisition: dataAcquisitionItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameTypeId': nameTypeId,
      'name': name,
      'nameDescription': nameDescription,
      'dataAcquisition': dataAcquisition.map((item) => item.toJson()).toList(),
    };
  }

  dynamic toMqtt() {
    String dataAcquisitionString = dataAcquisition
        .map((item) => "$name, ${item.toMqtt()}")
        .toList()
        .join(';\n');

    return dataAcquisitionString;
  }

}

class DataAcquisitionModel {
  int sNo;
  String name;
  String id;
  String location;
  String sampleRate;

  DataAcquisitionModel({
    required this.name,
    required this.id,
    required this.location,
    required this.sampleRate,
    required this.sNo
  });

  factory DataAcquisitionModel.fromJson(Map<String, dynamic> json) {
    return DataAcquisitionModel(
      sNo: json['sNo'],
      name: json['name'],
      id: json['id'],
      location: json['location'],
      sampleRate: json['sampleRate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'id': id,
      'location': location,
      'sampleRate': sampleRate,
    };
  }

  dynamic toMqtt() {
    // return "$sNo, $name, $id, $location, ${sampleRate != '' ? "${sampleRate.substring(0, sampleRate.length - 5)}:00:00" : '00:00:00'}";
    return "$sNo, $name, $id, $location, $sampleRate";

  }
}
