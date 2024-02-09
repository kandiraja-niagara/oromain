import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConstantProvider extends ChangeNotifier{
  List<String> myTabs = ['General','Lines','Main valve','Valve','Water meter','Fertilizers','EC/PH','Filters','Analog sensor','Moisture sensor','Level sensor','Normal Alarm','Critical Alarm','Finish'];
  List<List<dynamic>> general = [['Reset time','00:00',Icon(Icons.restart_alt),'time'],['Fertilizer leakage limit','20',Icon(Icons.production_quantity_limits),'numbers'],['Run list limit','10',Icon(Icons.list)],['Current irrigation day','1',Icon(Icons.today),'numbers'],['No pressure delay','00:00',Icon(Icons.timelapse_outlined),'time'],['Water pulse before dosing','Yes',Icon(Icons.navigate_before),'yes/no'],['Common dosing coefficient','100%',Icon(Icons.percent),'percentage']];
  int selected = -1;
  dynamic APIdata = {};
  dynamic APIpump = ['IP1','IP2','IP3','IP4','IP5'];
  List<dynamic>  irrigationLines = [
    ['Line 1','1','IP1','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 2','2','IP2','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 3','3','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 4','4','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 5','5','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 6','6','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 7','7','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 8','8','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 9','9','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 10','10','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 11','11','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 12','12','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
  ];
  List<Map<String,dynamic>> irrigationLineUpdated = [];
  List<Map<String,dynamic>> mainValveUpdated = [];
  List<Map<String,dynamic>> valveUpdated = [];
  List<Map<String,dynamic>> fertilizerUpdated = [];
  List<Map<String,dynamic>> ecPhUpdated = [];
  List<Map<String,dynamic>> waterMeterUpdated = [];
  List<Map<String,dynamic>> filterUpdated = [];
  List<Map<String,dynamic>> analogSensorUpdated = [];
  List<Map<String,dynamic>> moistureSensorUpdated = [];
  List<Map<String,dynamic>> levelSensorUpdated = [];
  List<dynamic> alarmUpdated = [];
  List<dynamic> criticalAlarmUpdated = [];
  List<dynamic> alarmType = [];
  Map<String,dynamic> setting = {};
  int wantToSendData = 0;
  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }

  List<dynamic>  mainValve = [
    ['Main Valve 1','1','1','NO DELAY','00:00'],
    ['Main Valve 2','2','1','NO DELAY','00:00'],
    ['Main Valve 3','3','1','NO DELAY','00:00'],
    ['Main Valve 4','4','1','NO DELAY','00:00'],
    ['Main Valve 5','5','2','NO DELAY','00:00'],
    ['Main Valve 6','6','2','NO DELAY','00:00'],
    ['Main Valve 7','7','2','NO DELAY','00:00'],
    ['Main Valve 8','8','3','NO DELAY','00:00'],
    ['Main Valve 9','9','3','NO DELAY','00:00'],
    ['Main Valve 10','10','3','NO DELAY','00:00'],
    ['Main Valve 11','11','3','NO DELAY','00:00'],
    ['Main Valve 12','12','3','NO DELAY','00:00'],
    ['Main Valve 12','12','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
  ];
  List<dynamic> valve = [
    {
      '1' : [
        ['1','1','valve 1','00:00:00','100','75','125','15','1.00','100'],
        ['2','2','valve 2','00:00:00','100','75','125','15','1.00','100'],
        ['3','3','valve 3','00:00:00','100','75','125','15','1.00','100'],
        ['4','4','valve 4','00:00:00','100','75','125','15','1.00','100'],
        ['5','5','valve 5','00:00:00','100','75','125','15','1.00','100'],
        ['6','6','valve 6','00:00:00','100','75','125','15','1.00','100'],
        ['7','7','valve 7','00:00:00','100','75','125','15','1.00','100'],
        ['8','8','valve 8','00:00:00','100','75','125','15','1.00','100'],
      ]
    },
    {
      '2' : [
        ['1','1','valve 1','00:00:00','100','75','125','15','1.00','100'],
        ['2','2','valve 2','00:00:00','100','75','125','15','1.00','100'],
        ['3','3','valve 3','00:00:00','100','75','125','15','1.00','100'],
        ['4','4','valve 4','00:00:00','100','75','125','15','1.00','100'],
        ['5','5','valve 5','00:00:00','100','75','125','15','1.00','100'],
        ['6','6','valve 6','00:00:00','100','75','125','15','1.00','100'],
        ['7','7','valve 7','00:00:00','100','75','125','15','1.00','100'],
        ['8','8','valve 8','00:00:00','100','75','125','15','1.00','100'],
      ]
    },
  ];


  List<dynamic>  waterMeter = [
    ['1','Line 1','water meter 1','100','1000'],
    ['2','Line 2','water meter 2','100','1000'],
    ['3','Line 3','water meter 3','100','1000'],
    ['4','Line 4','water meter 4','100','1000'],
    ['5','Line 5','water meter 5','100','1000'],
    ['6','IP 1','water meter 6','100','1000'],
    ['7','IP 2','water meter 7','100','1000'],
    ['8','IP 3','water meter 8','100','1000'],
    ['9','SP 1','water meter 9','100','1000'],
    ['10','SP 2','water meter 10','100','1000'],
  ];

  List<dynamic> fertilizer = [
    ['central fertilizer 1','1,2,3','STOP FAULTY FERTILIZER',[['fert 1','CF1 fert1','yes','100','20','400','REGULAR'],['fert 2','CF1 fert2','yes','100','20','400','REGULAR'],['fert 3','CF1 fert3','yes','100','20','400','REGULAR']]],
    ['central fertilizer 2','1,2,3','INFORM ONLY',[['fert 1','CF2 fert1','yes','100','20','400','REGULAR'],['fert 2','CF2 fert2','yes','100','20','400','REGULAR'],['fert 3','CF2 fert3','yes','100','20','400','REGULAR']]]
  ];
  String dropDownValue = 'Stop Irrigation';
  void editDropDownValue(String val){
    dropDownValue = val;
    notifyListeners();
  }

  List<dynamic>  filter = [
    ['CF 1','Central filtration 1','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 2','Central filtration 2','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 3','Central filtration 3','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 4','Central filtration 4','1,2,3','30','99','NO FERTILIZATION'],
    ['LF 1','Local filtration 1','1','30','99','NO FERTILIZATION'],
    ['LF 2','Local filtration 2','2','30','99','NO FERTILIZATION'],
    ['LF 3','Local filtration 3','3','30','99','NO FERTILIZATION'],
    ['LF 4','Local filtration 4','4','30','99','NO FERTILIZATION'],
  ];

  List<dynamic>  analogSensor = [
    ['1','Analog Sensor 1','VWC','bar','current','10','10'],
    ['2','Analog Sensor 2','VWC','bar','current','10','10'],
    ['3','Analog Sensor 3','VWC','bar','current','10','10'],
    ['4','Analog Sensor 4','VWC','bar','current','10','10'],
    ['5','Analog Sensor 5','VWC','bar','current','10','10'],
    ['6','Analog Sensor 6','VWC','bar','current','10','10'],
    ['7','Analog Sensor 7','VWC','bar','current','10','10'],
    ['8','Analog Sensor 8','VWC','bar','current','10','10'],
  ];

  String lineBehavior(String value){
    switch(value){
      case ('IGNORE'):{
        return '1';
      }
      case ('DO NEXT'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String mvMode(String value){
    switch(value){
      case ('NO DELAY'):{
        return '1';
      }
      case ('OPEN BEFORE'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String AStype(String value){
    switch(value){
      case ('Pressure IN'):{
        return '1';
      }
      case ('Pressure OUT'):{
        return '2';
      }
      case ('EC'):{
        return '3';
      }
      case ('PH'):{
        return '4';
      }
      case ('Level'):{
        return '5';
      }
      case ('Valve Pressure'):{
        return '6';
      }
      case ('Soil Moisture'):{
        return '7';
      }
      default :{
        return '8';
      }
    }
  }
  String AStUnit(String value){
    switch(value){
      case ('Bar'):{
        return '1';
      }
      case ('dS/m'):{
        return '2';
      }

      default :{
        return '3';
      }
    }
  }
  String ASDS(String value){
    switch(value){
      case ('Built- in Cloud'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }
  String ASbase(String value){
    switch(value){
      case ('current'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }
  void fetchSettings(dynamic data){
    setting['resetTime'] = data['general']['resetTime'];
    setting['fertilizerLeakageLimit'] = data['general']['fertilizerLeakageLimit'];
    setting['runListLimit'] = data['general']['runListLimit'];
    setting['currentIrrigationDay'] = data['general']['currentIrrigationDay'];
    setting['noPressureDelay'] = data['general']['noPressureDelay'];
    setting['waterPulseBeforeDosing'] = data['general']['waterPulseBeforeDosing'];
    setting['commonDosingCoefficient'] = data['general']['commonDosingCoefficient'];
    setting['line'] = {};
    for(var il in data['line']){
      setting['line']['${il['sNo']}'] = il;
    }
    setting['mainValve'] = {};
    for(var il in data['mainValve']){
      setting['mainValve']['${il['sNo']}'] = il;
    }
    setting['valve'] = {};
    for(var il in data['valve']){
      for(var vl in il['valve']){
        setting['valve']['${vl['sNo']}'] = vl;
      }
    }
    setting['waterMeter'] = {};
    for(var wm in data['waterMeter']){
      setting['waterMeter']['${wm['sNo']}'] = wm;
    }
    setting['fertilization'] = {};
    setting['inj'] = {};
    for(var fertSite in data['fertilization']){
      setting['fertilization']['${fertSite['sNo']}'] = fertSite;
      for(var fert in fertSite['fertilizer']){
        setting['inj']['${fert['sNo']}'] = fert;
      }
    }
    setting['filtration'] = {};
    for(var il in data['filtration']){
      setting['filtration']['${il['sNo']}'] = il;
    }
    setting['ecPh'] = {};
    for(var fertSite in data['ecPh']){
      for(var stg in fertSite['setting']){
        setting['ecPh']['${fertSite['sNo']}${stg['name']}'] = stg;
      }
    }
    setting['analogSensor'] = {};
    for(var il in data['analogSensor']){
      setting['analogSensor']['${il['sNo']}'] = il;
    }
    setting['moistureSensor'] = {};
    for(var il in data['moistureSensor']){
      setting['moistureSensor']['${il['sNo']}'] = il;
    }
    setting['levelSensor'] = {};
    for(var il in data['levelSensor']){
      setting['levelSensor']['${il['sNo']}'] = il;
    }
    setting['normalAlarm'] = {};
    for(var il in data['normalAlarm']){
      setting['normalAlarm']['${il['sNo']}'] = {};
      for(var st in il['alarm']){
        setting['normalAlarm']['${il['sNo']}']['${st['name']}'] = {};
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['scanTime'] = st['scanTime'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['alarmOnStatus'] = st['alarmOnStatus'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['resetAfterIrrigation'] = st['resetAfterIrrigation'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['autoResetDuration'] = st['autoResetDuration'];
        setting['normalAlarm']['${il['sNo']}']['${st['name']}']['threshold'] = st['threshold'];
      }
    }
    setting['criticalAlarm'] = {};
    for(var il in data['criticalAlarm']){
      setting['criticalAlarm']['${il['sNo']}'] = {};
      for(var st in il['alarm']){
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}'] = {};
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['scanTime'] = st['scanTime'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['alarmOnStatus'] = st['alarmOnStatus'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['resetAfterIrrigation'] = st['resetAfterIrrigation'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['autoResetDuration'] = st['autoResetDuration'];
        setting['criticalAlarm']['${il['sNo']}']['${st['name']}']['threshold'] = st['threshold'];
      }
    }
    print('setting1 : ${setting['ecPh']}');
    notifyListeners();
  }
  void fetchAll(dynamic data){
    irrigationLineUpdated = [];
    mainValveUpdated = [];
    valveUpdated = [];
    waterMeterUpdated = [];
    fertilizerUpdated = [];
    ecPhUpdated = [];
    filterUpdated = [];
    analogSensorUpdated = [];
    moistureSensorUpdated = [];
    levelSensorUpdated = [];
    alarmUpdated = [];
    alarmType = [];
    general = [
      ['Reset time',setting['resetTime'] ?? '00:00',Icon(Icons.restart_alt),'time'],
      ['Fertilizer leakage limit',setting['fertilizerLeakageLimit'] ?? '20',Icon(Icons.production_quantity_limits),'numbers'],
      ['Run list limit',setting['runListLimit'] ?? '10',Icon(Icons.list)],
      ['Current irrigation day',setting['currentIrrigationDay'] ?? '1',Icon(Icons.today),'numbers'],
      ['No pressure delay',setting['noPressureDelay'] ?? '00:00',Icon(Icons.timelapse_outlined),'time'],
      ['Water pulse before dosing',setting['waterPulseBeforeDosing'] ?? 'Yes',Icon(Icons.navigate_before),'yes/no'],
      ['Common dosing coefficient',setting['commonDosingCoefficient'] ?? '100%',Icon(Icons.percent),'percentage']
    ];    for(var i in data.entries){
      if(i.key == 'constant'){
        APIdata = i.value;
      }
      if(i.key == 'default'){
        for(var j in i.value.entries){
          if(j.key == 'alarm'){
            for(var at in j.value){
              alarmType.add(at);
            }
          }
          else if(j.key == 'line'){
            // if(j.value.length != 0){
            //   // myTabs.add('Lines');
            // }
            //TODO: generating line
            for(var line in j.value){
              var type = [];
              var criticalType = [];
              for(var at in alarmType){
                type.add({
                  'name' : '${at['name']}',
                  'scanTime' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['scanTime'] ?? '00:00:00',
                  'alarmOnStatus' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['alarmOnStatus'] ?? 'Do Nothing',
                  'resetAfterIrrigation' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['resetAfterIrrigation'] ?? 'Yes',
                  'autoResetDuration' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['autoResetDuration'] ?? '00:00:00',
                  'threshold' : setting['normalAlarm']?['${line['sNo']}']?['${at['name']}']?['threshold'] ?? '0',
                  'unit' : '${at['unit']}',
                });
                criticalType.add({
                  'name' : '${at['name']}',
                  'scanTime' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['scanTime'] ?? '00:00:00',
                  'alarmOnStatus' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['alarmOnStatus'] ?? 'Do Nothing',
                  'resetAfterIrrigation' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['resetAfterIrrigation'] ?? 'Yes',
                  'autoResetDuration' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['autoResetDuration'] ?? '00:00:00',
                  'threshold' : setting['criticalAlarm']?['${line['sNo']}']?['${at['name']}']?['threshold'] ?? '0',
                  'unit' : '${at['unit']}',
                });
              }
              print('seee : ${setting['normalAlarm']?['${line['sNo']}']}');
              alarmUpdated.add({
                'sNo' : line['sNo'],
                'name' : line['name'],
                'id' : line['id'],
                'alarm' : type,
              });
              criticalAlarmUpdated.add({
                'sNo' : line['sNo'],
                'name' : line['name'],
                'id' : line['id'],
                'alarm' : criticalType,
              });
              irrigationLineUpdated.add({
                'sNo' : line['sNo'],
                'name' : line['name'],
                'id' : line['id'],
                'pump' : line['irrigationPump'].length != 0 ? line['irrigationPump'][0]['id'] : '-',
                'lowFlowDelay' : setting['line']?['${line['sNo']}']?['lowFlowDelay'] ?? '00:00:00',
                'highFlowDelay' : setting['line']?['${line['sNo']}']?['highFlowDelay'] ?? '00:00:00',
                'lowFlowBehavior' : setting['line']?['${line['sNo']}']?['lowFlowBehavior'] ?? 'Ignore',
                'highFlowBehavior' : setting['line']?['${line['sNo']}']?['highFlowBehavior'] ?? 'Ignore',
                'leakageLimit' : setting['line']?['${line['sNo']}']?['leakageLimit'] ?? '0',
              });
              // if(line['mainValve'].length != 0){
              //   if(!myTabs.contains('Main valve')){
              //     myTabs.add('Main valve');
              //   }
              // }
              //TODO: generating mainValve
              for(var mv in line['mainValve']){
                mainValveUpdated.add({
                  'sNo' : mv['sNo'],
                  'name' : mv['name'],
                  'id' : mv['id'],
                  'location' : line['name'],
                  'mode' : setting['mainValve']?['${mv['sNo']}']?['mode'] ?? 'No delay',
                  'delay' : setting['mainValve']?['${mv['sNo']}']?['delay'] ?? '00:00:00',
                });
              }
              //TODO: generating moistureSensor
              for(var ms in line['moistureSensor']){
                moistureSensorUpdated.add({
                  'sNo' : ms['sNo'],
                  'name' : ms['name'],
                  'id' : ms['id'],
                  'location' : line['id'],
                  'high/low' : setting['moistureSensor']?['${ms['sNo']}']?['high/low'] ?? '-',
                  'units' : setting['moistureSensor']?['${ms['sNo']}']?['units'] ?? 'bar',
                  'base' : setting['moistureSensor']?['${ms['sNo']}']?['base'] ?? 'Current',
                  'minimum' : setting['moistureSensor']?['${ms['sNo']}']?['minimum'] ?? '0.00',
                  'maximum' : setting['moistureSensor']?['${ms['sNo']}']?['maximum'] ?? '0.00',
                });
              }
              //TODO: generating levelSensor
              for(var ls in line['levelSensor']){
                levelSensorUpdated.add({
                  'sNo' : ls['sNo'],
                  'name' : ls['name'],
                  'id' : ls['id'],
                  'location' : line['id'],
                  'high/low' : setting['levelSensor']?['${ls['sNo']}']?['high/low'] ?? '-',
                  'units' : setting['levelSensor']?['${ls['sNo']}']?['units'] ?? 'bar',
                  'base' : setting['levelSensor']?['${ls['sNo']}']?['base'] ?? 'Current',
                  'minimum' : setting['levelSensor']?['${ls['sNo']}']?['minimum'] ?? '0.00',
                  'maximum' : setting['levelSensor']?['${ls['sNo']}']?['maximum'] ?? '0.00',
                });
              }
              //TODO: generating valve
              var valve = [];
              for(var v in line['valve']){
                valve.add({
                  'sNo' : v['sNo'],
                  'name' : v['name'],
                  'id' : v['id'],
                  'location' : v['location'],
                  'defaultDosage' : setting['valve']?['${v['sNo']}']?['defaultDosage'] ?? 'Time',
                  'nominalFlow' : setting['valve']?['${v['sNo']}']?['nominalFlow'] ?? '100',
                  'minimumFlow' : setting['valve']?['${v['sNo']}']?['minimumFlow'] ?? '75',
                  'maximumFlow' : setting['valve']?['${v['sNo']}']?['maximumFlow'] ?? '125',
                  'fillUpDelay' : setting['valve']?['${v['sNo']}']?['fillUpDelay'] ?? '00:00:00',
                  'area' : setting['valve']?['${v['sNo']}']?['area'] ?? '0.00',
                  'cropFactor' : setting['valve']?['${v['sNo']}']?['cropFactor'] ?? '0',
                });
              }
              valveUpdated.add({
                'sNo' : line['sNo'],
                'name' : line['name'],
                'valve' : valve,
              });

            }
          }
          else if(j.key == 'fertilization'){
            for(var fert in j.value){
              var fertilizer = [];
              var ecPhSetting = [];
              for(var inj in fert['fertilizer']){
                fertilizer.add({
                  'sNo' : inj['sNo'],
                  'id' : inj['id'],
                  'name' : inj['name'],
                  'fertilizerMeter' : inj['fertilizerMeter'].length != 0 ? 'yes' : 'no',
                  'ratio' : setting['inj']?['${inj['sNo']}']?['ratio'] ?? '100',
                  'shortestPulse' : setting['inj']?['${inj['sNo']}']?['shortestPulse'] ?? '1',
                  'nominalFlow' : setting['inj']?['${inj['sNo']}']?['nominalFlow'] ?? '100',
                  'injectorMode' : setting['inj']?['${inj['sNo']}']?['injectorMode'] ?? 'Regular',
                });
              }
              if(fert['ec'].length != 0){
                print('see : ${setting['ecPh']}');
                dynamic ecStg = {
                  'name' : 'ec',
                  'sensor' : [],
                  'active' : setting['ecPh']?['${fert['sNo']}ec']?['active'] ?? false,
                  'controlCycle' : setting['ecPh']?['${fert['sNo']}ec']?['controlCycle'] ?? '00:00:00',
                  'delta' : setting['ecPh']?['${fert['sNo']}ec']?['delta'] ?? '0.0',
                  'fineTunning' : setting['ecPh']?['${fert['sNo']}ec']?['fineTunning'] ?? '0',
                  'coarseTunning' : setting['ecPh']?['${fert['sNo']}ec']?['coarseTunning'] ?? '0.0',
                  'deadBand' : setting['ecPh']?['${fert['sNo']}ec']?['deadBand'] ?? '0.0',
                  'integ' : setting['ecPh']?['${fert['sNo']}ec']?['integ'] ?? '00:00:00',
                  'sensorList' : [],
                  'avgFilterList' : ['1','2','3','4','5','6','7','8','9','10'],
                  'senseOrAvg' : fert['ec'].length > 1 ? 'Average' : '${fert['ec'][0]['id']}',
                  'avgFilterSpeed' : setting['ecPh']?['${fert['sNo']}ec']?['avgFilterSpeed'] ?? '1',
                };
                var sensorList = [];
                for(var ec in fert['ec']){
                  ecStg['sensor'].add(ec);
                  sensorList.add(ec['id']);
                }
                if(fert['ec'].length > 1){
                  sensorList.add('Average');
                }
                ecStg['sensorList'] = sensorList;
                ecPhSetting.add(ecStg);
              }
              if(fert['ph'].length != 0){
                dynamic phStg = {
                  'name' : 'ph',
                  'sensor' : [],
                  'active' : setting['ecPh']?['${fert['sNo']}ph']?['active'] ?? false,
                  'controlCycle' : setting['ecPh']?['${fert['sNo']}ph']?['controlCycle'] ?? '00:00:00',
                  'delta' : setting['ecPh']?['${fert['sNo']}ph']?['delta'] ?? '0.0',
                  'fineTunning' : setting['ecPh']?['${fert['sNo']}ph']?['fineTunning'] ?? '0',
                  'coarseTunning' : setting['ecPh']?['${fert['sNo']}ph']?['coarseTunning'] ?? '0.0',
                  'deadBand' : setting['ecPh']?['${fert['sNo']}ph']?['deadBand'] ?? '0.0',
                  'integ' : setting['ecPh']?['${fert['sNo']}ph']?['integ'] ?? '00:00:00',
                  'sensorList' : [],
                  'avgFilterList' : ['1','2','3','4','5','6','7','8','9','10'],
                  'senseOrAvg' : fert['ph'].length > 1 ? 'Average' : '${fert['ph'][0]['id']}',
                  'avgFilterSpeed' : setting['ecPh']?['${fert['sNo']}ph']?['avgFilterSpeed'] ?? '1',
                };
                var sensorList = [];

                for(var ph in fert['ph']){
                  phStg['sensor'].add(ph);
                  sensorList.add(ph['id']);
                }
                if(fert['ph'].length > 1){
                  sensorList.add('Average');
                }
                phStg['sensorList'] = sensorList;
                ecPhSetting.add(phStg);
              }


              //TODO: generating injector

              fertilizerUpdated.add({
                'sNo' : fert['sNo'],
                'id' : fert['id'],
                'name' : fert['name'],
                'location' : fert['location'],
                'noFlowBehavior' : setting['fertilization']?['${fert['sNo']}']?['noFlowBehavior'] ?? 'Inform Only',
                'minimalOnTime' : setting['fertilization']?['${fert['sNo']}']?['minimalOnTime'] ?? '00:00:00',
                'minimalOffTime' : setting['fertilization']?['${fert['sNo']}']?['minimalOffTime'] ?? '00:00:00',
                'waterFlowStabilityTime' : setting['fertilization']?['${fert['sNo']}']?['waterFlowStabilityTime'] ?? '00:00:00',
                'boosterOffDelay' : setting['fertilization']?['${fert['sNo']}']?['boosterOffDelay'] ?? '00:00:00',
                'fertilizer' : fertilizer,
              });
              //TODO: generating ecPh
              if(ecPhSetting.length != 0){
                ecPhUpdated.add({
                  'sNo' : fert['sNo'],
                  'id' : fert['id'],
                  'name' : fert['name'],
                  'location' : fert['location'],
                  'setting' : ecPhSetting,
                });
              }
            }
          }
          //TODO: generating waterMeter
          else if(j.key == 'waterMeter'){
            for(var wm in j.value){
              waterMeterUpdated.add({
                'sNo' : wm['sNo'],
                'id' : wm['id'],
                'name' : wm['name'],
                'location' : wm['location'],
                'ratio' : setting['waterMeter']?['${wm['sNo']}']?['ratio'] ?? '100',
                'maximumFlow' : setting['waterMeter']?['${wm['sNo']}']?['maximumFlow'] ?? '100',
              });
            }
          }
          //TODO: generating filtration
          else if(j.key == 'filtration'){
            for(var fl in j.value){
              filterUpdated.add({
                'sNo' : fl['sNo'],
                'id' : fl['id'],
                'name' : fl['name'],
                'location' : fl['location'],
                'dpDelay' : setting['filtration']?['${fl['sNo']}']?['dpDelay'] ?? '00:00:00',
                'loopingLimit' : setting['filtration']?['${fl['sNo']}']?['loopingLimit'] ?? '1',
                'whileFlushing' : setting['filtration']?['${fl['sNo']}']?['whileFlushing'] ?? 'Stop Irrigation',
              });
            }
          }
          //TODO: generating analogSensor
          else if(j.key == 'analogSensor'){
            for(var as in j.value){
              analogSensorUpdated.add({
                'sNo' : as['sNo'],
                'id' : as['id'],
                'name' : as['name'],
                'type' : setting['analogSensor']?['${as['sNo']}']?['type'] ?? 'Soil Temperature',
                'units' : setting['analogSensor']?['${as['sNo']}']?['units'] ?? 'bar',
                'base' : setting['analogSensor']?['${as['sNo']}']?['base'] ?? 'Current',
                'minimum' : setting['analogSensor']?['${as['sNo']}']?['minimum'] ?? '0.00',
                'maximum' : setting['analogSensor']?['${as['sNo']}']?['maximum'] ?? '0.00',
              });
            }
          }

        }
      }
    }
    print('ecph : ${jsonEncode(ecPhUpdated)}');
    notifyListeners();
  }

  void generalSelected(int index){
    selected = index;
    notifyListeners();
  }

  void generalFunctionality(int index,String value){
    general[index][1] = value;
    notifyListeners();
  }
  void irrigationLineFunctionality(dynamic list){
    switch(list[0]){
      case ('line/irrigationPump'):{
        irrigationLineUpdated[list[1]]['pump'] = list[2];
        break;
      }
      case ('line/lowFlowDelay'):{
        irrigationLineUpdated[list[1]]['lowFlowDelay'] = list[2];
        break;
      }
      case ('line/highFlowDelay'):{
        irrigationLineUpdated[list[1]]['highFlowDelay'] = list[2];
        break;
      }
      case ('line/lowFlowBehavior'):{
        irrigationLineUpdated[list[1]]['lowFlowBehavior'] = list[2];
        break;
      }
      case ('line/highFlowBehavior'):{
        irrigationLineUpdated[list[1]]['highFlowBehavior'] = list[2];
        break;
      }
      case ('line/leakageLimit'):{
        irrigationLineUpdated[list[1]]['leakageLimit'] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void mainValveFunctionality(dynamic list){
    switch (list[0]){
      case ('mainvalve/mode'):{
        mainValveUpdated[list[1]]['mode'] = list[2];
        break;
      }
      case ('mainvalve/delay'):{
        mainValveUpdated[list[1]]['delay'] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void valveFunctionality(dynamic list){
    print(list);
    switch (list[0]){
      case ('valve_defaultDosage'):{
        valveUpdated[list[1]]['valve'][list[2]]['defaultDosage'] = list[3];
        break;
      }
      case ('valve_nominal_flow'):{
        valveUpdated[list[1]]['valve'][list[2]]['nominalFlow'] = list[3];
        break;
      }
      case ('valve_minimum_flow'):{
        valveUpdated[list[1]]['valve'][list[2]]['minimumFlow'] = list[3];
        break;
      }
      case ('valve_maximum_flow'):{
        valveUpdated[list[1]]['valve'][list[2]]['maximumFlow'] = list[3];
        break;
      }
      case ('valve_fillUpDelay'):{
        valveUpdated[list[1]]['valve'][list[2]]['fillUpDelay'] = list[3];
        break;
      }
      case ('valve_area'):{
        valveUpdated[list[1]]['valve'][list[2]]['area'] = list[3];
        break;
      }
      case ('valve_crop_factor'):{
        valveUpdated[list[1]]['valve'][list[2]]['cropFactor'] = list[3];
        break;
      }
    }
    notifyListeners();
  }

  void waterMeterFunctionality(dynamic list){
    switch (list[0]){
      case ('wm_ratio'):{
        waterMeterUpdated[list[1]]['ratio'] = list[2];
        break;
      }
      case ('maximum_flow'):{
        waterMeterUpdated[list[1]]['maximumFlow'] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void fertilizerFunctionality(dynamic list){
    switch (list[0]){
      case ('fertilizer/noFlowBehavior'):{
        fertilizerUpdated[list[1]]['noFlowBehavior'] = list[2];
        break;
      }
      case ('fertilizer_minimalOnTime'):{
        fertilizerUpdated[list[1]]['minimalOnTime'] = list[2];
        break;
      }
      case ('fertilizer_minimalOffTime'):{
        fertilizerUpdated[list[1]]['minimalOffTime'] = list[2];
        break;
      }
      case ('fertilizer_waterFlowStabilityTime'):{
        fertilizerUpdated[list[1]]['waterFlowStabilityTime'] = list[2];
        break;
      }
      case ('fertilizer_boosterOffDelay'):{
        fertilizerUpdated[list[1]]['boosterOffDelay'] = list[2];
        break;
      }
      case ('fertilizer_ratio'):{
        fertilizerUpdated[list[1]][list[2]][list[3]]['ratio'] = list[4];
        break;
      }
      case ('fertilizer_shortestPulse'):{
        fertilizerUpdated[list[1]][list[2]][list[3]]['shortestPulse'] = list[4];
        break;
      }
      case ('fertilizer_injectorMode'):{
        fertilizerUpdated[list[1]][list[2]][list[3]]['injectorMode'] = list[4];
        break;
      }
      case ('fertilizer_nominalFlow'):{
        fertilizerUpdated[list[1]][list[2]][list[3]]['nominalFlow'] = list[4];
        break;
      }

    }
    notifyListeners();
  }
  void ecPhFunctionality(dynamic list){
    switch (list[0]){
      case ('activateEcPh'):{
        ecPhUpdated[list[1]]['setting'][list[2]]['active'] = list[3];
        break;
      }
      case ('ecPhControlCycle'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['controlCycle'] = list[4];
        break;
      }
      case ('ecPhInteg'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['integ'] = list[4];
        break;
      }
      case ('ecPhDelta'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['delta'] = list[4];
        break;
      }
      case ('ecPhFineTunning'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['fineTunning'] = list[4];
        break;
      }
      case ('ecPhCoarseTunning'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['coarseTunning'] = list[4];
        break;
      }
      case ('ecPhDeadBand'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['deadBand'] = list[4];
        break;
      }
      case ('ecPhAvgFiltSpeed'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['senseOrAvg'] = list[4];
        break;
      }
      case ('ecPhSenseOrAvg'):{
        ecPhUpdated[list[1]][list[2]][list[3]]['senseOrAvg'] = list[4];
        break;
      }
    }
    notifyListeners();
  }

  void filterFunctionality(dynamic list){
    switch (list[0]){
      case ('filter_dp_delay'):{
        filterUpdated[list[1]]['dpDelay'] = list[2];
        break;
      }
      case ('filter_looping_limit'):{
        filterUpdated[list[1]]['loopingLimit'] = list[2];
        break;
      }
      case ('filter/flushing'):{
        filterUpdated[list[1]]['whileFlushing'] = list[2];
        break;
      }

    }
    notifyListeners();
  }

  void analogSensorFunctionality(dynamic list){
    switch (list[0]){
      case ('analogSensor/type'):{
        analogSensorUpdated[list[1]]['type'] = list[2];
        break;
      }
      case ('analogSensor/units'):{
        analogSensorUpdated[list[1]]['units'] = list[2];
        break;
      }
      case ('analogSensor/base'):{
        analogSensorUpdated[list[1]]['base'] = list[2];
        break;
      }
      case ('analogSensor_minimum_v'):{
        analogSensorUpdated[list[1]]['minimum'] = list[2];
        break;
      }
      case ('analogSensor_maximum_v'):{
        analogSensorUpdated[list[1]]['maximum'] = list[2];
        break;
      }

    }
    notifyListeners();
  }
  void moistureSensorFunctionality(dynamic list){
    switch (list[0]){
      case ('moistureSensor_high_low'):{
        moistureSensorUpdated[list[1]]['high/low'] = list[2];
        break;
      }
      case ('moistureSensor/units'):{
        moistureSensorUpdated[list[1]]['units'] = list[2];
        break;
      }
      case ('moistureSensor/base'):{
        moistureSensorUpdated[list[1]]['base'] = list[2];
        break;
      }
      case ('moistureSensor_value'):{
        moistureSensorUpdated[list[1]]['value'] = list[2];
        break;
      }
      case ('moistureSensor_minimum_v'):{
        moistureSensorUpdated[list[1]]['minimum'] = list[2];
        break;
      }
      case ('moistureSensor_maximum_v'):{
        moistureSensorUpdated[list[1]]['maximum'] = list[2];
        break;
      }
    }
    notifyListeners();
  }
  void levelSensorFunctionality(dynamic list){
    switch (list[0]){
      case ('levelSensor_high_low'):{
        levelSensorUpdated[list[1]]['high/low'] = list[2];
        break;
      }
      case ('levelSensor/units'):{
        levelSensorUpdated[list[1]]['units'] = list[2];
        break;
      }
      case ('levelSensor/base'):{
        levelSensorUpdated[list[1]]['base'] = list[2];
        break;
      }
      case ('levelSensor_value'):{
        levelSensorUpdated[list[1]]['value'] = list[2];
        break;
      }
      case ('levelSensor_minimum_v'):{
        levelSensorUpdated[list[1]]['minimum'] = list[2];
        break;
      }
      case ('levelSensor_maximum_v'):{
        levelSensorUpdated[list[1]]['maximum'] = list[2];
        break;
      }
    }
    notifyListeners();
  }
  void alarmFunctionality(dynamic list){
    switch (list[0]){
      case ('alarm_scanTime'):{
        alarmUpdated[list[1]]['alarm'][list[2]]['scanTime'] = list[3];
        break;
      }
      case ('alarm_status'):{
        alarmUpdated[list[1]]['alarm'][list[2]]['alarmOnStatus'] = list[3];
        if(list[3] == 'Stop Irrigation'){
          alarmUpdated[list[1]]['alarm'][list[2]].remove('resetAfterIrrigation');
        }else{
          alarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'No';
        }
        break;
      }
      case ('alarm_reset_irrigation'):{
        alarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = list[3];
        break;
      }
      case ('alarm_auto_reset'):{
        alarmUpdated[list[1]]['alarm'][list[2]]['autoResetDuration'] = list[3];
        break;
      }
      case ('alarm_threshold'):{
        alarmUpdated[list[1]]['alarm'][list[2]]['threshold'] = list[3];
        break;
      }
    }
    notifyListeners();
  }
  void criticalAlarmFunctionality(dynamic list){
    switch (list[0]){
      case ('critical_alarm_scanTime'):{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['scanTime'] = list[3];
        break;
      }
      case ('critical_alarm_status'):{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['alarmOnStatus'] = list[3];
        if(list[3] == 'Stop Irrigation'){
          criticalAlarmUpdated[list[1]]['alarm'][list[2]].remove('resetAfterIrrigation');
        }else{
          criticalAlarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = 'No';
        }
        break;
      }
      case ('critical_alarm_reset_irrigation'):{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['resetAfterIrrigation'] = list[3];
        break;
      }
      case ('critical_alarm_auto_reset'):{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['autoResetDuration'] = list[3];
        break;
      }
      case ('critical_alarm_threshold'):{
        criticalAlarmUpdated[list[1]]['alarm'][list[2]]['threshold'] = list[3];
        break;
      }
    }
    notifyListeners();
  }

  bool valveContentShow = false;
  void editValveContentShow(bool value){
    valveContentShow = value;
    notifyListeners();
  }

  int returnMvMode(String name){
    if(name == 'No delay'){
      return 1;
    }else if(name == 'Open before'){
      return 2;
    }else{
      return 3;
    }
  }
  int noFlowBehavior(String name){
    if(name == 'Stop Faulty Fertilizer'){
      return 1;
    }else if(name == 'Stop Fertigation'){
      return 2;
    }else if(name == 'Stop Irrigation'){
      return 3;
    }else{
      return 4;
    }
  }
  int analogType(String name){
    if(name == 'Soil Temperature'){
      return 2;
    }else if(name == 'Soil Moisture'){
      return 1;
    }else if(name == 'Rainfall'){
      return 3;
    }else if(name == 'Windspeed'){
      return 4;
    }else if(name == 'Wind Direction'){
      return 5;
    }else if(name == 'Leaf Wetness'){
      return 6;
    }else if(name == 'Humidity'){
      return 7;
    }else if(name == 'Lux Sensor'){
      return 8;
    }else if(name == 'Co2 Sensor'){
      return 9;
    }else{
      return 10;
    }
  }

  int moistureType(String name){
    if(name == 'primary'){
      return 1;
    }else if(name == 'secondary'){
      return 2;
    }else{
      return 0;
    }
  }
  int levelType(String name){
    if(name == 'top'){
      return 1;
    }else if(name == 'middle'){
      return 2;
    }else if(name == 'bottom'){
      return 3;
    }else{
      return 0;
    }
  }

  int injectorMode(String name){
    if(name == 'Concentration'){
      return 1;
    }else if(name == 'Ec controlled'){
      return 2;
    }else if(name == 'Ph controlled'){
      return 3;
    }else if(name == 'Regular'){
      return 4;
    }else{
      return 0;
    }
  }
  int alarmBehavior(String name){
    if(name == 'Do Nothing'){
      return 1;
    }else if(name == 'Stop Irrigation'){
      return 2;
    }else if(name == 'Stop Fertigation'){
      return 3;
    }else if(name == 'Skip Irrigation'){
      return 4;
    }else{
      return 0;
    }
  }


  //TODO: generating HW payload
  dynamic sendDataToHW(){
    var payload = {
      "300" : [
        {'301': ''},

      ]
    };
    var mv = '';
    for(var i in mainValveUpdated){
      mv += '${mv.length != 0 ? ';' : ''}${i['sNo']},${i['id']},${returnMvMode(i['mode'])},${i['delay']}';
    }
    payload['300']?.add({'302' : mv});


    var line = '';
    for(var i in irrigationLineUpdated){
      line += '${line.isNotEmpty ? ';' : ''}${i['sNo']},${i['id']},${i['pump'] == '-' ? 1 : i['pump'].split('IP')[1]},${i['leakageLimit']}';
    }
    payload['300']?.add({'303' : line});
    // payload['300']?.add({'303' : ''});


    var valve = '';
    for(var i in valveUpdated){
      for(var vl in i['valve']){
        valve += '${valve.isNotEmpty ? ';' : ''}${vl['sNo']},${vl['location']},${vl['id']},${vl['defaultDosage'] == 'Time' ? 1 : 2},${double.parse(vl['nominalFlow'])},${double.parse(vl['minimumFlow'])},${double.parse(vl['maximumFlow'])},${vl['fillUpDelay']},${vl['area']},${vl['cropFactor']}}';
      }
    }
    payload['300']?.add({'304' : valve});
    // payload['300']?.add({'304' : ''});


    var wm = '';
    for(var i in waterMeterUpdated){
      wm += '${wm.isNotEmpty ? ';' : ''}${i['sNo']},${i['location']},${i['name']},${int.parse(i['ratio'])},${int.parse(i['maximumFlow'])}';
    }
    payload['300']?.add({'305' : wm});
    // payload['300']?.add({'305' : ''});


    var fertilizer = '';
    for(var i in fertilizerUpdated){
      for(var fert in i['fertilizer']){
        fertilizer += '${fertilizer.length != 0 ? ';' : ''}'
            '${fert['sNo']},${i['id']},${fert['id'][fert['id'].length - 1]},'
            '${noFlowBehavior(i['noFlowBehavior'])},${i['minimalOnTime']},'
            '${i['minimalOffTime']},${i['boosterOffDelay']},'
            '${i['waterFlowStabilityTime']},${fert['nominalFlow']},'
            '${injectorMode(fert['injectorMode'])},${fert['ratio']},${fert['shortestPulse']}';
      }
    }
    payload['300']?.add({'306' : fertilizer});
    // payload['300']?.add({'306' : ''});


    //
    var ecPh = '';
    for(var i in ecPhUpdated){
      for(var j in i['setting']){
        ecPh += '${ecPh.length != 0 ? ';' : ''}'
            '${j['sensor'][0]['sNo']},'
            '${i['id']},'
            '${j['name'] == 'ec' ? 1 : 2},'
            '${j['active'] == true ? 1 : 0},'
            '${j['controlCycle']},'
            '${double.parse(j['delta'])},'
            '${double.parse(j['fineTunning'])},'
            '${double.parse(j['coarseTunning'])},'
            '${double.parse(j['deadBand'])},'
            '${j['integ']},'
            '${j['senseOrAvg'] == 'Average' ? '${j['sensor'][0]['id']}_${j['sensor'][1]['id']}' : j['senseOrAvg']},'
            '${int.parse(j['avgFilterSpeed'])}';
      }
    }
    payload['300']?.add({'307' : ecPh});
    // payload['300']?.add({'307' : ''});
    //
    // var filter = '';
    // for(var i in filterUpdated){
    //   filter += '${filter.length != 0 ? ';' : ''}${i['sNo']},${i['location']},${i['dpDelay']},${i['loopingLimit']},${i['whileFlushing']}';
    // }
    //
    // payload['300']?.add({'308' : filter});


    var as = '';
    for(var i in analogSensorUpdated){
      as += '${as.length != 0 ? ';' : ''}${i['sNo']},${i['name']},${analogType(i['type'])},${i['units'] == 'bar' ? 1 : 2},${i['base'] == 'Voltage' ? 1 : 0},${double.parse(i['minimum'])},${double.parse(i['maximum'])}';
    }
    payload['300']?.add({'308' : as});
    // payload['300']?.add({'308' : ''});


    var ms = '';
    for(var i in moistureSensorUpdated){
      ms += '${ms.length != 0 ? ';' : ''}'
          '${i['sNo']},'
          '${i['name']},'
          '${i['location']},'
          '${moistureType(i['high/low'])},'
          '${i['units'] == 'bar' ? 1 : 2},'
          '${i['base'] == 'Voltage' ? 1 : 0},'
          '${double.parse(i['minimum'])},'
          '${double.parse(i['maximum'])}';
    }
    // payload['300']?.add({'309' : ms});
    payload['300']?.add({'309' : ''});


    var ls = '';
    for(var i in levelSensorUpdated){
      ls += '${ls.length != 0 ? ';' : ''}'
          '${i['sNo']},'
          '${i['name']},'
          '${i['location']},'
          '${levelType(i['high/low'])},'
          '${i['units'] == 'bar' ? 1 : 2},'
          '${i['base'] == 'Voltage' ? 1 : 0},'
          '${double.parse(i['minimum'])},'
          '${double.parse(i['maximum'])}';
    }
    payload['300']?.add({'310' : ls});
    // payload['300']?.add({'310' : ''});

    var nAlarm = '';
    print(jsonEncode(alarmUpdated));
    var nTypeCount = 0;
    for(var i = 0;i < alarmUpdated.length;i++){
      var type = alarmUpdated[i]['alarm'];
      for(var j = 0;j < type.length;j++){
        nTypeCount = nTypeCount + 1;
        nAlarm += '${nAlarm.isNotEmpty ? ';' : ''}'
            '$nTypeCount,'
        // '${alarmUpdated[i]['sNo']},'
            '${alarmUpdated[i]['id']},${type[j]['name']},'
            '${type[j]['scanTime']},${alarmBehavior(type[j]['alarmOnStatus'])},'
            '${type[j]['resetAfterIrrigation'] == 'yes' ? 1 : 0},${type[j]['autoResetDuration']},${type[j]['threshold']}' ;
      }
    }
    payload['300']?.add({'311' : nAlarm});
    // payload['300']?.add({'310' : ''});


    var cAlarm = '';
    var cTypeCount = 0;
    for(var i = 0;i < criticalAlarmUpdated.length;i++){
      var type = criticalAlarmUpdated[i]['alarm'];
      for(var j = 0;j < type.length;j++){
        cTypeCount = cTypeCount + 1;
        cAlarm += '${cAlarm.isNotEmpty ? ';' : ''}'
            '$cTypeCount,'
            '${criticalAlarmUpdated[i]['id']},${type[j]['name']},'
            '${type[j]['scanTime']},${alarmBehavior(type[j]['alarmOnStatus'])},'
            '${type[j]['resetAfterIrrigation'] == 'yes' ? 1 : 0},${type[j]['autoResetDuration']},${type[j]['threshold']}' ;
      }
    }
    payload['300']?.add({'312' : cAlarm});

    print('payload : $payload');
    return payload;

  }
}