import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oro_irrigation_new/state_management/schedule_view_provider.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String receivedText = '';
  int _wifiStrength = 0;
  List<dynamic> _list2401 = [];

  late ScheduleViewProvider mySchedule;

  void editMySchedule(ScheduleViewProvider instance){
    mySchedule = instance;
    notifyListeners();
  }

  void setReceivedText(String payload) {
    receivedText = payload;

    try {
      Map<String, dynamic> data = jsonDecode(payload);
      if(data["2900"] != {}) {
        mySchedule.dataFromMqttConversion(payload);
      }
      _wifiStrength = data['2400'][0]['WifiStregth'];
      _list2401 = data['2400'][0]['2401'];
    } catch (e) {
      print('Error parsing JSON: $e');
    }
    notifyListeners();
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => receivedText;
  int get receivedWifiStrength => _wifiStrength;
  List<dynamic> get receivedNodeStatus => _list2401;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;
}
