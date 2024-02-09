import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../../state_management/schedule_view_provider.dart';
import '../../widgets/SCustomWidgets/custom_date_picker.dart';
import '../../widgets/SCustomWidgets/custom_drop_down.dart';
import '../../widgets/SCustomWidgets/custom_snack_bar.dart';

class ScheduleViewScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int customerId;
  final String deviceId;
  const ScheduleViewScreen({super.key, required this.userId, required this.controllerId, required this.deviceId, required this.customerId});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  HttpService httpService = HttpService();
  late MQTTManager manager;
  late ScheduleViewProvider scheduleViewProvider;

  @override
  void initState() {
    super.initState();
    manager = MQTTManager();
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: false);
    scheduleViewProvider.payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 1500), () {
      scheduleViewProvider.requestScheduleData(widget.deviceId);
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if(scheduleViewProvider.scheduleList.isNotEmpty) {
        scheduleViewProvider.scheduleList = scheduleViewProvider.scheduleList;
      } else {
        scheduleViewProvider.getUserSequencePriority(widget.userId, widget.controllerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: true);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Schedule View"),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Text("Select a Date"),
                        const SizedBox(
                          width: 20,
                        ),
                        Card(
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DatePickerField(
                                  value: scheduleViewProvider.date,
                                  onChanged: (newDate) {
                                    setState(() {
                                      scheduleViewProvider.date = newDate;
                                    });
                                    scheduleViewProvider.fetchDataAfterDelay(widget.deviceId);
                                  }),
                            )),
                      ],
                    ),
                    if(scheduleViewProvider.scheduleList.isNotEmpty)
                      Row(
                        children: [
                          const Text("Change To"),
                          const SizedBox(width: 20,),
                          Card(
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                height: 40,
                                width: 50,
                                child: CustomDropdownWidget(
                                  dropdownItems: scheduleViewProvider.scheduleList.map((e) => e["ScheduleOrder"].toString()).toList(),
                                  selectedValue: scheduleViewProvider.changeToValue != ""
                                      ? scheduleViewProvider.changeToValue : scheduleViewProvider.scheduleList[0]["ScheduleOrder"].toString(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      scheduleViewProvider.changeToValue = newValue!;
                                      int changeToIndex = scheduleViewProvider.scheduleList.indexWhere((element) => element["ScheduleOrder"].toString() == scheduleViewProvider.changeToValue);
                                      scheduleViewProvider.scheduleList = [
                                        ...scheduleViewProvider.scheduleList.sublist(changeToIndex),
                                        ...scheduleViewProvider.scheduleList.sublist(0, changeToIndex)
                                      ];
                                    });
                                  },
                                  includeNoneOption: false,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
                scheduleViewProvider.scheduleList.isNotEmpty ?
                Expanded(
                    child: ReorderableListView.builder(
                        itemCount: scheduleViewProvider.scheduleList.length,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = scheduleViewProvider.scheduleList.removeAt(oldIndex);
                            scheduleViewProvider.scheduleList.insert(newIndex, item);
                          });
                          scheduleViewProvider.changeToValue = scheduleViewProvider.scheduleList[0]["ScheduleOrder"].toString();
                        },
                        proxyDecorator: (widget, animation, index) {
                          return Transform.scale(
                            scale: 0.95,
                            child: widget,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final scheduleItem = scheduleViewProvider.scheduleList[index];
                          var method = scheduleItem["IrrigationMethod"].toString();
                          var inputValue = scheduleItem["IrrigationDuration_Quantity"].toString();
                          var completedValue = method == "1"
                              ? scheduleItem["IrrigationDurationCompleted"].toString()
                              : scheduleItem["IrrigationQuantityCompleted"].toString();
                          var pumps = scheduleItem['Pump'];
                          var mainValves = scheduleItem['MainValve'];
                          var valves = scheduleItem['SequenceData'];
                          var toLeftDuration;
                          var progressValue;
                          if (method == "1") {
                            List<String> inputTimeParts = inputValue.split(':');
                            int inHours = int.parse(inputTimeParts[0]);
                            int inMinutes = int.parse(inputTimeParts[1]);
                            int inSeconds = int.parse(inputTimeParts[2]);

                            List<String> timeComponents = completedValue.split(':');
                            int hours = int.parse(timeComponents[0]);
                            int minutes = int.parse(timeComponents[1]);
                            int seconds = int.parse(timeComponents[2]);

                            Duration inDuration = Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
                            Duration completedDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);

                            toLeftDuration = (inDuration - completedDuration).toString().substring(0,7);
                            progressValue = completedDuration.inMilliseconds / inDuration.inMilliseconds;
                          } else {
                            progressValue = int.parse(completedValue) / int.parse(inputValue);
                            toLeftDuration = int.parse(inputValue) - int.parse(completedValue);
                          }
                          return Column(
                            key: ValueKey<int>(int.parse(scheduleItem["ScheduleOrder"].toString())),
                            children: [
                              buildScheduleList(
                                  scheduleItem["ScheduleOrder"].toString(),
                                  scheduleItem["ProgramName"].toString(),
                                  scheduleItem["ZoneName"].toString(),
                                  scheduleItem["Status"].toString(),
                                  inputValue,
                                  completedValue,
                                  toLeftDuration,
                                  progressValue,
                                  pumps,
                                  mainValves,
                                  valves,
                                  scheduleViewProvider.scheduleList,
                                  scheduleViewProvider.scheduleList,
                                  index
                              ),
                              if(index == scheduleViewProvider.scheduleList.length - 1)
                                const SizedBox(height: 50,)
                            ],
                          );
                        }
                    )
                ): const Text("User schedule priority not found")
              ],
            ),
            floatingActionButton: OutlinedButton(
              onPressed: () async{
                var userData = {
                  "userId": widget.userId,
                  "controllerId": widget.controllerId,
                  "modifyUser": widget.customerId,
                  "sequence": scheduleViewProvider.scheduleList,
                  "scheduleDate": DateFormat('yyyy/MM/dd').format(scheduleViewProvider.date)
                };
                var listToMqtt = [];
                for (var i = 0; i < scheduleViewProvider.scheduleList.length; i++) {
                  final scheduleItem = scheduleViewProvider.scheduleList[i];
                  String scheduleMap = ""
                      "${scheduleItem["S_No"]},"
                      "${i+1},"
                      "${scheduleItem["ScaleFactor"]},"
                      "${scheduleItem["SkipFlag"]}"
                      "";
                  listToMqtt.add(scheduleMap);
                }
                var dataToHardware = {
                  "2700": [{
                    "2701": "${listToMqtt.join(";").toString()};"
                  }]
                };
                try {
                  final updateUserSequencePriority = await httpService.postRequest('updateUserSequencePriority', userData);
                  final response = jsonDecode(updateUserSequencePriority.body);
                  Future<void>.delayed(const Duration(milliseconds: 1500),() {
                    manager.publish(dataToHardware.toString(), "AppToFirmware/${widget.deviceId}");
                  });
                  if(updateUserSequencePriority.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
                  print("Error: $error");
                }
              },
              child: const Text("Save"),
            ),
          );
        });
  }

  Widget buildScheduleList(
      String sno,
      String programName,
      String zoneName,
      String statusCode,
      String inputValue,
      String completedValue,
      toLeftDuration,
      progressValue,
      pumps,
      mainValves,
      valves,
      scaleFactor,
      skipFlag,
      index) {
    StatusInfo getStatusInfo(code) {
      Color innerCircleColor;
      String statusString;

      switch (code) {
        case "0":
          innerCircleColor = Colors.grey;
          statusString = "Pending";
          break;
        case "1":
          innerCircleColor = Colors.orange;
          statusString = "Running";
          break;
        case "2":
          innerCircleColor = Colors.green;
          statusString = "Completed";
          break;
        case "3":
          innerCircleColor = Colors.yellow;
          statusString = "Skipped by user";
          break;
        case "4":
          innerCircleColor = Colors.orangeAccent;
          statusString = "Day schedule pending";
          break;
        case "5":
          innerCircleColor = const Color(0xFF0D5D9A);
          statusString = "Day schedule running";
          break;
        case "6":
          innerCircleColor = Colors.yellowAccent;
          statusString = "Day schedule completed";
          break;
        case "7":
          innerCircleColor = Colors.red;
          statusString = "Day schedule skipped";
          break;
        case "8":
          innerCircleColor = Colors.redAccent;
          statusString = "Postponed partially to tomorrow";
          break;
        case "9":
          innerCircleColor = Colors.green;
          statusString = "Postponed fully to tomorrow";
          break;
        case "10":
          innerCircleColor = Colors.amberAccent;
          statusString = "RTC off time reached";
          break;
        case "11":
          innerCircleColor = Colors.amber;
          statusString = "RTC max time reached";
          break;
        default:
          throw Exception("Unsupported status code: $code");
      }

      return StatusInfo(innerCircleColor, statusString);
    }

    var status = getStatusInfo(statusCode);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: status.color)
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 0.5),
                      color: Colors.white),
                  child: Center(
                      child: Text(
                        sno,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ))),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programName,
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(zoneName),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.statusString,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Completed: $completedValue",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Actual: $inputValue",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "To left: $toLeftDuration",
                    style: const TextStyle(fontSize: 12),
                  ),
                  MouseRegion(
                    onHover: (onHover) {},
                    child: Tooltip(
                      message: completedValue,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                              Border.all(width: 0.3, color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                          child: LinearProgressIndicator(
                            value: progressValue.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            valueColor:
                            AlwaysStoppedAnimation<Color>(status.color),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pumps),
                    const Text("Pumps", style: TextStyle(fontSize: 12),)
                  ],
                )),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainValves),
                    const Text("Main Valves", style: TextStyle(fontSize: 12),)
                  ],
                )),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(valves.split('+').join(', ').toString()),
                    const Text("Valves", style: TextStyle(fontSize: 12),)
                  ],
                )),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 30,
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        initialValue: scaleFactor[index]["ScaleFactor"].toString(),
                        onChanged: (newValue){
                          setState(() {
                            scaleFactor[index]["ScaleFactor"] = newValue != '' ? newValue : scaleFactor[index]["ScaleFactor"];
                          });
                        },
                      ),
                    ),
                    // Text(scaleFactor),
                    const Text("Scale Factor", style: TextStyle(fontSize: 12),)
                  ],
                )),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 1,
                child: Center(
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          skipFlag[index]["SkipFlag"] = skipFlag[index]["SkipFlag"] == 0 ? 1 : 0;
                        });
                      },
                      child: Text(skipFlag[index]["SkipFlag"] == 0 ? "Skip" : "Un skip",
                        // style: TextStyle(color: skipFlag[index]["SkipFlag"] == 0 ? Colors.red : null),
                      )),
                )),
          ],
        ),
      ),
    );
  }
}

class StatusInfo {
  final Color color;
  final String statusString;

  StatusInfo(this.color, this.statusString);
}
