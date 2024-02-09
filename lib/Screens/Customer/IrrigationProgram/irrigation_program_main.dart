import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/program_library.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/schedule_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/selection_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/sequence_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/water_fert_screen.dart';
import 'package:provider/provider.dart';

import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import 'alarm_screen.dart';
import 'conditions_screen.dart';
import 'done_screen.dart';

class IrrigationProgram extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  final String? programType;
  final String deviceId;
  final bool? conditionsLibraryIsNotEmpty;
  const IrrigationProgram({Key? irrigationProgramKey,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    this.programType,
    this.conditionsLibraryIsNotEmpty, required this.deviceId}) :super(key: irrigationProgramKey);

  @override
  State<IrrigationProgram> createState() => _IrrigationProgramState();
}

class _IrrigationProgramState extends State<IrrigationProgram> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IrrigationProgramMainProvider irrigationProvider = IrrigationProgramMainProvider();
  bool isPressed = false;
  final HttpService httpService = HttpService();
  final delete = const SnackBar(content: Center(child: Text('The sequence is erased!')));
  final singleSelection = const SnackBar(content: Center(child: Text('Single valve selection is enabled')));
  final multipleSelection = const SnackBar(content: Center(child: Text('Multiple valve selection is enabled')));
  dynamic apiData = {};
  dynamic waterAndFertData = [];

  @override
  void initState() {
    super.initState();
    final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    irrigationProvider.doneData(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramSequence(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.scheduleData(widget.userId, widget.controllerId, widget.serialNumber);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
        getData(programPvd, widget.userId, widget.controllerId, widget.serialNumber);
      });
      irrigationProvider.updateTabIndex(0);
    }
    irrigationProvider.getUserProgramSelection(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramCondition(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.alarmDataFetched(widget.userId, widget.controllerId, widget.serialNumber);
    _tabController = TabController(
      length: (widget.serialNumber == 0
          ? irrigationProvider.isIrrigationProgram
          : widget.programType == "Irrigation Program")
          ? irrigationProvider.conditionsLibraryIsNotEmpty ? irrigationProvider.label1.length : irrigationProvider.label4.length
          : irrigationProvider.conditionsLibraryIsNotEmpty ? irrigationProvider.label2.length : irrigationProvider.label3.length,
      vsync: this,
    );

    _tabController.addListener(() {
      irrigationProvider.updateTabIndex(_tabController.index);
    });
  }

  void getData(IrrigationProgramMainProvider programPvd, userId, controllerId, serialNumber)async{
    programPvd.clearWaterFert();
    try{
      HttpService service = HttpService();
      var fert = await service.postRequest('getUserPlanningFertilizerSet', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response = await service.postRequest('getUserProgramWaterAndFert', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response1 = await service.postRequest('getUserConstant', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var jsonData = response.body;
      var jsonData1 = response1.body;
      var jsonData2 = fert.body;
      var myData = jsonDecode(jsonData);
      var myData1 = jsonDecode(jsonData1);
      var myData2 = jsonDecode(jsonData2);
      programPvd.editApiData(myData['data']['default']);
      programPvd.editSequenceData(myData['data']['waterAndFert']);
      programPvd.editRecipe(myData2['data']['fertilizerSet']['fertilizerSet']);
      programPvd.editConstantSetting(myData1['data']['constant']);
    }catch(e){
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    irrigationProvider.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    int selectedIndex = mainProvider.selectedTabIndex;

    if(mainProvider.irrigationLine != null || mainProvider.programDetails != null) {
      final program = mainProvider.programDetails!.programName.isNotEmpty
          ? mainProvider.programName == ''? "Program ${mainProvider.programCount+1}" : mainProvider.programName
          : mainProvider.programDetails!.defaultProgramName;
      return LayoutBuilder(
        builder: (context, constrains) {
          return DefaultTabController(
            length: (widget.serialNumber == 0
                ? mainProvider.isIrrigationProgram
                : widget.programType == "Irrigation Program")
                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length,
            child: Scaffold(
              appBar: AppBar(
                // title: Text(mainProvider.programName != '' ? mainProvider.programName : 'New Program'),
                title: Text(widget.serialNumber == 0 ? "New Program" : program),
                centerTitle: false,
                leading: IconButton(
                  onPressed: () {
                    mainProvider.programLibraryData(widget.userId, widget.controllerId, widget.serialNumber);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                bottom: constrains.maxWidth < 500
                    ?
                PreferredSize(
                  preferredSize: const Size.fromHeight(80.0),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.background,
                    child: TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      tabs: [
                        for (int i = 0; i <  ((widget.serialNumber == 0
                            ? mainProvider.isIrrigationProgram
                            : widget.programType == "Irrigation Program")
                            ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                            : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length); i++)
                          CustomTab(
                            height: 80,
                            label: (widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1[i] : mainProvider.label4[i]
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2[i] : mainProvider.label3[i],
                            content: (widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons1[i] : mainProvider.icons4[i]
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons2[i] : mainProvider.icons3[i],
                            tabIndex: i,
                            selectedTabIndex: mainProvider.selectedTabIndex,
                          ),
                      ],
                    ),
                  ),
                ) : null,
                actions: [
                  if (selectedIndex == 0) ...[
                    _buildIconButton(mainProvider.isSingleValveMode, Icons.fiber_manual_record_outlined, mainProvider.enableSingleValveMode, "Enable Single Valve mode"),
                    _buildIconButton(mainProvider.isMultipleValveMode, Icons.join_full_outlined, mainProvider.enableMultipleValveMode, "Enable Multiple Valve mode"),
                    // _buildIconButton(mainProvider.isNext, Icons.queue_play_next, mainProvider.enableSkipNex),
                    _buildIconButton(mainProvider.isDelete, Icons.delete, mainProvider.deleteFunction, "Delete the sequence"),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              body: Row(
                children: <Widget>[
                  if (constrains.maxWidth > 500)
                    SizedBox(
                      width: 250,
                      child: Drawer(
                        child: ListView(
                          children: [
                            for (int i = 0; i <  ((widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length); i++)
                              ListTile(
                                  title: Text((widget.serialNumber == 0
                                      ? mainProvider.isIrrigationProgram
                                      : widget.programType == "Irrigation Program")
                                      ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1[i] : mainProvider.label4[i]
                                      : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2[i] : mainProvider.label3[i],
                                    style: TextStyle(color: _tabController.index == i ? Colors.white : null),),
                                  leading: Icon((widget.serialNumber == 0
                                      ? mainProvider.isIrrigationProgram
                                      : widget.programType == "Irrigation Program")
                                      ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons1[i] : mainProvider.icons4[i]
                                      : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons2[i] : mainProvider.icons3[i],
                                    color: _tabController.index == i ? Colors.white : null,),
                                  selected: _tabController.index == i,
                                  onTap: () {
                                    _navigateToTab(i);
                                  },
                                  selectedTileColor: _tabController.index == i ? Theme.of(context).primaryColor : null,
                                  hoverColor: _tabController.index == i ? Theme.of(context).primaryColor : null
                              ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children:  [
                        for (
                        int i = 0;
                        i < ((widget.serialNumber == 0
                            ? mainProvider.isIrrigationProgram
                            : widget.programType == "Irrigation Program")
                            ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                            : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length);
                        i++)
                          _buildTabContent(i, (widget.serialNumber == 0
                              ? mainProvider.isIrrigationProgram
                              : widget.programType == "Irrigation Program"), mainProvider.conditionsLibraryIsNotEmpty),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: _buildFloatingActionButton(selectedIndex),
            ),
          );
        },
      );
    } else {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }
  }

  Widget _buildTabContent(int index, bool isIrrigationProgram, conditionsLibraryIsNotEmpty) {
    if (isIrrigationProgram) {
      if(conditionsLibraryIsNotEmpty) {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return SelectionScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return WaterAndFertScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 5:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 6:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      } else {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return SelectionScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return WaterAndFertScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 5:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      }
    } else {
      if(conditionsLibraryIsNotEmpty) {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      } else {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      }
    }
  }

  Widget? _buildFloatingActionButton(int selectedIndex)  {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    var dataToMqtt = {};
    var userData = {
      "defaultProgramName": mainProvider.defaultProgramName,
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "createUser": widget.userId,
      "serialNumber": widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber,
    };
    if(selectedIndex == ((widget.serialNumber == 0
        ? mainProvider.isIrrigationProgram
        : widget.programType == "Irrigation Program")
        ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length - 1 : mainProvider.label4.length - 1
        : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length - 1 : mainProvider.label3.length - 1)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            key: UniqueKey(),
            onPressed: () async{
              mainProvider.dataToWF();
              if(mainProvider.irrigationLine!.sequence.isNotEmpty) {
                var dataToSend = {
                  "sequence": mainProvider.irrigationLine!.sequence,
                  "schedule": mainProvider.sampleScheduleModel!.toJson(),
                  "conditions": mainProvider.sampleConditions!.toJson(),
                  "waterAndFert": mainProvider.serverDataWM,
                  "selection": mainProvider.selectionModel.data!.toJson(),
                  "alarm": mainProvider.alarmData!.toJson(),
                  "programName": mainProvider.programName,
                  "priority": mainProvider.priority,
                  "delayBetweenZones": mainProvider.programDetails!.delayBetweenZones,
                  "adjustPercentage": mainProvider.programDetails!.adjustPercentage,
                  "incompleteRestart": mainProvider.isCompletionEnabled ? "1" : "0",
                  "programType": mainProvider.selectedProgramType,
                  "hardware": dataToMqtt
                };
                dataToMqtt = {
                  "2500" : [
                    mainProvider.dataToMqtt(widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber),
                  ],
                };
                userData.addAll(dataToSend);
                try {
                  final createUserProgram = await httpService.postRequest('createUserProgram', userData);
                  final response = jsonDecode(createUserProgram.body);
                  MQTTManager().publish(dataToMqtt.toString(), "AppToFirmware/${widget.deviceId}");
                  if(createUserProgram.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProgramLibraryScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,)),
                    );
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
                  print("Error: $error");
                }
                // print(mainProvider.selectionModel.data!.localFertilizerSet!.map((e) => e.toJson()));
              }
              else {
                showAdaptiveDialog<Future>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                      title: 'Warning',
                      content: "Select valves to be sequence for Irrigation Program",
                      actions: [
                        TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                      ],
                    );
                  },
                );
              }
            },
            // child: const Icon(Icons.send),
            child: const Text('http'),
          ),
          const SizedBox(width: 10,),
          OutlinedButton(
            key: UniqueKey(),
            onPressed: () async{
              var userDataToMqtt = {
                "700": {
                  widget.userId,
                  widget.controllerId,
                }
              };
              MQTTManager().publish(userDataToMqtt.toString(), "AppToFirmware/12345");
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Sent successfully'));
            },
            child: const Text('Mqtt'),
          )
        ],
      );
    } else {
      return null;
      // return Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     FloatingActionButton(
      //         onPressed: () {},
      //         child: const Text('Back'),
      //         backgroundColor: Colors.red
      //     ),
      //     const SizedBox(width: 20,),
      //     FloatingActionButton(
      //         onPressed: () {},
      //         child: const Text('Next'),
      //         backgroundColor: Colors.green
      //     ),
      //   ],
      // );
    }
  }

  Widget _buildIconButton(bool isActive, IconData iconData, VoidCallback onPressed, toolTip) {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: toolTip,
        onPressed: () {
          if (iconData == Icons.delete) {
            showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: 'Verify to delete',
                  content: 'Are you sure to erase the sequence?',
                  actions: [
                    TextButton(
                      child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        setState(() {
                          mainProvider.deleteButton();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'The sequence is erased!'));
                          // CustomOverlayWidget.showOverlay(context, "The sequence is erased!");
                        });
                      },
                    ),
                  ],
                );
              },
            );
          } else if (iconData == Icons.fiber_manual_record_outlined) {
            // ScaffoldMessenger.of(context).showSnackBar(singleSelection);
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Single valve selection is enabled'));
            // CustomOverlayWidget.showOverlay(context, "Single valve selection is enabled");
            onPressed();
          } else if(iconData == Icons.join_full_outlined){
            // ScaffoldMessenger.of(context).showSnackBar(multipleSelection);
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Multiple valve selection is enabled'));
            // CustomOverlayWidget.showOverlay(context, "Multiple valve selection is enabled");
            onPressed();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Enabled to add next sequence'));
            // CustomOverlayWidget.showOverlay(context, "Multiple valve selection is enabled");
            onPressed();
          }
        },
        icon: Icon(
          iconData,
          color: isActive ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
    );
  }
}
