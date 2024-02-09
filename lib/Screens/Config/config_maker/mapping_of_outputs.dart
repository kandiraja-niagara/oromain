import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/drop_down_button.dart';



class MappingOfOutputsTable extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  MappingOfOutputsTable({super.key,required this.configPvd});

  @override
  State<MappingOfOutputsTable> createState() => _MappingOfOutputsTableState();
}

class _MappingOfOutputsTableState extends State<MappingOfOutputsTable> {
  bool odd = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context,constrainst){
      var width = constrainst.maxWidth;
      return Container(
        color: Color(0xFFF3F3F3),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 5,right: 5,top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Obj',),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                            left: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('RTU',),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ref.no',),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('O/P',),
                          Text('relays',),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.more_vert)
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        border: Border(
                          top: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                          right: BorderSide(width: 1),
                        )
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 5,right: 5),
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: getIrrigationLine(irrigationLine(configPvd),configPvd),
                      ),
                      Column(
                        children: getCentralDosing(centralDosing(configPvd),configPvd),
                      ),
                      Column(
                        children: getCentralFiltration(centralFiltration(configPvd),configPvd),
                      ),
                      Column(
                        children: getSourcePump(sourcePump(configPvd),configPvd),
                      ),
                      Column(
                        children: getIrrigationPump(irrigationPump(configPvd),configPvd),
                      ),
                      Column(
                        children: getAgitator(agitator(configPvd),configPvd),
                      ),
                      Column(
                        children: getSelector(selector(configPvd),configPvd),
                      ),
                      SizedBox(height: 150,),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });

  }

  List<Widget> getIrrigationLine(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(!myList[i]['map'][0]['deleted']){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.white : Colors.white70,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? 1 : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: getRtuName(configPvd,myList[i]['map'][j]['connection']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                          ),
                        )
                    ),
                    if(['injector','boosterConnection','valveConnection','main_valveConnection','foggerConnection','fanConnection','filterConnection'].contains(myList[i]['map'][j]['connection']))
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border(
                              top:  BorderSide(width: j == 0 ? 1 : 0),
                              right: BorderSide(width: 1),
                            )
                        ),
                        child: IconButton(
                            onPressed: (){
                              configPvd.irrigationLinesFunctionality(['deleteFromMapio',i,myList[i]['map'][j]['connection'],myList[i]['map'][j]['sNo']]);
                            },
                            icon: Icon(Icons.delete)
                        ),
                      )
                    else
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              border: Border(
                                top:  BorderSide(width: j == 0 ? 1 : 0),
                                right: BorderSide(width: 1),
                              )
                          ),
                          child: notAvailable
                      )
                  ],
                ),
              )
          );
        }
      }
    }
    return widgetList;
  }
  List<Widget> getCentralDosing(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(!myList[i]['map'][0]['deleted']){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.yellow.shade50 : Colors.yellow.shade100,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? 1 : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: getRtuName(configPvd,myList[i]['map'][j]['connection']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                          ),
                        )
                    ),
                    if(['injector','boosterConnection'].contains(myList[i]['map'][j]['connection']))
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border(
                              top:  BorderSide(width: j == 0 ? 1 : 0),
                              right: BorderSide(width: 1),
                            )
                        ),
                        child: IconButton(
                            onPressed: (){
                              configPvd.centralDosingFunctionality(['deleteFromMapio',i,myList[i]['map'][j]['connection'],myList[i]['map'][j]['sNo']]);
                            },
                            icon: Icon(Icons.delete)
                        ),
                      )
                    else
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              border: Border(
                                top:  BorderSide(width: j == 0 ? 1 : 0),
                                right: BorderSide(width: 1),
                              )
                          ),
                          child: notAvailable
                      )
                  ],
                ),
              )
          );
        }
      }

    }
    return widgetList;
  }
  List<Widget> getCentralFiltration(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(!myList[i]['map'][0]['deleted']){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.green.shade50 : Colors.green.shade100,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? 1 : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: getRtuName(configPvd,myList[i]['map'][j]['connection']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                          ),
                        )
                    ),
                    if(['filterConnection'].contains(myList[i]['map'][j]['connection']))
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border(
                              top:  BorderSide(width: j == 0 ? 1 : 0),
                              right: BorderSide(width: 1),
                            )
                        ),
                        child: IconButton(
                            onPressed: (){
                              configPvd.centralFiltrationFunctionality(['deleteFromMapio',i,myList[i]['map'][j]['connection'],myList[i]['map'][j]['sNo']]);
                            },
                            icon: Icon(Icons.delete)
                        ),
                      )
                    else
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              border: Border(
                                top:  BorderSide(width: j == 0 ? 1 : 0),
                                right: BorderSide(width: 1),
                              )
                          ),
                          child: notAvailable
                      )

                  ],
                ),
              )
          );
        }
      }

    }
    return widgetList;
  }
  List<Widget> getSourcePump(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(!myList[i]['map'][0]['deleted']){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.lightGreen.shade50 : Colors.lightGreen.shade100,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    if(myList[i]['map'][j]['oroPump'] == true)
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                            ),
                            height: 40,
                            child: Center(
                              child: Text('${myList[i]['map'][j]['rtu']}',style: TextStyle(fontSize: 11),),
                            ),
                          )
                      )
                    else
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                            ),
                            height: 40,
                            child: Center(
                                child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: myList[i]['map'][j]['oroPump'] == false ? getRtuName(configPvd,myList[i]['map'][j]['connection']) : ['-','ORO Pump'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                            ),
                          )
                      ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                          ),
                        )
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border(
                              top:  BorderSide(width: j == 0 ? 1 : 0),
                              right: BorderSide(width: 1),
                            )
                        ),
                        child: notAvailable
                    )

                  ],
                ),
              )
          );
        }
      }

    }
    return widgetList;
  }
  List<Widget> getIrrigationPump(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(!myList[i]['map'][0]['deleted']){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.brown.shade50 : Colors.brown.shade100,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    if(myList[i]['map'][j]['oroPump'] == true)
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                            ),
                            height: 40,
                            child: Center(
                              child: Text('${myList[i]['map'][j]['rtu']}',style: TextStyle(fontSize: 11),),
                            ),
                          )
                      )
                    else
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                            ),
                            height: 40,
                            child: Center(
                                child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: myList[i]['map'][j]['oroPump'] == false ? getRtuName(configPvd,myList[i]['map'][j]['connection']) : ['-','ORO Pump'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                            ),
                          )
                      ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                          ),
                        )
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border(
                              top:  BorderSide(width: j == 0 ? 1 : 0),
                              right: BorderSide(width: 1),
                            )
                        ),
                        child: notAvailable
                    )

                  ],
                ),
              )
          );
        }
      }

    }
    return widgetList;
  }
  List<Widget> getAgitator(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: getRtuName(configPvd,myList[i]['map'][j]['connection']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                        ),
                      )
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        border: Border(
                          top:  BorderSide(width: j == 0 ? 1 : 0),
                          right: BorderSide(width: 1),
                        )
                    ),
                    child: IconButton(
                        onPressed: (){
                          configPvd.mappingOfOutputsFunctionality(['agitatorDelete',j,]);
                        },
                        icon: Icon(Icons.delete)
                    ),
                  )
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getSelector(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: getRtuName(configPvd,myList[i]['map'][j]['connection']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['output']}', itemList: getOutPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['output']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/output', index: -1),
                        ),
                      )
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        border: Border(
                          top:  BorderSide(width: j == 0 ? 1 : 0),
                          right: BorderSide(width: 1),
                        )
                    ),
                    child: IconButton(
                        onPressed: (){
                          configPvd.mappingOfOutputsFunctionality(['selectorDelete',j,]);
                        },
                        icon: Icon(Icons.delete)
                    ),
                  )
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<String> getRtuName(ConfigMakerProvider configPvd,name){
    var list = ['-'];
    if(configPvd.totalRTU != 0){
      list.add('ORO RTU');
    }
    if(configPvd.totalRtuPlus != 0){
      list.add('O-RTU-Plus');
    }
    if(configPvd.totalOroSmartRTU != 0){
      list.add('ORO Smart');
    }
    if(configPvd.totalOroSmartRtuPlus != 0){
      list.add('O-Smart-Plus');
    }
    if(configPvd.totalOroSwitch != 0){
      list.add('ORO Switch');
    }
    if(configPvd.totalOroPump != 0){
      list.add('ORO Pump');
    }
    if(configPvd.oPumpPlus.length != 0){
      list.add('O-Pump-Plus');
    }
    if(configPvd.totalOroLevel != 0){
      list.add('ORO Level');
    }

    if(configPvd.totalOroSense != 0){
      list.add('ORO Sense');
    }
    if(['valveConnection','main_valveConnection','foggerConnection','fanConnection','water_meter','pressureIn','pressureOut','injector','dosingMeter','boosterConnection','ecConnection','phConnection','pressureSwitch','filterConnection','dv','diffPressureSensor','pumpConnection'].contains(name)){
      list.remove('ORO Sense');
      list.remove('ORO Level');
      list.remove('ORO Pump');
      list.remove('O-Pump-Plus');
      list.remove('ORO Switch');

    }else if(['levelSensorConnection','levelSensor'].contains(name)){
      list.remove('ORO Sense');
      list.remove('ORO Pump');
      list.remove('O-Pump-Plus');
      list.remove('ORO RTU');
      list.remove('ORO Smart');
      list.remove('O-RTU-Plus');
      list.remove('ORO Switch');
    }else if(['moistureSensorConnection'].contains(name)){
      list.remove('ORO Level');
      list.remove('ORO Pump');
      list.remove('O-Pump-Plus');
      list.remove('ORO Switch');
      list.remove('ORO RTU');
      list.remove('ORO Smart');
      list.remove('O-Smart-Plus');
    }
    return list;
  }
  List<String> getrefNoForOthers(ConfigMakerProvider configPvd,String title){
    List<String> myList = ['-'];
    if(title == 'ORO Smart'){
      var list = configPvd.oSrtu;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'O-Smart-Plus'){
      var list = configPvd.oSrtuPlus;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO Switch'){
      var list = configPvd.oSwitch;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO Sense'){
      var list = configPvd.oSense;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO RTU'){
      var list = configPvd.oRtu;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'O-RTU-Plus'){
      var list = configPvd.oRtuPlus;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO Pump'){
      var list = configPvd.oPump;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'O-Pump-Plus'){
      var list = configPvd.oPumpPlus;
      for(var i in list){
        myList.add('$i');
      }
    }
    return myList;
  }
  // List<String> getrefNo(int line,ConfigMakerProvider configPvd,String title){
  //   List<String> myList = ['-'];
  //   if(title == 'ORO Smart'){
  //     for(var i in configPvd.irrigationLines[line]['myOroSmartRtu']){
  //       myList.add('${i}');
  //     }
  //   }else if(title == 'O-Smart-Plus'){
  //     for(var i in configPvd.irrigationLines[line]['myOroSmartRtuPlus']){
  //       myList.add('${i}');
  //     }
  //   }else if(title == 'ORO Switch'){
  //     for(var i in configPvd.irrigationLines[line]['myOROswitch']){
  //       myList.add('${i}');
  //     }
  //   }else if(title == 'ORO Sense'){
  //     for(var i in configPvd.irrigationLines[line]['myOROsense']){
  //       myList.add('${i}');
  //     }
  //   }else if(title == 'ORO RTU'){
  //     for(var i in configPvd.irrigationLines[line]['myRTU']){
  //       myList.add('${i}');
  //     }
  //   }else if(title == 'O-RTU-Plus'){
  //     for(var i in configPvd.irrigationLines[line]['myRtuPlus']){
  //       myList.add('${i}');
  //     }
  //   }
  //
  //   return myList;
  // }
  List<String> filterOutPut(List<dynamic> data,String rtu,String rf,String output){
    List<String> list = [];
    for(var i in data){
      if((i['rtu'] == rtu) && (i['rfNo'] == rf)){
        if(i['output'] != '-' && output != i['output']){
          list.add(i['output']);
        }
      }
    }
    return list;
  }
  List<String> filterCt(List<dynamic> data,String rtu,String rf,String ct){
    List<String> list = [];
    for(var i in data){
      if((i['rtu'] == rtu) && (i['rfNo'] == rf)){
        if(i['current_selection'] != '-' && ct != i['current_selection']){
          list.add(i['current_selection']);
        }
      }
    }
    return list;
  }

  List<String> getOutPut(ConfigMakerProvider configPvd,String rtu, String rf, String output,int index) {
    List<String> myList = [];
    List<String> filterList = [];
    if(rtu == 'ORO RTU'){
      for(var i = 0;i < 8;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'O-RTU-Plus'){
      for(var i = 0;i < 8;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'ORO Pump'){
      for(var i = 0;i < 4;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'O-Pump-Plus'){
      for(var i = 0;i < 4;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'ORO Smart'){
      for(var i = 0;i < 8;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'O-Smart-Plus'){
      for(var i = 0;i < 16;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'ORO Switch'){
      for(var i = 0;i < 4;i++){
        myList.add('R${i+1}');
      }
    }else if(rtu == 'ORO Sense'){
      for(var i = 0;i < 4;i++){
        myList.add('R${i+1}');
      }
    }
    if(rtu != '-' && rf != '-'){
      for(var i in configPvd.sourcePumpUpdated){
        if(i['oro_pump'] == true || i['oro_pump_plus'] == true){
          if(i['on'] != null){
            filterList.addAll(filterOutPut([i['on']],rtu,rf,output));
          }
          if(i['off'] != null){
            filterList.addAll(filterOutPut([i['off']],rtu,rf,output));
          }
          if(i['scr'] != null){
            filterList.addAll(filterOutPut([i['scr']],rtu,rf,output));
          }
          if(i['ecr'] != null){
            filterList.addAll(filterOutPut([i['ecr']],rtu,rf,output));
          }
        }else{
          if(i['pumpConnection'] != null){
            filterList.addAll(filterOutPut([i['pumpConnection']],rtu,rf,output));
          }
        }
      }
      for(var i in configPvd.irrigationPumpUpdated){
        if(i['oro_pump'] == true || i['oro_pump_plus'] == true ){
          if(i['on'] != null){
            filterList.addAll(filterOutPut([i['on']],rtu,rf,output));
          }
          if(i['off'] != null){
            filterList.addAll(filterOutPut([i['off']],rtu,rf,output));
          }
          if(i['scr'] != null){
            filterList.addAll(filterOutPut([i['scr']],rtu,rf,output));
          }
          if(i['ecr'] != null){
            filterList.addAll(filterOutPut([i['ecr']],rtu,rf,output));
          }
        }else{
          if(i['pumpConnection'] != null){
            filterList.addAll(filterOutPut([i['pumpConnection']],rtu,rf,output));
          }
        }
      }
      filterList.addAll(filterOutPut(configPvd.totalAgitator,rtu,rf,output));
      filterList.addAll(filterOutPut(configPvd.totalSelector,rtu,rf,output));
      for(var i in configPvd.centralFiltrationUpdated){
        filterList.addAll(filterOutPut(i['filterConnection'],rtu,rf,output));
        filterList.addAll(filterOutPut([i['dv']],rtu,rf,output));
      }
      for(var i in configPvd.centralDosingUpdated){
        filterList.addAll(filterOutPut(i['injector'],rtu,rf,output));
        filterList.addAll(filterOutPut(i['boosterConnection'],rtu,rf,output));
      }
      for(var i in configPvd.irrigationLines){
        filterList.addAll(filterOutPut(i['valveConnection'],rtu,rf,output));
        filterList.addAll(filterOutPut(i['main_valveConnection'],rtu,rf,output));
        filterList.addAll(filterOutPut(i['foggerConnection'],rtu,rf,output));
        filterList.addAll(filterOutPut(i['fanConnection'],rtu,rf,output));
      }
      for(var i in configPvd.localFiltrationUpdated){
        filterList.addAll(filterOutPut(i['filterConnection'],rtu,rf,output));
        filterList.addAll(filterOutPut([i['dv']],rtu,rf,output));
      }
      for(var i in configPvd.localDosingUpdated){
        filterList.addAll(filterOutPut(i['injector'],rtu,rf,output));
        filterList.addAll(filterOutPut(i['boosterConnection'],rtu,rf,output));
      }
    }
    for(var i in filterList){
      if(myList.contains(i)){
        myList.remove(i);
      }
    }
    myList.insert(0, '-');
    return rf == '-' ? ['-'] : myList;
  }
  List<Map<String,dynamic>> irrigationLine(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.irrigationLines.length;i++){
      myList.add(
          {
            'name' : 'Irrigation Line ${i+1}',
            'map' : [],
          }
      );
      for(var valve = 0;valve < configPvd.irrigationLines[i]['valveConnection'].length;valve++){
        myList[i]['map'].add(
            {
              'name' : 'valve',
              'type' : 'm_o_line',
              'line' : i,
              'count' : valve,
              'connection' : 'valveConnection',
              'sNo' :  configPvd.irrigationLines[i]['valveConnection'][valve]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['valveConnection'][valve]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['valveConnection'][valve]['rfNo'],
              'output' : configPvd.irrigationLines[i]['valveConnection'][valve]['output'],
              'deleted' : configPvd.irrigationLines[i]['deleted'],
            }
        );
      }
      for(var mainValve = 0;mainValve < configPvd.irrigationLines[i]['main_valveConnection'].length;mainValve++){
        myList[i]['map'].add(
            {
              'name' : 'mainValve',
              'type' : 'm_o_line',
              'line' : i,
              'count' : mainValve,
              'connection' : 'main_valveConnection',
              'sNo' :  configPvd.irrigationLines[i]['main_valveConnection'][mainValve]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['main_valveConnection'][mainValve]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['main_valveConnection'][mainValve]['rfNo'],
              'output' : configPvd.irrigationLines[i]['main_valveConnection'][mainValve]['output'],
              'deleted' : configPvd.irrigationLines[i]['deleted'],
            }
        );
      }
      for(var fogger = 0;fogger < configPvd.irrigationLines[i]['foggerConnection'].length;fogger++){
        myList[i]['map'].add(
            {
              'name' : 'fogger',
              'type' : 'm_o_line',
              'line' : i,
              'count' : fogger,
              'connection' : 'foggerConnection',
              'sNo' :  configPvd.irrigationLines[i]['foggerConnection'][fogger]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['foggerConnection'][fogger]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['foggerConnection'][fogger]['rfNo'],
              'output' : configPvd.irrigationLines[i]['foggerConnection'][fogger]['output'],
              'deleted' : configPvd.irrigationLines[i]['deleted'],
            }
        );
      }
      for(var fan = 0;fan < configPvd.irrigationLines[i]['fanConnection'].length;fan++){
        myList[i]['map'].add(
            {
              'name' : 'fan',
              'type' : 'm_o_line',
              'line' : i,
              'count' : fan,
              'connection' : 'fanConnection',
              'sNo' :  configPvd.irrigationLines[i]['fanConnection'][fan]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['fanConnection'][fan]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['fanConnection'][fan]['rfNo'],
              'output' : configPvd.irrigationLines[i]['fanConnection'][fan]['output'],
              'deleted' : configPvd.irrigationLines[i]['deleted'],
            }
        );
      }
      if(configPvd.irrigationLines[i]['Local_dosing_site'] == true){
        localDosing : for(var ld = 0;ld < configPvd.localDosingUpdated.length;ld++){
          if(configPvd.localDosingUpdated[ld]['sNo'] == configPvd.irrigationLines[i]['sNo']){
            for(var injector = 0;injector < configPvd.localDosingUpdated[ld]['injector'].length;injector++){
              myList[i]['map'].add(
                  {
                    'name' : 'injector',
                    'type' : 'm_o_localDosing',
                    'line' : i,
                    'count' : injector,
                    'connection' : 'injector',
                    'sNo' :  configPvd.localDosingUpdated[ld]['injector'][injector]['sNo'],
                    'rtu' :  configPvd.localDosingUpdated[ld]['injector'][injector]['rtu'],
                    'rfNo' : configPvd.localDosingUpdated[ld]['injector'][injector]['rfNo'],
                    'output' : configPvd.localDosingUpdated[ld]['injector'][injector]['output'],
                    'deleted' : configPvd.irrigationLines[i]['deleted'],
                  }
              );
            }
            for(var boosterPump = 0;boosterPump < configPvd.localDosingUpdated[ld]['boosterConnection'].length;boosterPump++){
              myList[i]['map'].add(
                  {
                    'name' : 'Booster',
                    'type' : 'm_o_localDosing',
                    'line' : i,
                    'count' : boosterPump,
                    'connection' : 'boosterConnection',
                    'sNo' :  configPvd.localDosingUpdated[ld]['boosterConnection'][boosterPump]['sNo'],
                    'rtu' :  configPvd.localDosingUpdated[ld]['boosterConnection'][boosterPump]['rtu'],
                    'rfNo' : configPvd.localDosingUpdated[ld]['boosterConnection'][boosterPump]['rfNo'],
                    'output' : configPvd.localDosingUpdated[ld]['boosterConnection'][boosterPump]['output'],
                    'deleted' : configPvd.irrigationLines[i]['deleted'],
                  }
              );
            }
            break localDosing;
          }
        }
      }
      if(configPvd.irrigationLines[i]['local_filtration_site'] == true){
        localFiltration : for(var ld = 0;ld < configPvd.localFiltrationUpdated.length;ld++){
          if(configPvd.localFiltrationUpdated[ld]['sNo'] == configPvd.irrigationLines[i]['sNo']){
            for(var filter = 0;filter < configPvd.localFiltrationUpdated[ld]['filterConnection'].length;filter++){
              myList[i]['map'].add(
                  {
                    'name' : 'filter',
                    'type' : 'm_o_localFiltration',
                    'line' : i,
                    'count' : filter,
                    'connection' : 'filterConnection',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['filterConnection'][filter]['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['filterConnection'][filter]['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['filterConnection'][filter]['rfNo'],
                    'output' : configPvd.localFiltrationUpdated[ld]['filterConnection'][filter]['output'],
                    'deleted' : configPvd.irrigationLines[i]['deleted'],
                  }
              );
            }
            if(configPvd.localFiltrationUpdated[ld]['dv'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'd_valve',
                    'type' : 'm_o_localFiltration',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'dv',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['dv']['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['dv']['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['dv']['rfNo'],
                    'output' : configPvd.localFiltrationUpdated[ld]['dv']['output'],
                    'deleted' : configPvd.irrigationLines[i]['deleted'],
                  }
              );
            }

            break localFiltration;
          }
        }
      }

    }
    return myList;
  }
  List<Map<String,dynamic>> centralDosing(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.centralDosingUpdated.length;i++){
      myList.add(
          {
            'name' : 'Central Dosing Site ${i+1}',
            'map' : [],
          }
      );
      for(var injector = 0;injector < configPvd.centralDosingUpdated[i]['injector'].length;injector++){
        myList[i]['map'].add(
            {
              'name' : 'injector',
              'type' : 'm_o_centralDosing',
              'site' : i,
              'count' : injector,
              'connection' : 'injector',
              'sNo' :  configPvd.centralDosingUpdated[i]['injector'][injector]['sNo'],
              'rtu' :  configPvd.centralDosingUpdated[i]['injector'][injector]['rtu'],
              'rfNo' : configPvd.centralDosingUpdated[i]['injector'][injector]['rfNo'],
              'output' : configPvd.centralDosingUpdated[i]['injector'][injector]['output'],
              'deleted' : configPvd.centralDosingUpdated[i]['deleted'],
            }
        );
      }
      for(var boosterPump = 0;boosterPump < configPvd.centralDosingUpdated[i]['boosterConnection'].length;boosterPump++){
        myList[i]['map'].add(
            {
              'name' : 'Booster',
              'type' : 'm_o_centralDosing',
              'line' : i,
              'count' : boosterPump,
              'connection' : 'boosterConnection',
              'sNo' :  configPvd.centralDosingUpdated[i]['boosterConnection'][boosterPump]['sNo'],
              'rtu' :  configPvd.centralDosingUpdated[i]['boosterConnection'][boosterPump]['rtu'],
              'rfNo' : configPvd.centralDosingUpdated[i]['boosterConnection'][boosterPump]['rfNo'],
              'output' : configPvd.centralDosingUpdated[i]['boosterConnection'][boosterPump]['output'],
              'deleted' : configPvd.centralDosingUpdated[i]['deleted'],
            }
        );
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> centralFiltration(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.centralFiltrationUpdated.length;i++){
      myList.add(
          {
            'name' : 'Central Filtration Site ${i+1}',
            'map' : [],
          }
      );
      for(var filter = 0;filter < configPvd.centralFiltrationUpdated[i]['filterConnection'].length;filter++){
        myList[i]['map'].add(
            {
              'name' : 'filter',
              'type' : 'm_o_centralFiltration',
              'line' : i,
              'count' : filter,
              'connection' : 'filterConnection',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['filterConnection'][filter]['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['filterConnection'][filter]['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['filterConnection'][filter]['rfNo'],
              'output' : configPvd.centralFiltrationUpdated[i]['filterConnection'][filter]['output'],
              'deleted' : configPvd.centralFiltrationUpdated[i]['deleted'],
            }
        );
      }
      if(configPvd.centralFiltrationUpdated[i]['dv'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'd_valve',
              'type' : 'm_o_centralFiltration',
              'line' : i,
              'count' : -1,
              'connection' : 'dv',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['dv']['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['dv']['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['dv']['rfNo'],
              'output' : configPvd.centralFiltrationUpdated[i]['dv']['output'],
              'deleted' : configPvd.centralFiltrationUpdated[i]['deleted'],
            }
        );
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> sourcePump(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.sourcePumpUpdated.length;i++){
      myList.add(
          {
            'name' : 'Source Pump ${i+1}',
            'map' : [],
          }
      );
      if(configPvd.sourcePumpUpdated[i]['oro_pump'] == false && configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == false){
        myList[i]['map'].add(
            {
              'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
              'name' : 'pump',
              'type' : 'm_o_sourcePump',
              'pump' : i,
              'count' : -1,
              'connection' : 'pumpConnection',
              'sNo' :  configPvd.sourcePumpUpdated[i]['pumpConnection']['sNo'],
              'rtu' :  configPvd.sourcePumpUpdated[i]['pumpConnection']['rtu'],
              'rfNo' : configPvd.sourcePumpUpdated[i]['pumpConnection']['rfNo'],
              'output' : configPvd.sourcePumpUpdated[i]['pumpConnection']['output'],
              'deleted' : configPvd.sourcePumpUpdated[i]['deleted'],
            }
        );
      }

      if(configPvd.sourcePumpUpdated[i]['oro_pump'] == true || configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == true){
        if(configPvd.sourcePumpUpdated[i]['on'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.sourcePumpUpdated[i]['oro_pump'] == true || configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'on',
                'type' : 'm_o_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'on',
                'sNo' :  configPvd.sourcePumpUpdated[i]['on']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['on']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['on']['rfNo'],
                'output' : configPvd.sourcePumpUpdated[i]['on']['output'],
                'deleted' : configPvd.sourcePumpUpdated[i]['deleted'],
              }
          );
        }
        if(configPvd.sourcePumpUpdated[i]['off'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.sourcePumpUpdated[i]['oro_pump'] == true || configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'off',
                'type' : 'm_o_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'off',
                'sNo' :  configPvd.sourcePumpUpdated[i]['off']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['off']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['off']['rfNo'],
                'output' : configPvd.sourcePumpUpdated[i]['off']['output'],
                'deleted' : configPvd.sourcePumpUpdated[i]['deleted'],
              }
          );
        }
        if(configPvd.sourcePumpUpdated[i]['scr'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.sourcePumpUpdated[i]['oro_pump'] == true || configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'scr',
                'type' : 'm_o_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'scr',
                'sNo' :  configPvd.sourcePumpUpdated[i]['scr']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['scr']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['scr']['rfNo'],
                'output' : configPvd.sourcePumpUpdated[i]['scr']['output'],
                'deleted' : configPvd.sourcePumpUpdated[i]['deleted'],
              }
          );
        }
        if(configPvd.sourcePumpUpdated[i]['ecr'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.sourcePumpUpdated[i]['oro_pump'] == true || configPvd.sourcePumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'ecr',
                'type' : 'm_o_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'ecr',
                'sNo' :  configPvd.sourcePumpUpdated[i]['ecr']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['ecr']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['ecr']['rfNo'],
                'output' : configPvd.sourcePumpUpdated[i]['ecr']['output'],
                'deleted' : configPvd.sourcePumpUpdated[i]['deleted'],
              }
          );
        }
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> irrigationPump(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.irrigationPumpUpdated.length;i++){
      myList.add(
          {
            'name' : 'Irrigation Pump ${i+1}',
            'map' : [],
          }
      );
      if(configPvd.irrigationPumpUpdated[i]['oro_pump'] == false && configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == false){
        myList[i]['map'].add(
            {
              'oroPump' : (configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
              'name' : 'pump',
              'type' : 'm_o_irrigationPump',
              'pump' : i,
              'count' : -1,
              'connection' : 'pumpConnection',
              'sNo' :  configPvd.irrigationPumpUpdated[i]['pumpConnection']['sNo'],
              'rtu' :  configPvd.irrigationPumpUpdated[i]['pumpConnection']['rtu'],
              'rfNo' : configPvd.irrigationPumpUpdated[i]['pumpConnection']['rfNo'],
              'output' : configPvd.irrigationPumpUpdated[i]['pumpConnection']['output'],
              'c-type' : configPvd.irrigationPumpUpdated[i]['pumpConnection']['current_selection'],
              'deleted' : configPvd.irrigationPumpUpdated[i]['deleted']
            }
        );
      }

      if(configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true){
        if(configPvd.irrigationPumpUpdated[i]['on'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'on',
                'type' : 'm_o_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'on',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['on']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['on']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['on']['rfNo'],
                'output' : configPvd.irrigationPumpUpdated[i]['on']['output'],
                'c-type' : configPvd.irrigationPumpUpdated[i]['on']['current_selection'],
                'deleted' : configPvd.irrigationPumpUpdated[i]['deleted']
              }
          );
        }
        if(configPvd.irrigationPumpUpdated[i]['off'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'off',
                'type' : 'm_o_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'off',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['off']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['off']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['off']['rfNo'],
                'output' : configPvd.irrigationPumpUpdated[i]['off']['output'],
                'c-type' : configPvd.irrigationPumpUpdated[i]['off']['current_selection'],
                'deleted' : configPvd.irrigationPumpUpdated[i]['deleted']
              }
          );
        }
        if(configPvd.irrigationPumpUpdated[i]['scr'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true) == true ? true : false,
                'name' : 'scr',
                'type' : 'm_o_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'scr',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['scr']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['scr']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['scr']['rfNo'],
                'output' : configPvd.irrigationPumpUpdated[i]['scr']['output'],
                'c-type' : configPvd.irrigationPumpUpdated[i]['scr']['current_selection'],
                'deleted' : configPvd.irrigationPumpUpdated[i]['deleted']

              }
          );
        }
        if(configPvd.irrigationPumpUpdated[i]['ecr'] != null){
          myList[i]['map'].add(
              {
                'oroPump' : (configPvd.irrigationPumpUpdated[i]['oro_pump'] == true || configPvd.irrigationPumpUpdated[i]['oro_pump_plus'] == true) ? true : false,
                'name' : 'ecr',
                'type' : 'm_o_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'ecr',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['ecr']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['ecr']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['ecr']['rfNo'],
                'output' : configPvd.irrigationPumpUpdated[i]['ecr']['output'],
                'c-type' : configPvd.irrigationPumpUpdated[i]['ecr']['current_selection'],
                'deleted' : configPvd.irrigationPumpUpdated[i]['deleted']
              }
          );
        }
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> agitator(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    myList.add(
        {
          'name' : 'Agitator',
          'map' : [],
        }
    );
    for(var i = 0;i < configPvd.totalAgitator.length;i++){
      myList[0]['map'].add(
          {
            'name' : 'AG ${i+1}',
            'type' : 'm_o_agitator',
            'agitator' : i,
            'count' : i,
            'connection' : 'totalAgitator',
            'sNo' :  configPvd.totalAgitator[i]['sNo'],
            'rtu' :  configPvd.totalAgitator[i]['rtu'],
            'rfNo' : configPvd.totalAgitator[i]['rfNo'],
            'output' : configPvd.totalAgitator[i]['output'],
          }
      );
    }
    return myList;
  }
  List<Map<String,dynamic>> selector(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    myList.add(
        {
          'name' : 'Selector',
          'map' : [],
        }
    );
    for(var i = 0;i < configPvd.totalSelector.length;i++){
      myList[0]['map'].add(
          {
            'name' : 'Sl ${i+1}',
            'type' : 'm_o_selector',
            'agitator' : i,
            'count' : i,
            'connection' : 'totalSelector',
            'sNo' :  configPvd.totalSelector[i]['sNo'],
            'rtu' :  configPvd.totalSelector[i]['rtu'],
            'rfNo' : configPvd.totalSelector[i]['rfNo'],
            'output' : configPvd.totalSelector[i]['output'],
          }
      );
    }
    return myList;
  }

}
