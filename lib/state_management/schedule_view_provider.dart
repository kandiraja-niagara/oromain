import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import 'MqttPayloadProvider.dart';

class ScheduleViewProvider extends ChangeNotifier {
  late MQTTManager manager;
  HttpService httpService = HttpService();
  late MqttPayloadProvider payloadProvider;
  String changeToValue = '';
  bool start = false;
  bool pause = false;
  late String data;
  List<Map<String, dynamic>> scheduleList = [];
  DateTime date = DateTime.now();
  List<Map<String, dynamic>> scheduleListFromMqtt = [];
  Map<String, dynamic> innerList = {};
  late int userID;
  late int controllerID;

  // Constructor
  ScheduleViewProvider() {
    manager= MQTTManager();
  }

  Future<void> requestScheduleData(deviceId) async {
    data = {
      "2600": [
        {"2601": DateFormat('yyyy/MM/dd').format(date)}
      ]
    }.toString();
    manager.publish(data, "AppToFirmware/$deviceId");
  }

  Future<void> getUserSequencePriority(userId, controllerId) async {
    userID = userId;
    controllerID = controllerId;
    print('Getting from http ------------------------------>');
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "scheduleDate": DateFormat('yyyy/MM/dd').format(date)
      };

      var getUserProgramQueue = await httpService.postRequest("getUserSequencePriority", userData);

      if (getUserProgramQueue.statusCode == 200) {
        final responseJson = getUserProgramQueue.body;
        final convertedJson = jsonDecode(responseJson);
        if (convertedJson["code"] == 200) {
          scheduleList = convertedJson;
        } else {
          scheduleList = [];
          print("schedule list is empty in the http");
        }
      }
    } catch (e) {
      log('Error: $e');
    }
    notifyListeners();
  }

  void fetchDataAfterDelay(deviceId) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      scheduleList.clear();
      scheduleListFromMqtt.clear();
    }).then((value) => requestScheduleData(deviceId));
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void dataFromMqttConversion(String payload) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        innerList = data["2900"]["2901"];
        for (int i = 0; i < innerList["S_No"].length; i++) {
          Map<String, dynamic> resultDict = {
            "S_No": innerList["S_No"][i],
            "ScheduleOrder": innerList["ScheduleOrder"][i],
            "ScaleFactor": innerList["ScaleFactor"][i],
            "SkipFlag": innerList["SkipFlag"][i],
            "Priority": innerList["Priority"][i],
            "Date": innerList["Date"][i],
            "ProgramCategory": innerList["ProgramCategory"][i],
            "MainValve": innerList["MainValve"][i],
            "ProgramS_No": innerList["ProgramS_No"][i],
            "ProgramName": innerList["ProgramName"][i],
            "ZoneS_No": innerList["ZoneS_No"][i],
            "ZoneName": innerList["ZoneName"][i],
            "RtcNumber": innerList["RtcNumber"][i],
            "CycleNumber": innerList["CycleNumber"][i],
            "RtcOnTime": innerList["RtcOnTime"][i],
            "ProgramStopMethod": innerList["ProgramStopMethod"][i],
            "RtcOffTime": innerList["RtcOffTime"][i],
            "Status": innerList["Status"][i],
            "Pump": innerList["Pump"][i],
            "SequenceData": innerList["SequenceData"][i],
            "IrrigationMethod": innerList["IrrigationMethod"][i],
            "ScheduleStartTime": innerList["ScheduleStartTime"][i],
            "ActualStartTime": innerList["ActualStartTime"][i],
            "ActualStopTime": innerList["ActualStopTime"][i],
            "IrrigationDuration_Quantity": innerList["IrrigationDuration_Quantity"][i],
            "IrrigationQuantityCompleted": innerList["IrrigationQuantityCompleted"][i],
            "IrrigationDurationCompleted": innerList["IrrigationDurationCompleted"][i],
            "ValveFlowrate": innerList["ValveFlowrate"][i],
          };
          scheduleListFromMqtt.add(resultDict);
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
      notifyListeners();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      // print("invoked");
      if (scheduleListFromMqtt.isNotEmpty) {
        scheduleList = scheduleListFromMqtt;
        // print("scheduleList from provider ==> ${scheduleList.length}");
      } else {
        getUserSequencePriority(userID, controllerID);
      }
      // print("scheduleList from provider outside ==> ${scheduleList.length}");
      notifyListeners();
    });
  }
}
