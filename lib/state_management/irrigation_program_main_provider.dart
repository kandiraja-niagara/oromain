import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/IrrigationModel/sequence_model.dart';
import '../constants/http_service.dart';

class IrrigationProgramMainProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    Future.delayed(Duration.zero, (){
      notifyListeners();
    });
  }

  //TODO:SEQUENCE SCREEN PROVIDER
  final HttpService httpService = HttpService();

  SequenceModel? _irrigationLine;
  SequenceModel? get irrigationLine => _irrigationLine;
  List zoneSnoList = [];
  List zoneNameList = [];
  List sNoList = [];
  List programSNoList = [];
  String zoneSerialNumberCreation = '';

  Future<void> getUserProgramSequence(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSequence = await httpService.postRequest('getUserProgramSequence', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        _irrigationLine = SequenceModel.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  bool isRecentlySelected = false;

  void valveSelection(valves, titleIndex, valveIndex, isGroup, serialNumber) {
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';
    int zoneSno() {
      if(_irrigationLine!.sequence.isEmpty) {
        int zoneSNo = 1;
        return zoneSNo++;
      } else {
        int length = _irrigationLine!.sequence.length+1;
        return length++;
      }
    }
    updateSequencedValves(valves, valueToShow, titleIndex+1, serialNumber, zoneSno(), isGroup);
    notifyListeners();
  }

  bool isSameLine = false;
  bool isStartTogether = false;
  bool isReuseValve = true;
  bool isContains = false;
  bool isAgitator = false;
  bool groupAdding = false;

  void updateIsAgitator() {
    isAgitator = true;
    notifyListeners();
  }

  void updateSequencedValves(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup) {
    if (isSingleValveMode) {
      handleSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup);
      groupAdding = false;
    } else {
      if(!isGroup && isMultipleValveMode) {
        handleMultipleValvesMode(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup);
        groupAdding = false;
      } else {
        groupAdding = true;
      }
    }
  }

  void handleSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup) {
    if (selectedProgramType == 'Agitator Program') {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
    } else {
      handleNonAgitatorSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup);
    }
  }

  void handleNonAgitatorSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup) {
    bool isContains = checkValveContainment(valves, isGroup);

    if (irrigationLine!.defaultData.reuseValve || !isContains) {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
      isStartTogether = false;
      isReuseValve = false;
    } else {
      isReuseValve = true;
    }
  }

  bool checkValveContainment(valves, isGroup) {
    for (var item in _irrigationLine!.sequence) {
      if (!isGroup) {
        if (item['valve'].any((valve) => valve['sNo']! == valves['sNo'])) {
          return true;
        }
      } else if (isGroup) {
        for(var valveInGroup in valves){
          if(item['valve'].any((valve) => valve['sNo']! == valveInGroup["sNo"])) {
            return true;
          }
        }
      }
    }
    return false;
  }
  void handleMultipleValvesMode(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup) {
    if (_irrigationLine!.sequence.isEmpty && !isAgitator) {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
      isStartTogether = false;
    } else {
      var lastIndex = _irrigationLine!.sequence.length - 1;
      var selectedLength = _irrigationLine!.sequence[lastIndex]["selected"].length - 1;

      if (!_irrigationLine!.sequence[lastIndex]["selected"][selectedLength].startsWith("G") || isGroup) {
        handleNonEmptySequence(valves, valueToShow, titleIndex, isGroup);
        groupAdding = false;
      } else {
        groupAdding = true;
      }
    }
  }

  void addSequence(valves, valueToShow, serialNumber, sNo, isGroup) {
    _irrigationLine!.sequence.add({
      "sNo": sNo,
      "id": 'SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo',
      "name": 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo',
      "location": '',
      "valve": isGroup ? valves : [valves],
      "selected": [valueToShow]
    });
    zoneSnoList.add('${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    zoneNameList.add('Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    programSNoList.add('${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    notifyListeners();
  }

  void handleNonEmptySequence(valves, valueToShow, titleIndex, isGroup) {
    int lastIndex = _irrigationLine!.sequence.length - 1;

    if (lastIndex >= 0) {
      dynamic lastItem = _irrigationLine!.sequence[lastIndex];
      List? sNoList = lastItem["valve"];
      isSameLine = lastItem['selected']!.every((item) {
        String itemString = item.toString();
        return itemString.startsWith(titleIndex.toString());
      });

      if (selectedProgramType == 'Agitator Program') {
        updateAgitatorProgram(valves, sNoList, valueToShow, lastItem);
      } else {
        updateNonAgitatorProgram(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
      }
    }
  }

  void updateAgitatorProgram(valves, sNoList, valueToShow, lastItem) {
    sNoList?.add(valves);
    List<String>? selectedList = lastItem["selected"]?.cast<String>();
    selectedList?.add(valves['name']);
  }

  void updateNonAgitatorProgram(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    if (irrigationLine!.defaultData.startTogether) {
      handleStartTogether(valves, sNoList, valueToShow, lastItem);
    } else {
      handleNonStartTogether(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
    }
  }

  void handleStartTogether(valves, sNoList, valueToShow, lastItem) {
    if (irrigationLine!.defaultData.reuseValve || !sNoList!.any((element) => element['sNo'] == valves['sNo'])) {
      isReuseValve = false;
      sNoList?.add(valves);
      List<String>? selectedList = lastItem["selected"]?.cast<String>();
      selectedList?.add(valueToShow);
    } else {
      isReuseValve = true;
    }
  }

  void handleNonStartTogether(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    if (isSameLine) {
      handleSameLine(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
    } else {
      isStartTogether = true;
    }
  }

  void handleSameLine(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    if (!irrigationLine!.defaultData.startTogether) {
      if (!isGroup) {
        if (!sNoList!.any((element) => element['sNo'] == valves['sNo'])) {
          isReuseValve = false;
          sNoList?.add(valves);
          List<String>? selectedList = lastItem["selected"]?.cast<String>();
          selectedList?.add(valueToShow);
          isStartTogether = false;
        } else {
          if (irrigationLine!.defaultData.reuseValve) {
            sNoList?.add(valves);
            List<String>? selectedList = lastItem["selected"]?.cast<String>();
            selectedList?.add(valueToShow);
            isReuseValve = false;
          } else {
            isReuseValve = true;
          }
        }
      } else {
        isStartTogether = false;
      }
    } else {
      isStartTogether = false;
    }
  }

  void reorderSelectedValves(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final valve = _irrigationLine!.sequence[oldIndex];
    _irrigationLine!.sequence.removeAt(oldIndex);
    _irrigationLine!.sequence.insert(newIndex, valve);
  }

  bool isSingleValveMode = true;
  bool isNext = false;
  bool isMultipleValveMode = false;
  void enableMultipleValveMode() {
    isSingleValveMode = false;
    isMultipleValveMode = true;
    isDelete = false;
    isNext = false;
    notifyListeners();
  }

  void enableSingleValveMode() {
    isSingleValveMode = true;
    isMultipleValveMode = false;
    isDelete = false;
    isNext = false;
    notifyListeners();
  }

  bool isDelete = false;
  void deleteFunction() {
    isDelete = true;
    isMultipleValveMode = false;
    isSingleValveMode = false;
    isNext = false;
    notifyListeners();
  }

  void enableSkipNex() {
    isDelete = false;
    isMultipleValveMode = true;
    isSingleValveMode = false;
    isNext = true;
    notifyListeners();
  }

  void deleteButton() {
    _irrigationLine!.sequence.clear();
    notifyListeners();
  }

  bool isSelected(valveIndex, titleIndex, isGroup, bigScreen, valve) {
    // print(isGroup ? "Group   == >>> $valve" : "Valve ==== >>> $valve");
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';

    return bigScreen
        ? _irrigationLine!.sequence.any((list) => list['valve']!.any((v) => v['name'] == valve))
        : _irrigationLine!.sequence.any((list) => list['selected']!.contains(valueToShow))
        || _irrigationLine!.sequence.any((list) => list['valve']!.any((v) => v['name'] == valve));
  }


  //TODO: SCHEDULE SCREEN PROVIDERS
  SampleScheduleModel? _sampleScheduleModel;
  SampleScheduleModel? get sampleScheduleModel => _sampleScheduleModel;

  Future<void> scheduleData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSchedule = await httpService.postRequest('getUserProgramSchedule', userData);
      if(getUserProgramSchedule.statusCode == 200) {
        final responseJson = getUserProgramSchedule.body;
        final convertedJson = jsonDecode(responseJson);
        if(convertedJson['data']['schedule'].isEmpty) {
          convertedJson['data']['schedule'] = {
            "scheduleAsRunList" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "noOfDays": "00", "startDate": DateTime.now().toString(), "type" : [] },
            },
            "scheduleByDays" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "startDate": DateTime.now().toString(), "runDays": "0", "skipDays": "0" }
            },
            "selected" : "NO SCHEDULE",
          };
        }
        _sampleScheduleModel = SampleScheduleModel.fromJson(convertedJson);
      }else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }

    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  String convertTo12HourFormat(String time24Hour) {
    List<String> timeComponents = time24Hour.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    String period = (hour >= 12) ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');

    return time24Hour != "00:00" ? '$formattedHour:$formattedMinute $period': "00:00";
  }

  String convertTo24HourFormat(String time12Hour) {
    List<String> components = time12Hour.split(' ');
    String timePart = components[0];
    String period = components[1];

    List<String> timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute:00';
  }

  void updateRtcProperty(newTime, selectedRtc, property, scheduleType) {
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList){
      final selectedRtcKey = sampleScheduleModel!.scheduleAsRunList.rtc.keys.toList()[selectedRtcIndex1];
      sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey][property] = (property != "interval" && property != "condition")
          ? convertTo24HourFormat(newTime) : newTime;
    } else {
      final selectedRtcKey = sampleScheduleModel!.scheduleByDays.rtc.keys.toList()[selectedRtcIndex2];
      sampleScheduleModel!.scheduleByDays.rtc[selectedRtcKey][property] = (property != "interval" && property != "condition")
          ? convertTo24HourFormat(newTime) : newTime;
      // print(sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey]['onTime']);
    }
    notifyListeners();
  }

  void updateStartDate(newDate, scheduleType) {
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList) {
      sampleScheduleModel!.scheduleAsRunList.schedule['startDate'] = newDate.toString();
    } else if(scheduleType == sampleScheduleModel!.scheduleByDays) {
      sampleScheduleModel!.scheduleByDays.schedule = {
        "startDate": newDate.toString(),
        "runDays": sampleScheduleModel!.scheduleByDays.schedule['runDays'],
        "skipDays": sampleScheduleModel!.scheduleByDays.schedule['skipDays']
      };
    }
    notifyListeners();
  }

  void updateNumberOfDays(newNumberOfDays, daysType, scheduleType) {
    scheduleType.schedule[daysType] = newNumberOfDays;
    notifyListeners();
  }

  List<String> scheduleTypes = ['NO SCHEDULE', 'SCHEDULE AS RUN LIST', 'SCHEDULE BY DAYS'];

  String? get selectedScheduleType => sampleScheduleModel?.selected ?? "NO SCHEDULE";

  void updateSelectedValue(newValue) {
    sampleScheduleModel!.selected = newValue;
    notifyListeners();
  }

  int _selectedRtcIndex1 = 0;

  int get selectedRtcIndex1 => _selectedRtcIndex1;

  void updateRtcIndex1(int newIndex) {
    _selectedRtcIndex1 = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  int _selectedRtcIndex2 = 0;

  int get selectedRtcIndex2 => _selectedRtcIndex2;

  void updateRtcIndex2(int newIndex) {
    _selectedRtcIndex2 = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  List<String> scheduleOptions = ['DO NOTHING', 'DO ONE TIME', 'DO WATERING', 'DO FERTIGATION'];

  void initializeDropdownValues(numberOfDays, existingDays, type) {
    if (sampleScheduleModel!.scheduleAsRunList.schedule['type'].isEmpty || int.parse(existingDays) == 0) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'] = List.generate(int.parse(numberOfDays), (index) => 'DO NOTHING');
    } else {
      if (int.parse(numberOfDays) != int.parse(existingDays)) {
        if (int.parse(numberOfDays) < int.parse(existingDays)) {
          for (var i = 0; i < int.parse(existingDays); i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = type[i];
          }
        } else {
          var newDays = int.parse(numberOfDays) - int.parse(existingDays);
          for (var i = 0; i < newDays; i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'].add('DO NOTHING');
          }
        }
      }
    }
    notifyListeners();
  }

  void updateDropdownValue(index, newValue) {
    if (index >= 0 && index < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'][index] = newValue;
      notifyListeners();
    }
  }

  int selectedButtonIndex = -1;
  void setAllSame(index) {
    bool allSame = true;
    switch(index) {
      case 0:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[0];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[0]) {
            allSame = false;
          }
        }
        break;
      case 1:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[1];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[1]) {
            allSame = false;
          }
        }
        break;
      case 2:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[2];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[2]) {
            allSame = false;
          }
        }
        break;
      case 3:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[3];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[3]) {
            allSame = false;
          }
        }
        break;
    }
    if (allSame) {
      selectedButtonIndex = index;
    }
    notifyListeners();
  }

  String? errorText;

  void validateInputAndSetErrorText(input, runListLimit) {
    if (input.isEmpty) {
      errorText = 'Please enter a value';
    } else {
      int? parsedValue = int.tryParse(input);
      if (parsedValue == null) {
        errorText = 'Please enter a valid number';
      } else if (parsedValue > (runListLimit)) {
        errorText = 'Value should not exceed $runListLimit';
      } else {
        errorText = null;
      }
    }
    notifyListeners();
  }

  //TODO: CONDITIONS PROVIDER
  SampleConditions? _sampleConditions;
  SampleConditions? get sampleConditions => _sampleConditions;
  bool conditionsLibraryIsNotEmpty = false;
  Future<void> getUserProgramCondition(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramCondition = await httpService.postRequest('getUserProgramCondition', userData);
      if(getUserProgramCondition.statusCode == 200) {
        final responseJson = getUserProgramCondition.body;
        final convertedJson = jsonDecode(responseJson);
        _sampleConditions = SampleConditions.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateConditionType(newValue, conditionTypeIndex) {
    _sampleConditions!.condition[conditionTypeIndex].selected = newValue;
    notifyListeners();
  }

  void updateConditions(title, sNo, newValue, conditionTypeIndex) {
    // print('$title, $sNo, $newValue, $conditionTypeIndex');
    _sampleConditions!.condition[conditionTypeIndex].value = {
      "sNo": sNo,
      "name" : newValue
    };
    notifyListeners();
  }

  //TODO: WATER AND FERT PROVIDER
  int sequenceSno = 0;
  List<dynamic> sequenceData = [];
  List<dynamic> serverDataWM = [];
  List<dynamic> channelData = [];
  int selectedGroup = 0;
  int selectedCentralSite = 0;
  int selectedLocalSite = 0;
  int selectedInjector = 0;
  List<dynamic> sequence = [];
  String radio = 'set individual';
  dynamic apiData = {};
  dynamic recipe = [];
  dynamic constantSetting = {};
  dynamic fertilizerSet = [];
  int segmentedControlGroupValue = 0;
  int segmentedControlCentralLocal = 0;
  TextEditingController waterQuantity = TextEditingController();
  TextEditingController preValue = TextEditingController();
  TextEditingController postValue = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController ph = TextEditingController();
  TextEditingController channel = TextEditingController();
  TextEditingController injectorValue = TextEditingController();
  ScrollController scrollControllerGroup = ScrollController();
  ScrollController scrollControllerSite = ScrollController();
  ScrollController scrollControllerInjector = ScrollController();

  Map<int, Widget> myTabs = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Water",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Fert",style: TextStyle(color: Colors.white)),
    ),
  };
  Map<int, Widget> cOrL = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Central",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Local",style: TextStyle(color: Colors.black)),
    ),
  };

  void clearWaterFert(){
    sequenceSno = 0;
    sequenceData = [];
    serverDataWM = [];
    channelData = [];
    selectedGroup = 0;
    selectedCentralSite = 0;
    selectedLocalSite = 0;
    selectedInjector = 0;
    sequence = [];
    radio = 'set individual';
    apiData = {};
    recipe = [];
    constantSetting = {};
    fertilizerSet = [];
    segmentedControlGroupValue = 0;
    segmentedControlCentralLocal = 0;
    // waterQuantity = TextEditingController();
    // preValue = TextEditingController();
    // postValue = TextEditingController();
    // ec = TextEditingController();
    // ph = TextEditingController();
    // injectorValue = TextEditingController();
    // scrollControllerGroup = ScrollController();
    // scrollControllerSite = ScrollController();
    // scrollControllerInjector = ScrollController();
    notifyListeners();
  }

  editFertilizerSet(dynamic data){
    fertilizerSet = data;
    notifyListeners();
  }

  void editSegmentedControlGroupValue(int value){
    segmentedControlGroupValue = value;
    myTabs = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Water",style: TextStyle(color: segmentedControlGroupValue == 0 ? Colors.white : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Fert",style: TextStyle(color: segmentedControlGroupValue == 1 ? Colors.white : Colors.black)),
      ),
    };
    notifyListeners();
  }
  void editSegmentedCentralLocal(int value){
    segmentedControlCentralLocal = value;
    selectedCentralSite = 0;
    selectedLocalSite = 0;
    selectedInjector = 0;
    // print('first');
    if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0){
      ec.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['ecValue'].toString() ?? '';
      ph.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['phValue'].toString() ?? '';
      injectorValue.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'].toString() ?? '';
    }
    cOrL = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Central",style: TextStyle(color: segmentedControlCentralLocal == 0 ? Colors.white : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Local",style: TextStyle(color: segmentedControlCentralLocal == 1 ? Colors.white : Colors.black)),
      ),
    };
    notifyListeners();
  }
  var waterAndFertData = [];

  void selectingTheSite(){
    if(sequenceData.isNotEmpty){
      segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] == -1 ? 0 : sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'];
      editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] == -1 ? 0 : sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']);
    }
    notifyListeners();
  }

  void editApiData(dynamic value){
    // print('api data is : ${value}');
    apiData = value;
    notifyListeners();
  }
  void editSequenceData(dynamic value){
    sequenceData = value;
    notifyListeners();
  }
  void editRecipe(dynamic value){
    if(value != null){
      recipe = value;
    }
    notifyListeners();
  }
  void editConstantSetting(dynamic value){
    constantSetting = value;
    notifyListeners();
  }
  dynamic returnSequenceDataUpdate({required central,required local,required i,required sequence}){
    var centralDuplicate = [];
    for(var i in central){
      // print(i.keys);
      var line = [];
      var fert = [];
      var ec = [];
      var ph = [];
      for(var l in i['irrigationLine']){
        line.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      for(var l in i['fertilizer']){
        fert.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      if(i['ecSensor'].isNotEmpty){
        for(var l in i['ecSensor']){
          ec.add({
            'sNo' : l['sNo'],
            'id' : l['id'],
            'name' : l['name'],
            'location' : l['location'],
          });
        }
      }
      for(var l in i['phSensor']){
        ph.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      centralDuplicate.add({
        'sNo' : i['sNo'],
        'id' : i['id'],
        'name' : i['name'],
        'location' : i['location'],
        'irrigationLine' : line,
        'fertilizer' : fert,
        'ecSensor' : ec,
        'phSensor' : ph,
      });
    }
    var localDuplicate = [];
    for(var i in local){
      // print(i.keys);
      var fert = [];
      var ec = [];
      var ph = [];

      for(var l in i['fertilizer']){
        fert.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      if(i['ecSensor'].isNotEmpty){
        for(var l in i['ecSensor']){
          ec.add({
            'sNo' : l['sNo'],
            'id' : l['id'],
            'name' : l['name'],
            'location' : l['location'],
          });
        }
      }
      for(var l in i['phSensor']){
        ph.add({
          'sNo' : l['sNo'],
          'id' : l['id'],
          'name' : l['name'],
          'location' : l['location'],
        });
      }
      localDuplicate.add({
        'sNo' : i['sNo'],
        'id' : i['id'],
        'name' : i['name'],
        'location' : i['location'],
        'fertilizer' : fert,
        'ecSensor' : ec,
        'phSensor' : ph,
      });
    }
    var generateNew = [];
    var myCentral = [];
    var myLocal = [];
    var valList = [];
    for(var vl in sequence[0]['valve']){
      if(!valList.contains(vl['location'])){
        valList.add(vl['location']);
      }
    }
    // this process is to find the central site for the sequence
    for(var cd in centralDuplicate){
      line : for(var il in cd['irrigationLine']){
        if(valList.contains(il['id'])){
          var createSite = {
            'sNo' : cd['sNo'],
            'name' : cd['name'],
            'id' : cd['id'],
            'location' : cd['location'],
            'recipe' : -1,
            'applyRecipe' : false,
          };
          var fertilizer = [];
          for(var fert in cd['fertilizer']){
            fert['method'] = 'Time';
            fert['timeValue'] = '00:00:00';
            fert['quantityValue'] = '';
            fert['onOff'] = false;
            fertilizer.add(fert);
          }
          if(cd['ecSensor'].length != 0){
            createSite['ecValue'] = 0;
            createSite['needEcValue'] = false;
          }
          if(cd['phSensor'].length != 0){
            createSite['phValue'] = 0;
            createSite['needPhValue'] = false;
          }
          createSite['fertilizer'] = fertilizer;
          myCentral.add(createSite);
          break line;
        }
      }
    }
    // process end for central
    // this process is to find the Local site for the sequence
    for(var ld in localDuplicate){
      if(valList.contains(ld['id'])){
        var createSite = {
          'sNo' : ld['sNo'],
          'name' : ld['name'],
          'id' : ld['id'],
          'location' : ld['location'],
          'recipe' : -1,
          'applyRecipe' : false,
        };
        var fertilizer = [];
        for(var fert in ld['fertilizer']){
          fert['method'] = 'Time';
          fert['timeValue'] = '00:00:00';
          fert['quantityValue'] = '';
          fert['onOff'] = false;
          fertilizer.add(fert);
        }
        if(ld['ecSensor'].length != 0){
          createSite['ecValue'] = 0;
          createSite['needEcValue'] = false;
        }
        if(ld['phSensor'].length != 0){
          createSite['phValue'] = 0;
          createSite['needPhValue'] = false;
        }
        createSite['fertilizer'] = fertilizer;
        myLocal.add(createSite);
      }
    }
    // process end for local
    generateNew.add({
      'sNo' : sequence[0]['sNo'],
      'valve' : sequence[0]['valve'],
      'name' : giveNameForSequence(sequence[0]),
      'moistureCondition' : '-',
      'moistureSno' : 0,
      'levelCondition' : '-',
      'levelSno' : 0,
      'prePostMethod' : 'Time',
      'preValue' : '00:00:00',
      'postValue' : '00:00:00',
      'method' : 'Time',
      'timeValue' : '00:00:00',
      'quantityValue' : '0',
      'centralDosing' : myCentral,
      'localDosing' : myLocal,
      'applyFertilizerForCentral' : false,
      'applyFertilizerForLocal' : false,
      'selectedCentralSite' : 0,
      'selectedLocalSite' : 0,
    });
    return generateNew;
  }
  bool isSiteVisible(data,localOrCentral){
    var checkList = [];
    for(var i in data){
      checkList.add(i['sNo']);
    }
    bool CentralpgmMode = false;
    bool LocalpgmMode = false;
    bool visible = false;
    if(localOrCentral == 'central'){
      for(var pm in selectionModel.data!.centralFertilizerSite!){
        if(pm.selected == true){
          CentralpgmMode = true;
        }
      }
    }
    if(localOrCentral == 'local'){
      for(var pm in selectionModel.data!.localFertilizerSite!){
        if(pm.selected == true){
          LocalpgmMode = true;
        }
      }
    }
    if(localOrCentral == 'central'){
      if(CentralpgmMode == true){
        for(var slt in selectionModel.data!.centralFertilizerSite!){
          // print('slt.selected : ${slt.selected}');
          // print('slt.sNo : ${slt.sNo}');
          if(slt.selected == true){
            if(checkList.contains(slt.sNo)){
              visible = true;
            }
          }
        }

      }
    }
    if(localOrCentral == 'local'){
      if(LocalpgmMode == true){
        for(var slt in selectionModel.data!.localFertilizerSite!){
          if(slt.selected == true){
            if(checkList.contains(slt.sNo)){
              visible = true;
            }
          }
        }
      }
    }
    return ((localOrCentral == 'central' ? CentralpgmMode : LocalpgmMode) == true) ? visible : true;
  }

  dynamic deepCopy(dynamic originalList) {
    dynamic copiedList = [];
    if(originalList.isNotEmpty){
      for (var map in originalList) {
        copiedList.add(Map.from({
          "sNo": map['sNo'],
          "id": map['id'],
          "name": map['name'],
          "location": map['location'],
          "valve": List.from(map['valve']),
          "selected": List.from(map['selected'])
        }));
      }
    }

    return copiedList;
  }
  void waterAndFert(){
    final valSeqList = deepCopy(_irrigationLine!.sequence);
    var givenSeq = [];
    var myOldSeq = [];
    if(valSeqList.isNotEmpty){
      for(var i in valSeqList){
        givenSeq.add(i['sNo']);
      }
    }
    if(sequenceData.isNotEmpty){
      for(var i in sequenceData){
        myOldSeq.add(i['sNo']);
      }
    }
    var generateNew = [];
    var central = [];
    var local = [];
    for(var site in apiData['fertilization']){
      if(site['id'].contains('CFESI')){
        central.add(site);
      }else{
        local.add(site);
      }
    }
    for(var i = 0;i < valSeqList.length;i++){
      var seqList = [];
      bool newData = false;
      if(myOldSeq.isNotEmpty){
        add : for(var j = 0;j < myOldSeq.length;j++){
          if(myOldSeq.contains(valSeqList[i]['sNo'])){
            if(valSeqList[i]['sNo'] == myOldSeq[j]){
              if(valSeqList[i]['valve'].length == sequenceData[j]['valve'].length){
                for(var lst in sequenceData[j]['valve']){
                  seqList.add(lst['sNo']);
                }
                checkValve : for(var checkVal in valSeqList[i]['valve']){
                  if(!seqList.contains(checkVal['sNo'])){
                    newData = true;
                    break checkValve;
                  }else{
                    newData = false;
                  }
                }
                if(newData == true){
                  generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]]));
                  break add;
                }else{
                  generateNew.add(sequenceData[j]);
                  break add;
                }
              }else{
                generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]]));
              }
            }
          }else{
            generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]]));
            break add;
          }
        }
      }else{
        generateNew.addAll(returnSequenceDataUpdate(central: central, local: local, i: i,sequence: [valSeqList[i]]));
      }
    }

    sequenceData = generateNew;
    for(var i in sequenceData){
      for(var cd in i['centralDosing']){
        for(var slt in _selectionModel.data!.centralFertilizerSite!){
          if(slt.selected == true){
            if(cd['sNo'] == slt.sNo){
              i['selectedCentralSite'] = i['centralDosing'].indexOf(cd);
            }
          }
        }
      }
      for(var ld in i['localDosing']){
        for(var slt in _selectionModel.data!.localFertilizerSite!){
          if(slt.selected == true){
            if(ld['sNo'] == slt.sNo){
              i['selectedLocalSite'] = i['localDosing'].indexOf(ld);
            }
          }
        }
      }
    }
    if(sequenceData.isNotEmpty){
      waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
      preValue.text = sequenceData[selectedGroup]['preValue'] ?? '';
      postValue.text = sequenceData[selectedGroup]['postValue'] ?? '';
      ec.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['ecValue'].toString() ?? '';
      ph.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['phValue'].toString() ?? '';
    }

    // print('after seq : ${sequenceData}');
    notifyListeners();
  }

  String fertMethodHw(String value){
    switch (value){
      case ('Time'):{
        return '1';
      }
      case ('Pro.time'):{
        return '1';
      }
      case ('Quantity'):{
        return '2';
      }
      case ('Pro.quantity'):{
        return '2';
      }
      default : {
        return '0';
      }
    }
  }

  dynamic hwPayloadForWF(){
    var wf = '';
    for(var sq in sequenceData){
      var valId = '';
      for(var vl in sq['valve']){
        valId += '${valId.length != 0 ? ',' : ''}${vl['id']}';
      }
      var centralMethod = '';
      var centralTimeAndQuantity = '';
      var centralFertOnOff = '';
      var centralEcActive = 0;
      var centralEcValue = '';
      var centralPhActive = 0;
      var centralPhValue = '';
      var localMethod = '';
      var localTimeAndQuantity = '';
      var localFertOnOff = '';
      var localEcActive = 0;
      var localEcValue = '';
      var localPhActive = 0;
      var localPhValue = '';
      var centralEC = '';
      var centralPH = '';
      var localEC = '';
      var localPH = '';
      // print('c1 : ${isSiteVisible(sq['centralDosing'],'central')}');
      // print('c2 : ${sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false}');
      // print('c3 : ${sq['centralDosing'].isEmpty}');
      // print('c4 : ${sq['selectedCentralSite'] == -1}');
      if(!isSiteVisible(sq['centralDosing'],'central') || sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false || sq['centralDosing'].isEmpty || sq['selectedCentralSite'] == -1){
        centralMethod = '0_0_0_0_0_0_0_0';
        centralTimeAndQuantity += '0_0_0_0_0_0_0_0';
        centralFertOnOff += '0_0_0_0_0_0_0_0';
        centralEcActive = 0;
        centralEcValue = '';
        centralPhActive = 0;
        centralPhValue = '';
      }else{
        var fertList = [];
        for(var ft in sq['centralDosing'][sq['selectedCentralSite']]['fertilizer']){
          centralMethod += '${centralMethod.isNotEmpty ? '_' : ''}${fertMethodHw(ft['method'])}';
          centralFertOnOff += '${centralFertOnOff.isNotEmpty ? '_' : ''}${ft['onOff'] == true ? 1 : 0}';
          centralTimeAndQuantity += '${centralTimeAndQuantity.isNotEmpty ? '_' : ''}${ft['method'].contains('ime') ? ft['timeValue'] : ft['quantityValue']}';
          centralEcActive = sq['centralDosing'][sq['selectedCentralSite']]['needEcValue'] == null ? 0 : sq['centralDosing'][sq['selectedCentralSite']]['needEcValue'] == true ? 1 : 0;
          centralEcValue = '${sq['centralDosing'][sq['selectedCentralSite']]['ecValue'] ?? 0}';
          centralPhActive = sq['centralDosing'][sq['selectedCentralSite']]['needPhValue'] == null ? 0 : sq['centralDosing'][sq['selectedCentralSite']]['needPhValue'] == true ? 1 : 0;
          centralPhValue = '${sq['centralDosing'][sq['selectedCentralSite']]['phValue'] ?? 0}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          centralMethod += '${centralMethod.length != 0 ? '_' : ''}0';
          centralTimeAndQuantity += '${centralTimeAndQuantity.length != 0 ? '_' : ''}0';
          centralFertOnOff += '${centralFertOnOff.length != 0 ? '_' : ''}0';
        }
      }

      if(!isSiteVisible(sq['localDosing'],'local') || sq[segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] == false || sq['localDosing'].isEmpty || sq['selectedLocalSite'] == -1){
        localMethod = '0_0_0_0_0_0_0_0';
        localTimeAndQuantity += '0_0_0_0_0_0_0_0';
        localFertOnOff += '0_0_0_0_0_0_0_0';
        localEcActive = 0;
        localEcValue = '';
        localPhActive = 0;
        localPhValue = '';
      }else{
        var fertList = [];
        for(var ft in sq['localDosing'][sq['selectedLocalSite']]['fertilizer']){
          localMethod += '${localMethod.isNotEmpty ? '_' : ''}${fertMethodHw(ft['method'])}';
          localFertOnOff += '${localFertOnOff.isNotEmpty ? '_' : ''}${ft['onOff'] == true ? 1 : 0}';
          localTimeAndQuantity += '${localTimeAndQuantity.isNotEmpty ? '_' : ''}${ft['method'].contains('ime') ? ft['timeValue'] : ft['quantityValue']}';
          localEcActive = sq['localDosing'][sq['selectedLocalSite']]['needEcValue'] == null ? 0 : sq['localDosing'][sq['selectedLocalSite']]['needEcValue'] == true ? 1 : 0;
          localEcValue = '${sq['localDosing'][sq['selectedLocalSite']]['ecValue'] ?? 0}';
          localPhActive = sq['localDosing'][sq['selectedLocalSite']]['needPhValue'] == null ? 0 : sq['localDosing'][sq['selectedLocalSite']]['needPhValue'] == true ? 1 : 0;
          localPhValue = '${sq['localDosing'][sq['selectedLocalSite']]['phValue'] ?? 0}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          localMethod += '${localMethod.length != 0 ? '_' : ''}0';
          localTimeAndQuantity += '${localTimeAndQuantity.length != 0 ? '_' : ''}0';
          localFertOnOff += '${localFertOnOff.length != 0 ? '_' : ''}0';
        }
      }
      wf += '${wf.length != 0 ? ';' : ''}'
          '${sq['sNo']},${0},${sq['name']},'
          '${valId},,${10000},${sq['method'] == 'Time' ? 1 : 2},'
          '${sq['method'] == 'Time' ? sq['timeValue'] : sq['quantityValue']},'
          '${sq['applyFertilizerForCentral'] == false ? 0 : sq['selectedCentralSite'] == -1 ? 0 : 1},'
          '${sq['applyFertilizerForLocal'] == false ? 0 : sq['selectedLocalSite'] == -1 ? 0 : 1},'
          '${sq['prePostMethod'] == 'Time' ? 0 : 1},'
          '${sq['preValue']},'
          '${sq['postValue']},'
          '${centralMethod},'
          '${localMethod},'
          '${centralFertOnOff},'
          '${localFertOnOff},'
          '${centralTimeAndQuantity},'
          '${localTimeAndQuantity},'
          '${centralEcActive},'
          '${centralEcValue},'
          '${localEcActive},'
          '${localEcValue},'
          '${centralPhActive},'
          '${centralPhValue},'
          '${localPhActive},'
          '${localPhValue},'
          '${localPhValue},'
          '${sq['moistureSno']},'
          '${sq['levelSno']}';

    }
    // print('water and fert : ${wf}');
    return wf;
    // for(var i in wf.split(';')){
    //   for(var j = 0;j < i.split(',').length;j++){
    //     print('${wfPld(j)} =====  ${i.split(',')[j]}');
    //   }
    //   // print('');
    //   // print('');
    // }
  }

  String wfPld(int index){
    switch (index){
      case (0):{
        return 'S_No';
      }
      case (1):{
        return 'program sno';
      }
      case (2):{
        return 'seq name';
      }
      case (3):{
        return 'seq id';
      }
      case (4):{
        return 'pump';
      }
      case (5):{
        return 'valve flowrate';
      }
      case (6):{
        return 'irri method';
      }
      case (7):{
        return 'irr duration or quantity';
      }
      case (8):{
        return 'central fert on-off';
      }
      case (9):{
        return 'local fert on-off';
      }
      case (10):{
        return 'pre post method';
      }
      case (11):{
        return 'pre time or quantity';
      }
      case (12):{
        return 'post time or quantity';
      }
      case (13):{
        return 'central method';
      }
      case (14):{
        return 'local method';
      }
      case (15):{
        return 'central channel on off';
      }
      case (16):{
        return 'local channel on off';
      }
      case (17):{
        return 'central channel method';
      }
      case (18):{
        return 'local channel method';
      }
      case (19):{
        return 'central ec on-off';
      }
      case (20):{
        return 'central ec value';
      }
      case (20):{
        return 'local ec on-off';
      }
      case (22):{
        return 'local ec value';
      }
      case (23):{
        return 'central ph on-off';
      }
      case (24):{
        return 'central ph value';
      }
      case (25):{
        return 'local ph on-off';
      }
      case (26):{
        return 'local ph value';
      }
      case (27):{
        return 'condition';
      }
      case (28):{
        return 'immediate on-off';
      }
      default:{
        return 'nothing';
      }
    }
  }

  void editWaterSetting(String title, String value){
    if(title == 'method'){
      sequenceData[selectedGroup]['method'] = value;
    }else if(title == 'timeValue'){
      sequenceData[selectedGroup]['timeValue'] = value;
    }else if(title == 'quantityValue'){
      sequenceData[selectedGroup]['quantityValue'] = value;
    }
    notifyListeners();
  }
  //TODO : edit ec ph in central and local
  void editGroupSiteInjector(String title,dynamic value){
    switch(title){
      case ('applyFertilizer'):{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'] = value;
        break;
      }
      case ('selectedGroup'):{
        selectedGroup = value;
        waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
        break;
      }
      case ('selectedCentralSite'):{
        selectedCentralSite = value;
        if(sequenceData[selectedGroup]['centralDosing'].length != 0){
          sequenceData[selectedGroup]['selectedCentralSite'] = sequenceData[selectedGroup]['selectedCentralSite'] = value;
          ec.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          injectorValue.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['fertilizer'][selectedInjector]['quantityValue'];
        }
        // print('--------------${jsonEncode(sequenceData[selectedGroup])}');
        break;
      }
      case ('selectedLocalSite'):{
        selectedLocalSite = value;
        if( sequenceData[selectedGroup]['localDosing'].length != 0){
          sequenceData[selectedGroup]['selectedLocalSite'] = sequenceData[selectedGroup]['selectedLocalSite'] =value;
          ec.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          injectorValue.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] ?? '';
        }
        break;
      }
      case ('selectedInjector'):{
        selectedInjector = value;
        injectorValue.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] ?? '';

        break;
      }
      case ('selectedRecipe') : {
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] = value;
        if(value != -1){
          for(var i in recipe){
            if(i['sNo'] == sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['sNo']){
              if(i['recipe'][value]['ecActive'] != null && i['recipe'][value]['Ec'] != null){
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] = i['recipe'][value]['ecActive'];
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['ecValue'] = i['recipe'][value]['Ec'];
                ec.text = i['recipe'][value]['Ec'];
              }
              if(i['recipe'][value]['phActive'] != null && i['recipe'][value]['Ph'] != null){
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] = i['recipe'][value]['phActive'];
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['phValue'] = i['recipe'][value]['Ph'];
                ph.text = i['recipe'][value]['Ph'];
              }
              for(var inj = 0;inj < i['recipe'][value]['fertilizer'].length;inj++){
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][inj]['onOff'] = i['recipe'][value]['fertilizer'][inj]['active'];
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][inj]['method'] = i['recipe'][value]['fertilizer'][inj]['method'];
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][inj]['timeValue'] = i['recipe'][value]['fertilizer'][inj]['timeValue'];
                sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][inj]['quantityValue'] = i['recipe'][value]['fertilizer'][inj]['quantityValue'];
                injectorValue.text = i['recipe'][value]['fertilizer'][inj]['quantityValue'];
              }

            }
          }
        }

      }
      break;
      case ('applyRecipe') : {
        // print('value : $value');
        if(value == false){
          for(var i in sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing']){
            i['recipe'] = -1;
          }
        }
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['applyRecipe'] = value;
      }
      break;
      case ('applyMoisture') : {
        sequenceData[selectedGroup]['moistureCondition'] = value['name'];
        sequenceData[selectedGroup]['moistureSno'] = value['sNo'];
      }
      break;
      case ('applyLevel') : {
        sequenceData[selectedGroup]['levelCondition'] = value['name'];
        sequenceData[selectedGroup]['levelSno'] = value['sNo'];
      }
    }
    notifyListeners();
  }
  void editNext(){
    if(segmentedControlGroupValue == 1){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'].length - 1 != selectedInjector){
        editGroupSiteInjector('selectedInjector',selectedInjector + 1);
      }
      // else if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length - 1 != (segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite)){
      //   editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) + 1);
      // }
      else if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
        // editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',0);
        editGroupSiteInjector('selectedInjector', 0);
      }
    }else{
      if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
      }
    }

    notifyListeners();
  }
  void editBack(){
    if(segmentedControlGroupValue == 1){
      if(selectedInjector != 0){
        editGroupSiteInjector('selectedInjector',selectedInjector - 1);
      }
      // else if((segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) != 0){
      //   editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) - 1);
      // }
      else if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length -1);
        editGroupSiteInjector('selectedInjector', sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'].length -1);
      }
    }else{
      if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
      }
    }
    notifyListeners();
  }

  void editEcPhNeedOrNot(String title){
    if(title == 'ec'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] = true;
      }
    }else if(title == 'ph'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] = true;
      }    }
    notifyListeners();
  }
  void editEcPh(String title,String ecOrPh, String value){
    if(title == 'centralDosing'){
      sequenceData[selectedGroup]['centralDosing'][selectedCentralSite][ecOrPh] = value;
    }else if(title == 'localDosing'){
      // print(value);
      sequenceData[selectedGroup]['localDosing'][selectedLocalSite][ecOrPh] = value;
    }
    notifyListeners();
  }

  int waterValueInSec(){
    int sec = 0;
    if(sequenceData[selectedGroup]['method'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['timeValue'].split(':');
      sec = (int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]));
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        // print('constantSetting : ${constantSetting}');
        for(var i = 0;i < constantSetting['valve'].length;i++){
          // print('came');
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }

          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['quantityValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['quantityValue'] != '' ? int.parse(sequenceData[selectedGroup]['quantityValue']) : 0)/valveFlowRate).round();
      }
    }
    // print('water finished');
    return sec;
  }
  double preValueInSec(){
    double sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['preValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]).toDouble();
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }
      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      // print('nominalFlowRate : $nominalFlowRate');
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['preValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['preValue'] != '' ? int.parse(sequenceData[selectedGroup]['preValue']) : 0)/valveFlowRate);
      }
    }
    // print('pre in seconds : $sec');
    return sec;
  }
  double postValueInSec(){
    double sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['postValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]).toDouble();
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['postValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['postValue'] != '' ? int.parse(sequenceData[selectedGroup]['postValue']) : 0)/valveFlowRate);
      }
    }
    return sec;
  }
  double flowRate(){
    var nominalFlowRate = [];
    var sno = [];
    for(var val in sequenceData[selectedGroup]['valve']){
      // print('valve >>> ${val['sNo']}');
      for(var i = 0;i < constantSetting['valve'].length;i++){
        for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
          if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
            if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
              if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
              }
            }
          }
        }
      }

    }
    var totalFlowRate = 0;
    // print('nominalFlowRate : ${nominalFlowRate}');
    for(var flwRate in nominalFlowRate){
      totalFlowRate = totalFlowRate + int.parse(flwRate);
    }
    var valveFlowRate = totalFlowRate * 0.00027778;
    return valveFlowRate;
  }

  //TODO : edit pre post in fert segment
  void editPrePostMethod(String title,int index,String value){
    switch (title){
      case 'prePostMethod' :{
        if(value == 'Time'){
          sequenceData[index]['preValue'] = '00:00:00';
          sequenceData[index]['postValue'] = '00:00:00';
        }else{
          sequenceData[index]['preValue'] = '0';
          sequenceData[index]['postValue'] = '0';
          preValue.text = '0';
          postValue.text = '0';
        }
        sequenceData[index]['prePostMethod'] = value;
        break;
      }
      case 'preValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          // print('waterValueInSec() : ${waterValueInSec()}');
          // print('postValueInSec() : ${postValueInSec()}');
          var diff = waterValueInSec() - postValueInSec();
          // print('flowRate() : ${flowRate()}');
          var quantity = diff * flowRate();
          // print('pre diff : ${quantity.round()}');
          // print('pre diff1 : ${quantity}');

          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['preValue'] = '${quantity.toInt()}';
            preValue.text = '${quantity.toInt()}';
          }else{
            sequenceData[index]['preValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['preValue'] = value;
        }
        break;
      }
      case 'postValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          var diff = waterValueInSec() - preValueInSec();
          var quantity = diff * flowRate();
          // print('post diff : ${quantity}');
          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['postValue'] = '${quantity.toInt()}';
            postValue.text = '${quantity.toInt()}';
          }else{
            sequenceData[index]['postValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['postValue'] = value;
        }
        break;
      }

    }
    notifyListeners();
  }
  // void editSelectedSite(String centralOrLocal,dynamic value){
  //   if(centralOrLocal == 'centralDosing'){
  //     sequenceData[selectedGroup]['selectedCentralSite'] = sequenceData[selectedGroup]['selectedCentralSite'] == value ? -1 : value;
  //   }else{
  //     sequenceData[selectedGroup]['selectedLocalSite'] = sequenceData[selectedGroup]['selectedLocalSite'] == value ? -1 : value;
  //   }
  //   notifyListeners();
  // }

  void editOnOffInInjector(String centralOrLocal,int index,bool value){
    // print('sequenceData check1 : ${jsonEncode(sequenceData)}');
    sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index]['onOff'] = value;
    // print('sequenceData check2 : ${jsonEncode(sequenceData)}');
    notifyListeners();
  }

  void editParticularChannelDetails(String title,String centralOrLocal,dynamic value){
    switch(title){
      case ('method') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['method'] = value;
        break;
      }
      case ('quantityValue') : {
        var diff = waterValueInSec() - preValueInSec() - postValueInSec();
        var quantity = diff * flowRate();
        if(int.parse(value) >= quantity.toInt()){
          sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] = '${quantity.toInt()}';
          injectorValue.text = '${quantity.toInt()}';
        }else{
          sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] = (value == '' ? '0' : value);
        }
        break;
      }
      case ('timeValue') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['timeValue'] = value;
        break;
      }
    }
    notifyListeners();
  }

  String giveNameForSequence(dynamic data){
    var name = '';
    for(var i in data['selected']){
      name += '${name.length != 0 ? '&' : ''}$i';
    }
    return name;
  }


  void dataToWF() {
    serverDataWM = sequenceData;
    notifyListeners();
  }

  //TODO: SELECTION PROVIDER
  SelectionModel _selectionModel = SelectionModel();
  SelectionModel get selectionModel => _selectionModel;

  void updateSelectionModel(SelectionModel newSelectionModel) {
    _selectionModel = newSelectionModel;
    notifyListeners();
  }
  List<String> filtrationModes = ['TIME', 'DP', 'BOTH'];
  String get selectedCentralFiltrationMode => _selectionModel.data?.additionalData?.centralFiltrationOperationMode ?? "TIME";
  String get selectedLocalFiltrationMode => _selectionModel.data?.additionalData?.localFiltrationOperationMode ?? "TIME";

  void updateFiltrationMode(newValue, bool isCentral) {
    if(isCentral) {
      _selectionModel.data?.additionalData?.centralFiltrationOperationMode = newValue;
    } else {
      _selectionModel.data?.additionalData?.localFiltrationOperationMode = newValue;
    }
    notifyListeners();
  }

  bool get isPumpStationMode => _selectionModel.data?.additionalData?.pumpStationMode ?? false;
  bool get isProgramBasedSet => _selectionModel.data?.additionalData?.programBasedSet ?? false;
  bool get isProgramBasedInjector => _selectionModel.data?.additionalData?.programBasedInjector ?? false;
  void updatePumpStationMode(newValue, title) {
    switch(title) {
      case "Pump Station Mode": _selectionModel.data?.additionalData?.pumpStationMode = newValue;
      break;
      case "Program based set selection": _selectionModel.data?.additionalData?.programBasedSet = newValue;
      break;
      case "Program based Injector selection": _selectionModel.data?.additionalData?.programBasedInjector = newValue;
      break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  bool get centralFiltBegin => _selectionModel.data?.additionalData?.centralFiltrationBeginningOnly ?? false;
  bool get localFiltBegin => _selectionModel.data?.additionalData?.localFiltrationBeginningOnly ?? false;
  void updateFiltBegin(newValue, isCentral) {
    if(isCentral) {
      _selectionModel.data?.additionalData?.centralFiltrationBeginningOnly = newValue;
    } else {
      _selectionModel.data?.additionalData?.localFiltrationBeginningOnly = newValue;
    }
    notifyListeners();
  }

  Future<void> getUserProgramSelection(int userId, int controllerId, int serialNumber) async {
    var userData = {
      "userId": userId,
      "controllerId": controllerId,
      "serialNumber": serialNumber
    };
    try {
      final response = await HttpService().postRequest("getUserProgramSelection", userData);
      final jsonData = json.decode(response.body);
      if (jsonData['data']['additionalData'] != null) {
        _selectionModel = SelectionModel.fromJson(jsonData);
        // print(_selectionModel.data!.centralFertilizerSet!.centralFertilizerSet.map((e) => e.name));
        // print(_selectionModel.data!.localFertilizerSet!.centralFertilizerSet.map((e) => e.name));
      } else {
        jsonData['data']['additionalData'] = {
          "centralFiltrationOperationMode": "TIME",
          "localFiltrationOperationMode": "TIME",
          "centralFiltrationBeginningOnly": false,
          "localFiltrationBeginningOnly": false,
          "pumpStationMode": false,
          "programBasedSet": false
        };
        _selectionModel = SelectionModel.fromJson(jsonData);
      }
    } catch (e) {
      log('Error: $e');
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateSelectedItem(title, id) {
    switch(title) {
      case 'EC Sensors For central':
        for (int i = 0; i < selectionModel.data!.ecSensor!.length; i++) {
          var site = selectionModel.data!.centralFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.ecSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.ecSensor![i].id == id) {
              selectionModel.data!.ecSensor![i].selected = !selectionModel.data!.ecSensor![i].selected!;
            } else {
              if(selectionModel.data!.ecSensor![i].location!.startsWith("CFESI")) {
                selectionModel.data!.ecSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.ecSensor![i].location!.startsWith("CFESI")) {
              selectionModel.data!.ecSensor![i].selected = false;
            }
          }
        }
        break;
      case 'EC Sensors For local':
        for (int i = 0; i < selectionModel.data!.ecSensor!.length; i++) {
          var site = selectionModel.data!.localFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.ecSensor![i].location, orElse: () => NameData());
          if (site.selected == true) {
            if (selectionModel.data!.ecSensor![i].id == id) {
              selectionModel.data!.ecSensor![i].selected = !selectionModel.data!.ecSensor![i].selected!;
            } else {
              if(selectionModel.data!.ecSensor![i].location!.startsWith("IL")) {
                selectionModel.data!.ecSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.ecSensor![i].location!.startsWith("IL")) {
              selectionModel.data!.ecSensor![i].selected = false;
            }
          }
        }
        break;
      case 'pH Sensors For central':
        for (int i = 0; i < selectionModel.data!.phSensor!.length; i++) {
          var site = selectionModel.data!.centralFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.phSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.phSensor![i].id == id) {
              selectionModel.data!.phSensor![i].selected = !selectionModel.data!.phSensor![i].selected!;
            } else {
              if(selectionModel.data!.phSensor![i].location!.startsWith("CFESI")) {
                selectionModel.data!.phSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.phSensor![i].location!.startsWith("CFESI")) {
              selectionModel.data!.phSensor![i].selected = false;
            }
          }
        }
        break;
      case 'pH Sensors For local':
        for (int i = 0; i < selectionModel.data!.phSensor!.length; i++) {
          var site = selectionModel.data!.localFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.phSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.phSensor![i].id == id) {
              selectionModel.data!.phSensor![i].selected = !selectionModel.data!.phSensor![i].selected!;
            } else {
              if(selectionModel.data!.phSensor![i].location!.startsWith("IL")) {
                selectionModel.data!.phSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.phSensor![i].location!.startsWith("IL")) {
              selectionModel.data!.phSensor![i].selected = false;
            }
          }
        }
        break;
      case 'Central Fertilizer Set':
        for (var fertilizerSet in selectionModel.data!.centralFertilizerSet!) {
          bool hasSelectedSite = selectionModel.data!.centralFertilizerSite!
              .any((site) => site.id == (fertilizerSet.recipe.isNotEmpty
              ? fertilizerSet.recipe.first.location
              : null) && site.selected == true);

          if (hasSelectedSite) {
            if (fertilizerSet.recipe.any((element) => element.selected == true)) {
              if(fertilizerSet.recipe.firstWhere((element) => element.selected == true).id == id){
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = false;
              } else {
                fertilizerSet.recipe.firstWhere((element) => element.selected == true).selected = false;
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
              }
            } else {
              fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
            }
          }
        }

        break;
      case 'Local Fertilizer Set':
        for (var fertilizerSet in selectionModel.data!.localFertilizerSet!) {
          bool hasSelectedSite = selectionModel.data!.localFertilizerSite!
              .any((site) => site.id == (fertilizerSet.recipe.isNotEmpty
              ? fertilizerSet.recipe.first.location
              : null) && site.selected == true);

          if (hasSelectedSite) {
            if (fertilizerSet.recipe.any((element) => element.selected == true)) {
              if(fertilizerSet.recipe.firstWhere((element) => element.selected == true).id == id){
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = false;
              } else {
                fertilizerSet.recipe.firstWhere((element) => element.selected == true).selected = false;
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
              }
            } else {
              fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
            }
          }
        }
        // selectionModel.data!.localFertilizerSet!.forEach((fertilizerSet) {
        //   bool hasSelectedSite = selectionModel.data!.localFertilizerSite!
        //       .any((site) => site.id == (fertilizerSet.recipe.isNotEmpty
        //       ? fertilizerSet.recipe.first.location
        //       : null) && site.selected == true);
        //
        //   if (hasSelectedSite) {
        //     for (var i = 0; i < fertilizerSet.recipe.length; i++) {
        //       if(fertilizerSet.recipe[i].id == id) {
        //         fertilizerSet.recipe[i].selected = !fertilizerSet.recipe[i].selected;
        //       }
        //     }
        //   }
        // });
        break;
      case 'Central Fertilizer Injector':
        if(selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)) {
          selectionModel.data!.centralFertilizerInjector!.firstWhere((element) => element.id == id).selected = !selectionModel.data!.centralFertilizerInjector!.firstWhere((element) => element.id == id).selected!;
        }
        break;
      case 'Local Fertilizer Injector':
        if(selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)) {
          selectionModel.data!.localFertilizerInjector!.firstWhere((element) => element.id == id).selected = !selectionModel.data!.localFertilizerInjector!.firstWhere((element) => element.id == id).selected!;
        }
        break;
      case 'Central Filter':
        if(selectionModel.data!.centralFilterSite!.any((element) => element.selected == true)) {
          selectionModel.data!.centralFilter!.firstWhere((element) => element.id == id).selected = !selectionModel.data!.centralFilter!.firstWhere((element) => element.id == id).selected!;
        }
        break;
      case 'Local Filter':
        if(selectionModel.data!.localFilterSite!.any((element) => element.selected == true)) {
          selectionModel.data!.localFilter!.firstWhere((element) => element.id == id).selected = !selectionModel.data!.localFilter!.firstWhere((element) => element.id == id).selected!;
        }
        break;
      default:
        log('Not match found');
    }
    notifyListeners();
  }

  void selectItem(int index, String title) {
    switch (title) {
      case 'List of Valves':
        selectionModel.data!.mainValve![index].selected = !selectionModel.data!.mainValve![index].selected!;
        break;
      case 'List of Pump':
        selectionModel.data!.irrigationPump![index].selected = !selectionModel.data!.irrigationPump![index].selected!;
        break;
      case 'Central Fertilizer Site':
        if(selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.centralFertilizerSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.centralFertilizerSite![oldIndex].selected = !selectionModel.data!.centralFertilizerSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.centralFertilizerSite![index].selected = false;
          } else{
            selectionModel.data!.centralFertilizerSite![index].selected = true;
          }
        } else {
          selectionModel.data!.centralFertilizerSite![index].selected = true;
        }
        break;
      case 'Central Fertilizer Injector':
        if(selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.centralFertilizerInjector!.indexWhere((element) => element.selected == true);
          selectionModel.data!.centralFertilizerInjector![oldIndex].selected = !selectionModel.data!.centralFertilizerInjector![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.centralFertilizerInjector![index].selected = false;
          } else{
            selectionModel.data!.centralFertilizerInjector![index].selected = true;
          }
        } else {
          selectionModel.data!.centralFertilizerInjector![index].selected = true;
        }
        // selectionModel.data!.centralFertilizerInjector![index].selected = !selectionModel.data!.centralFertilizerInjector![index].selected!;
        break;
      case 'Local Fertilizer Site':
        if(selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.localFertilizerSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.localFertilizerSite![oldIndex].selected = !selectionModel.data!.localFertilizerSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.localFertilizerSite![index].selected = false;
          } else{
            selectionModel.data!.localFertilizerSite![index].selected = true;
          }
        } else {
          selectionModel.data!.localFertilizerSite![index].selected = true;
        }
        break;
      case 'Local Fertilizer Injector':
        selectionModel.data!.localFertilizerInjector![index].selected = !selectionModel.data!.localFertilizerInjector![index].selected!;
        break;
      case 'Central Filter Site':
        if(selectionModel.data!.centralFilterSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.centralFilterSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.centralFilterSite![oldIndex].selected = !selectionModel.data!.centralFilterSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.centralFilterSite![index].selected = false;
          } else{
            selectionModel.data!.centralFilterSite![index].selected = true;
          }
        } else {
          selectionModel.data!.centralFilterSite![index].selected = true;
        }
        break;
      case 'Local Filter Site':
        if(selectionModel.data!.localFilterSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.localFilterSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.localFilterSite![oldIndex].selected = !selectionModel.data!.localFilterSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.localFilterSite![index].selected = false;
          } else{
            selectionModel.data!.localFilterSite![index].selected = true;
          }
        } else {
          selectionModel.data!.localFilterSite![index].selected = true;
        }
        break;
      case 'Selector for central fertilizer':
        if(selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)) {
          var selectedLocalSelectorIndices = selectionModel.data!.selectorForLocal!.asMap().entries
              .where((entry) => entry.value.selected == true)
              .map((entry) => entry.key)
              .toList();
          if(selectedLocalSelectorIndices.contains(index)) {
            selectionModel.data!.selectorForLocal![index].selected = false;
            selectionModel.data!.selectorForCentral![index].selected = true;
          } else {
            selectionModel.data!.selectorForCentral![index].selected = !selectionModel.data!.selectorForCentral![index].selected;
          }
        }
        break;
      case 'Selector for local fertilizer':
        if(selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)) {
          var selectedLocalSelectorIndices = selectionModel.data!.selectorForCentral!.asMap().entries
              .where((entry) => entry.value.selected == true)
              .map((entry) => entry.key)
              .toList();
          if(selectedLocalSelectorIndices.contains(index)) {
            selectionModel.data!.selectorForCentral![index].selected = false;
            selectionModel.data!.selectorForLocal![index].selected = true;
          } else {
            selectionModel.data!.selectorForLocal![index].selected = !selectionModel.data!.selectorForLocal![index].selected;
          }
        }
        break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  //TODO: ALARM SCREEN PROVIDER
  AlarmData? _alarmData;
  AlarmData? get alarmData => _alarmData;
  Future<void> alarmDataFetched(userId, controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramAlarm = await httpService.postRequest('getUserProgramAlarm', userData);
      if(getUserProgramAlarm.statusCode == 200) {
        final responseJson = getUserProgramAlarm.body;
        final convertedJson = jsonDecode(responseJson);
        _alarmData = AlarmData.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateValueForGeneral(notificationTypeId, newValue) {
    final item = _alarmData!.general.firstWhere(
            (notification) => notification.notificationTypeId == notificationTypeId,
        orElse: () => throw Exception('Item not found for identifier: $notificationTypeId',
        ));

    item.selected = newValue;
    notifyListeners();
  }

  void updateValueForEcPh(notificationTypeId, newValue) {
    final item = _alarmData!.ecPh.firstWhere(
            (notification) => notification.notificationTypeId == notificationTypeId,
        orElse: () => throw Exception('Item not found for identifier: $notificationTypeId',
        ));

    item.selected = newValue;
    notifyListeners();
  }

  //TODO: DONE SCREEN PROVIDER
  List<dynamic> programList = [];
  int programCount = 0;
  String programName = '';
  String defaultProgramName = '';
  String priority = '';
  List<String> priorityList = ["High", "Low"];
  bool isCompletionEnabled = false;
  List<String> programTypes = [];
  String selectedProgramType = '';
  int serialNumberCreation = 0;
  bool irrigationProgramType = false;

  List<int> serialNumberList = [];
  ProgramDetails? _programDetails;
  ProgramDetails? get programDetails => _programDetails;
  String get delayBetweenZones => _programDetails!.delayBetweenZones;
  String get adjustPercentage => _programDetails!.adjustPercentage;
  Future<void> doneData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramDetails', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programDetails = ProgramDetails.fromJson(convertedJson);
        programCount = _programLibrary!.program.isEmpty ? 1 : _programLibrary!.program.length + 1;
        serialNumberCreation = _programLibrary!.program.length + 1;
        priority = _programDetails!.priority != "" ? _programDetails!.priority : "None";
        // if(_programDetails != null) {
        programName = serialNumber == 0
            ? "Program $programCount"
            : _programDetails!.programName.isEmpty
            ? _programDetails!.defaultProgramName
            : _programDetails!.programName;
        // } else {
        //   programName = _programDetails!.defaultProgramName;
        // }
        selectedProgramType = _programDetails!.programType == '' ? selectedProgramType : _programDetails!.programType;
        defaultProgramName = (_programDetails!.defaultProgramName == '' || _programDetails!.defaultProgramName.isEmpty) ?  "Program $programCount" : _programDetails!.defaultProgramName;
        isCompletionEnabled = _programDetails!.completionOption;
        Future.delayed(Duration.zero, () {
          notifyListeners();
        });
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: PROGRAM LIBRARY
  bool get getProgramType => _programDetails?.programType == "Irrigation Program" ? true : false;
  ProgramLibrary? _programLibrary;
  ProgramLibrary? get programLibrary => _programLibrary;

  int _selectedSegment = 0;

  int get selectedSegment => _selectedSegment;
  bool agitatorCountIsNotZero = false;
  void updateSelectedSegment(int newIndex) {
    _selectedSegment = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  Future<void> programLibraryData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramLibrary', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programLibrary = ProgramLibrary.fromJson(convertedJson);
        priority = _programDetails?.priority != "" ? _programDetails?.priority ?? "None" : "None";
        agitatorCountIsNotZero = convertedJson['data']['agitatorCount'] != 0 ? true : false;
        conditionsLibraryIsNotEmpty = convertedJson['data']['conditionLibraryCount'] != 0 ? true : false;
        // irrigationProgramType = _programLibrary?.program[serialNumber].programType == "Irrigation Program" ? true : false;
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    notifyListeners();
  }

  //TODO: PROGRAM RESET
  Future<String> userProgramReset(int userId, int controllerId, int serialNumber, int programId) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "modifyUser": userId,
        "programId": programId
      };

      var getUserProgramName = await httpService.putRequest('resetUserProgram', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        log("HTTP Request failed or received an unexpected response.");
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  void updatePriority(newValue, index) {
    _programLibrary?.program[index].priority = newValue;
    notifyListeners();
  }

  void updateProgramName(dynamic newValue, String type) {
    switch (type) {
      case 'programName':programName = newValue != '' ? newValue : programName;
      break;
      case 'priority':priority = newValue;
      break;
      case 'completion':isCompletionEnabled = newValue as bool;
      break;
      case 'programType':selectedProgramType = newValue as String;
      break;
      case"delayBetweenZones": _programDetails!.delayBetweenZones = newValue;
      break;
      case"adjustPercentage": _programDetails!.adjustPercentage = newValue;
      break;
      default:
        log("Not found");
    }
    notifyListeners();
  }

  bool isIrrigationProgram = false;
  bool isAgitatorProgram = false;
  bool showIrrigationPrograms = false;
  bool showAgitatorPrograms = false;
  bool showAllPrograms = true;
  bool isActive = true;

  void updateActiveProgram() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateShowPrograms(all, irrigation, agitator, active) {
    showAllPrograms = all;
    showIrrigationPrograms = irrigation;
    showAgitatorPrograms = agitator;
    notifyListeners();
  }
  void updateIsIrrigationProgram() {
    isIrrigationProgram = true;
    isAgitatorProgram = false;
    notifyListeners();
  }

  void updateIsAgitatorProgram() {
    isAgitatorProgram = true;
    isIrrigationProgram = false;
    notifyListeners();
  }

  List<String> label1 = ['Sequence', 'Schedule', 'Conditions', 'Selection', 'Water & Fert', 'Alarm', 'Done'];
  List<IconData> icons1 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.checklist,
    Icons.local_florist_rounded,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  List<String> label2 = ['Sequence', 'Schedule', 'Conditions', 'Alarm', 'Done'];
  List<IconData> icons2 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  List<String> label3 = ['Sequence', 'Schedule', 'Alarm', 'Done'];
  List<IconData> icons3 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  List<String> label4 = ['Sequence', 'Schedule', 'Selection', 'Water & Fert', 'Alarm', 'Done'];
  List<IconData> icons4 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.checklist,
    Icons.local_florist_rounded,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  //TODO: UPDATE PROGRAM DETAILS
  Future<String> updateUserProgramDetails(
      int userId, int controllerId, int serialNumber, int programId, String programName, String priority) async {
    try {
      Map<String, dynamic> userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber,
        "modifyUser": userId,
        "programId": programId,
        "programName": programName,
        "priority": priority,
      };

      var updateUserProgramDetails = await httpService.putRequest('updateUserProgramDetails', userData);

      if (updateUserProgramDetails.statusCode == 200) {
        final responseJson = updateUserProgramDetails.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: Program Payload conversion for hardware
  DateTime get scheduleAsRunListDate => DateTime.parse(_sampleScheduleModel!.scheduleAsRunList.schedule['startDate']);
  DateTime get scheduleByDayDate => DateTime.parse(_sampleScheduleModel!.scheduleByDays.schedule['startDate']);

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String get formattedScheduleAsRunListDate => formatter.format(scheduleAsRunListDate);
  String get formattedScheduleByDayDate => formatter.format(scheduleByDayDate);

  dynamic getDaySelectionMode() {
    List typeData = _sampleScheduleModel!.scheduleAsRunList.schedule['type'];
    var selectionModeList = [];
    for(var i = 0; i < typeData.length; i++) {
      switch(typeData[i]) {
        case "DO NOTHING":
          selectionModeList.add(0);
          break;
        case "DO WATERING":
          selectionModeList.add(1);
          break;
        case "DO ONE TIME":
          selectionModeList.add(2);
          break;
        case "DO FERTIGATION":
          selectionModeList.add(3);
          break;
      }
    }
    return selectionModeList.join('_');
  }

  List<String> generateRtcTimeList(Map<String, dynamic> rtcData, String key, bool isCycles) {
    return List.generate(6, (index) {
      final rtcKey = 'rtc${index + 1}';
      String rtcValue;

      if (key == 'noOfCycles') {
        rtcValue = index < rtcData.length ? rtcData[rtcKey]['noOfCycles'].toString() : '0';
      } else {
        rtcValue = index < rtcData.length ? '${rtcData[rtcKey][key]}' : '00:00';
      }

      return key == 'noOfCycles' ? rtcValue : '$rtcValue:00';
    });
  }

  String generateRtcTimeString(SampleScheduleModel model, String type, bool isRunList) {
    final rtcTimeList = generateRtcTimeList(isRunList ? model.scheduleAsRunList.rtc : model.scheduleByDays.rtc, type, false);
    return rtcTimeList.join('_');
  }

  String get sBRrtcOnTimeString => generateRtcTimeString(sampleScheduleModel!, 'onTime', true);
  String get sBDrtcOnTimeString => generateRtcTimeString(sampleScheduleModel!, 'onTime', false);
  String get sBRrtcMaxTimeString => generateRtcTimeString(sampleScheduleModel!, 'maxTime', true);
  String get sBDrtcMaxTimeString => generateRtcTimeString(sampleScheduleModel!, 'maxTime', false);
  String get sBRrtcOffTimeString => generateRtcTimeString(sampleScheduleModel!, 'offTime', true);
  String get sBDrtcOffTimeString => generateRtcTimeString(sampleScheduleModel!, 'offTime', false);
  String get sBRrtcNoOfCyclesString => generateRtcTimeString(sampleScheduleModel!, 'noOfCycles', true);
  String get sBDrtcNoOfCyclesString => generateRtcTimeString(sampleScheduleModel!, 'noOfCycles', false);
  String get sBRrtcIntervalString => generateRtcTimeString(sampleScheduleModel!, 'interval', true);
  String get sBDrtcIntervalString => generateRtcTimeString(sampleScheduleModel!, 'interval', false);


  String generateFertilizerString(dataList, idField) {
    if(idField.runtimeType != String) {
      final selectedIds = dataList?.where((element) => element.selected == true).map((element) => element.sNo ?? 0).toList() ?? [];
      return selectedIds.join('_');
    } else {
      final selectedIds = dataList?.where((element) => element.selected == true).map((element) => element.id ?? "").toList() ?? [];
      return selectedIds.join('_');
    }
  }

  String generateFertilizerLocationString(List<NameData>? dataList, String locationField) {
    final selectedLocations = dataList?.where((element) => element.selected == true).map((element) => element.location ?? "").toList() ?? [];
    return selectedLocations.join('_');
  }
  List<String?> get conditionList => _sampleConditions?.condition
      .map((e) => e.value['sNo']?.toString())
      .toList() ?? List.generate(6, (index) => '0');

  dynamic dataToMqtt(serialNumber) {
    return {
      "2501": [
        '$serialNumber',
        '${_irrigationLine!.sequence[0]['valve'][0]['location']}',
        programName,
        '${_irrigationLine?.sequence.map((e) {
          List valveSerialNumbers = e['valve'].map((valve) => valve['id']).toList();
          return valveSerialNumbers.join('+');
        }).toList().join("_")}',
        '${isPumpStationMode ? 1 : 0}',
        '${_selectionModel.data?.irrigationPump?.where((element) => element.selected == true).map((e) => e.sNo).toList().join("_")}',
        '${_selectionModel.data?.mainValve?.where((element) => element.selected == true).map((e) => e.sNo).toList().join("_")}',
        '${priority == "High" ? 1 : 0}',
        '${_sampleScheduleModel!.selected == "NO SCHEDULE" ? 1 : _sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST" ? 2 : 3}',
        (_sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST" ? formattedScheduleAsRunListDate : formattedScheduleByDayDate),
        '${int.parse(_sampleScheduleModel!.scheduleAsRunList.schedule['noOfDays'])}',
        '${_sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? getDaySelectionMode()
            : [_sampleScheduleModel!.scheduleByDays.schedule['skipDays'] ?? '0', _sampleScheduleModel!.scheduleByDays.schedule['runDays'] ?? '0'].join("_")}',
        (_sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? sBRrtcOnTimeString
            : sBDrtcOnTimeString),
        '${_sampleScheduleModel!.defaultModel.rtcMaxTime
            ? 3
            : _sampleScheduleModel!.defaultModel.rtcOffTime
            ? 2
            : 1}',
        (_sampleScheduleModel!.defaultModel.rtcMaxTime
            ? _sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? sBRrtcMaxTimeString
            : sBDrtcMaxTimeString
            : _sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? sBDrtcOffTimeString
            : sBRrtcOffTimeString),
        (_sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? sBRrtcNoOfCyclesString
            : sBDrtcNoOfCyclesString),
        (_sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
            ? sBRrtcIntervalString
            : sBDrtcIntervalString),
        '${_selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)
            ? _selectionModel.data!.centralFertilizerSite?.firstWhere((element) => element.selected == true).id
            : ""}',
        '${_selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)
            ? _selectionModel.data!.localFertilizerSite?.firstWhere((element) => element.selected == true).id
            : ""}',
        (generateFertilizerString(_selectionModel.data!.selectorForCentral, 0)),
        (generateFertilizerString(_selectionModel.data!.selectorForLocal, 0)),
        '${selectionModel.data!.centralFilterSite!.any((element) => element.selected == true)
            ? _selectionModel.data!.centralFilterSite?.firstWhere((element) => element.selected == true).id
            : ""}',
        '${selectionModel.data!.localFilterSite!.any((element) => element.selected == true)
            ? _selectionModel.data!.localFilterSite?.firstWhere((element) => element.selected == true).id
            : ""}',
        '${selectedCentralFiltrationMode == "TIME"
            ? 1 : selectedCentralFiltrationMode == "DP"
            ? 2
            : 3}',
        '${selectedLocalFiltrationMode == "TIME"
            ? 1 : selectedLocalFiltrationMode == "DP"
            ? 2
            : 3}',
        (generateFertilizerString(_selectionModel.data!.localFilter, "id")),
        (generateFertilizerString(_selectionModel.data!.localFilter, "id")),
        // "centralInj": '${generateFertilizerString(_selectionModel.data!.centralFertilizerInjector, 'id')}',
        // "localInj": '${generateFertilizerString(_selectionModel.data!.localFertilizerInjector, 'id')}',
        '${centralFiltBegin ? 1 : 0}',
        '${localFiltBegin ? 1 : 0}',
        '${_sampleConditions?.condition != null
            ? _sampleConditions!.condition.any((element) => element.selected == true)
            ? 1
            : 0
            : 0}',
        (conditionList.map((value) => value ?? '0').toList().join("_")),
        ([..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList(), ..._alarmData!.general.map((e) => e.selected == true ? 1 : 0).toList()].join("_")),
      ].join(','),
      "2502": hwPayloadForWF()
    };
  }
}