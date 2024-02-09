import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_animated_switcher.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';

class SelectionScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const SelectionScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final Map<int, GlobalKey> itemKeys = {};
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final selectionPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: true);
    Widget buildCard(itemList, String subtitle,) {

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subtitle,),
                        SizedBox(
                            height: 50,
                            child: (subtitle != "EC Sensors For local"
                                && subtitle != "EC Sensors For central"
                                && subtitle != "Local Fertilizer Set"
                                && subtitle != "Central Fertilizer Set"
                                && subtitle != "Central Fertilizer Injector"
                                && subtitle != "Local Fertilizer Injector"
                                && subtitle != "pH Sensors For central"
                                && subtitle != "pH Sensors For local"
                                && subtitle != "Central Filter"
                                && subtitle != "Local Filter") ?
                            ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.horizontal,
                                itemCount: itemList.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text((subtitle != 'Selector for central fertilizer' && subtitle != 'Selector for local fertilizer')
                                            ? '${itemList[index].name}'
                                            : 'Selector ${index+1}',
                                            style: const TextStyle(fontSize: 15)
                                        ),
                                        selected : itemList[index].selected ?? false,
                                        selectedColor: Theme.of(context).colorScheme.secondary,
                                        onSelected: (bool selected) {
                                          selectionPvd.selectItem(index, subtitle);
                                        },
                                      ),
                                      const SizedBox(width: 5,)
                                    ],
                                  );
                                }
                            ) :
                            ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...itemList.map((ecSensor) {
                                  final name = ecSensor.name;

                                  return Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text('$name', style: const TextStyle(fontSize: 15)),
                                        selected: ecSensor.selected ?? false,
                                        selectedColor: Theme.of(context).colorScheme.secondary,
                                        onSelected: (bool selected) {
                                          selectionPvd.updateSelectedItem(subtitle, ecSensor.id);
                                        },
                                      ),
                                      const SizedBox(width: 5,)
                                    ],
                                  );
                                })
                              ],
                            )
                          // Container()
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 5,)
                ],
              ),
            ),
          );
        },
      );
    }

    Widget buildDropdownContainer(String title, String selectedValue, List<String> dropdownItems, onChanged, icon) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: CustomDropdownTile(
            title: title,
            showCircleAvatar: true,
            dropdownItems: dropdownItems,
            selectedValue: selectedValue,
            onChanged: onChanged,
            content: icon,
            includeNoneOption: false,
          ),
        ),
      );
    }

    Widget buildSwitchContainer(String title, bool value, Function(bool) onChanged, icon, subtitle, showSubTitle) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: CustomSwitchTile(
            title: title,
            showCircleAvatar: true,
            icon: Icon(icon, color: Colors.black,),
            showSubTitle: showSubTitle,
            subtitle: subtitle,
            onChanged: onChanged,
            value: value,
          ),
        ),
      );
    }

    if (selectionPvd.selectionModel.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var centralSetCondition = (selectionPvd.selectionModel.data!.centralFertilizerSet!.isNotEmpty) ?
            selectionPvd.selectionModel.data!.centralFertilizerSet!
                .where((fertilizerSet) =>
                selectionPvd.selectionModel.data!.centralFertilizerSite!
                    .any((site) =>
                site.id == (fertilizerSet.recipe.isNotEmpty
                    ? fertilizerSet.recipe.first.location
                    : null) &&
                    site.selected == true))
                .isNotEmpty : false;
            var centralInjectorCondition = (selectionPvd.selectionModel.data!.centralFertilizerSet!.isNotEmpty) ?
            selectionPvd.selectionModel.data!.centralFertilizerInjector!
                .where((injector) =>
                selectionPvd.selectionModel.data!.centralFertilizerSite!
                    .any((site) =>
                site.id ==  injector.location && site.selected == true)).isNotEmpty : false;
            var localInjectorCondition = (selectionPvd.selectionModel.data!.localFertilizerSite!.isNotEmpty) ?
            selectionPvd.selectionModel.data!.localFertilizerInjector!
                .where((injector) =>
                selectionPvd.selectionModel.data!.localFertilizerSite!
                    .any((site) =>
                site.id ==  injector.location && site.selected == true)).isNotEmpty : false;
            var localSetCondition = selectionPvd.selectionModel.data!.localFertilizerSet!.isNotEmpty
                ? selectionPvd.selectionModel.data!.localFertilizerSet!
                .where((fertilizerSet) =>
                selectionPvd.selectionModel.data!.localFertilizerSite!
                    .any((site) =>
                site.id == (fertilizerSet.recipe.isNotEmpty
                    ? fertilizerSet.recipe.first.location
                    : null) &&
                    site.selected == true))
                .isNotEmpty
                : false;
            var ecSensorSelectionCentralCondition = selectionPvd.selectionModel.data!.ecSensor!.isNotEmpty ?
            selectionPvd.selectionModel.data!.ecSensor!
                .where((ecSensor) => selectionPvd.selectionModel.data!.centralFertilizerSite!
                .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false;
            var ecSensorSelectionLocalCondition = selectionPvd.selectionModel.data!.ecSensor!.isNotEmpty ?
            selectionPvd.selectionModel.data!.ecSensor!
                .where((ecSensor) => selectionPvd.selectionModel.data!.localFertilizerSite!
                .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false;
            var pHSensorSelectionCentralCondition = selectionPvd.selectionModel.data!.phSensor!.isNotEmpty ?
            selectionPvd.selectionModel.data!.phSensor!
                .where((phSensor) => selectionPvd.selectionModel.data!.centralFertilizerSite!
                .any((site) => site.id == phSensor.location && site.selected == true)).isNotEmpty : false;
            var pHSensorSelectionLocalCondition = selectionPvd.selectionModel.data!.phSensor!.isNotEmpty ?selectionPvd.selectionModel.data!.phSensor!
                .where((phSensor) => selectionPvd.selectionModel.data!.localFertilizerSite!
                .any((site) => site.id == phSensor.location && site.selected == true)).isNotEmpty : false;
            // print(centralInjectorCondition);
            return ListView(
              padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                const SizedBox(height: 10),
                selectionPvd.selectionModel.data!.mainValve!.isNotEmpty ?
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("MAIN VALVE SELECTION",),
                    ),
                    buildCard(
                      selectionPvd.selectionModel.data!.mainValve!,
                      'List of Valves',),
                    const SizedBox(height: 10),
                  ],
                ) : Container(),
                selectionPvd.selectionModel.data!.irrigationPump!.isNotEmpty ?
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("PUMP SELECTION"),
                    ),
                    buildSwitchContainer(
                        "Pump Station Mode",
                        selectionPvd.isPumpStationMode,
                            (newValue) => selectionPvd.updatePumpStationMode(newValue, "Pump Station Mode"),
                        Icons.local_gas_station,
                        selectionPvd.isPumpStationMode ? "Automatic pump selection" : "Manual pump selection",
                        true
                    ),
                    selectionPvd.isPumpStationMode ? const SizedBox(height: 10) : Container(),
                    selectionPvd.selectionModel.data!.irrigationPump!.isNotEmpty
                        ? CustomAnimatedSwitcher(
                      condition: !selectionPvd.isPumpStationMode,
                      child: buildCard(selectionPvd.selectionModel.data!.irrigationPump!, 'List of Pump',),)
                        : Container(),
                    !selectionPvd.isPumpStationMode ? const SizedBox(height: 10) : Container(),
                  ],
                ) : Container(),
                selectionPvd.selectionModel.data!.centralFertilizerSite!.isNotEmpty ?
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("FERTILIZER SELECTION"),
                    ),
                    (selectionPvd.selectionModel.data!.centralFertilizerSite!.isNotEmpty)
                        ? buildCard(selectionPvd.selectionModel.data!.centralFertilizerSite!,'Central Fertilizer Site',)
                        : Container(),
                    (selectionPvd.selectionModel.data!.selectorForCentral!.isNotEmpty)
                        ? CustomAnimatedSwitcher(
                      condition: selectionPvd.selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true),
                      child: buildCard(
                        selectionPvd.selectionModel.data!.selectorForCentral,'Selector for central fertilizer',),
                    )
                        : Container(),
                    (selectionPvd.selectionModel.data!.localFertilizerSite!.isNotEmpty)
                        ? buildCard(selectionPvd.selectionModel.data!.localFertilizerSite!,'Local Fertilizer Site',) : Container(),
                    (selectionPvd.selectionModel.data!.selectorForLocal!.isNotEmpty)
                        ? CustomAnimatedSwitcher(
                      condition: selectionPvd.selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true),
                      child: buildCard(
                        selectionPvd.selectionModel.data!.selectorForLocal,'Selector for local fertilizer',),
                    )
                        : Container(),
                    CustomAnimatedSwitcher(
                        condition: (selectionPvd.selectionModel.data!.centralFertilizerInjector!.isNotEmpty
                            && selectionPvd.selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true))
                            || (selectionPvd.selectionModel.data!.localFertilizerInjector!.isNotEmpty
                                && selectionPvd.selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)),
                        child: Column(
                          children: [
                            buildSwitchContainer(
                                "Program based Injector selection",
                                selectionPvd.isProgramBasedInjector,
                                    (newValue) => selectionPvd.updatePumpStationMode(newValue, "Program based Injector selection"),
                                Icons.toggle_on,
                                selectionPvd.isProgramBasedInjector ? "Program based Injector selection is enabled" : "Zone based Injector selection is enabled",
                                false
                            ),
                            (selectionPvd.selectionModel.data!.centralFertilizerInjector!.isNotEmpty)
                                ? CustomAnimatedSwitcher(
                              condition: centralInjectorCondition && selectionPvd.isProgramBasedInjector,
                              child: buildCard(
                                  selectionPvd.selectionModel.data!.centralFertilizerInjector!
                                      .where((injector) =>
                                      selectionPvd.selectionModel.data!.centralFertilizerSite!
                                          .any((site) =>
                                      site.id ==  injector.location && site.selected == true)).expand((element) => [element]),'Central Fertilizer Injector'),
                            )
                                : Container(),
                            (selectionPvd.selectionModel.data!.localFertilizerInjector!.isNotEmpty)
                                ? CustomAnimatedSwitcher(
                              condition: localInjectorCondition && selectionPvd.isProgramBasedInjector,
                              child: buildCard(
                                selectionPvd.selectionModel.data!.localFertilizerInjector!
                                    .where((injector) =>
                                    selectionPvd.selectionModel.data!.localFertilizerSite!
                                        .any((site) =>
                                    site.id ==  injector.location && site.selected == true)).expand((element) => [element]),'Local Fertilizer Injector',),
                            )
                                : Container(),
                            (selectionPvd.selectionModel.data!.localFertilizerInjector!.isNotEmpty) ? const SizedBox(height: 10,) : Container(),
                          ],
                        )
                    ),
                  ],
                ) : Container(),
                (selectionPvd.selectionModel.data!.centralFertilizerSet!.isNotEmpty || selectionPvd.selectionModel.data!.localFertilizerSet!.isNotEmpty) ?
                CustomAnimatedSwitcher(
                  condition: centralSetCondition || localSetCondition,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("FERTILIZER SET SELECTION"),
                      ),
                      buildSwitchContainer(
                          "Program based set selection",
                          selectionPvd.isProgramBasedSet,
                              (newValue) => selectionPvd.updatePumpStationMode(newValue, "Program based set selection"),
                          Icons.toggle_on,
                          selectionPvd.isProgramBasedSet ? "Program based set selection is enabled" : "Zone based set selection is enabled",
                          false
                      ),
                      (selectionPvd.selectionModel.data!.centralFertilizerSet!.isNotEmpty)
                          ?
                      CustomAnimatedSwitcher(
                        condition: centralSetCondition && selectionPvd.isProgramBasedSet,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.centralFertilizerSet!
                              .where((fertilizerSet) =>
                              selectionPvd.selectionModel.data!.centralFertilizerSite!
                                  .any((site) =>
                              site.id == (fertilizerSet.recipe.isNotEmpty
                                  ? fertilizerSet.recipe.first.location
                                  : null) && site.selected == true)
                          ).map((fertilizerSet) => fertilizerSet.recipe)
                              .expand((recipeList) => recipeList),'Central Fertilizer Set',
                        ),
                      ) : Container(),
                      CustomAnimatedSwitcher(
                        condition: localSetCondition && selectionPvd.isProgramBasedSet,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.localFertilizerSet!
                              .where((fertilizerSet) =>
                              selectionPvd.selectionModel.data!.localFertilizerSite!
                                  .any((site) =>
                              site.id == (fertilizerSet.recipe.isNotEmpty
                                  ? fertilizerSet.recipe.first.location
                                  : null) && site.selected == true)
                          ).map((fertilizerSet) => fertilizerSet.recipe)
                              .expand((recipeList) => recipeList),'Local Fertilizer Set',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
                    : Container(),
                selectionPvd.selectionModel.data!.ecSensor!.isNotEmpty ?
                CustomAnimatedSwitcher(
                  condition: selectionPvd.selectionModel.data!.centralFertilizerSite!.any((site) => site.selected == true)
                      || selectionPvd.selectionModel.data!.localFertilizerSite!.any((site) => site.selected == true),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("EC SENSOR SELECTION"),
                      ),
                      CustomAnimatedSwitcher(
                        condition: ecSensorSelectionCentralCondition,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.ecSensor!.where((ecSensor) =>
                              selectionPvd.selectionModel.data!.centralFertilizerSite!.any((site) =>
                              site.id == ecSensor.location && site.selected == true)),'EC Sensors For central',
                        ),
                      ),
                      CustomAnimatedSwitcher(
                        condition: ecSensorSelectionLocalCondition,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.ecSensor!.where((ecSensor) =>
                              selectionPvd.selectionModel.data!.localFertilizerSite!.any((site) =>
                              site.id == ecSensor.location && site.selected == true)),'EC Sensors For local',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
                    : Container(),
                selectionPvd.selectionModel.data!.phSensor!.isNotEmpty ?
                CustomAnimatedSwitcher(
                  condition: selectionPvd.selectionModel.data!.centralFertilizerSite!.any((site) => site.selected == true)
                      || selectionPvd.selectionModel.data!.localFertilizerSite!.any((site) => site.selected == true),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("PH SENSOR SELECTION"),
                      ),
                      CustomAnimatedSwitcher(
                        condition: pHSensorSelectionCentralCondition,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.phSensor!.where((phSensor) =>
                              selectionPvd.selectionModel.data!.centralFertilizerSite!.any((site) =>
                              site.id == phSensor.location && site.selected == true)),'pH Sensors For central',
                        ),
                      ),
                      CustomAnimatedSwitcher(
                        condition: pHSensorSelectionLocalCondition,
                        child: buildCard(
                          selectionPvd.selectionModel.data!.phSensor!.where((phSensor) =>
                              selectionPvd.selectionModel.data!.localFertilizerSite!.any((site) =>
                              site.id == phSensor.location && site.selected == true)),'pH Sensors For local',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ) : Container(),
                (selectionPvd.selectionModel.data!.centralFilterSite!.isNotEmpty || selectionPvd.selectionModel.data!.localFilter!.isNotEmpty) ?
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("FILTER SELECTION"),
                    ),
                    (selectionPvd.selectionModel.data!.centralFilterSite!.isNotEmpty)
                        ? buildCard(
                      selectionPvd.selectionModel.data!.centralFilterSite!, 'Central Filter Site',)
                        : Container(),
                    (selectionPvd.selectionModel.data!.centralFilter!.isNotEmpty)
                        ? CustomAnimatedSwitcher(
                      condition: selectionPvd.selectionModel.data!.centralFilterSite!.any((site) => site.selected == true),
                      child: buildCard(
                        selectionPvd.selectionModel.data!.centralFilter!.where((element) =>
                            selectionPvd.selectionModel.data!.centralFilterSite!.any((site) => site.selected == true && site.id == element.location)),
                        'Central Filter',),
                    )
                        : Container(),
                    (selectionPvd.selectionModel.data!.localFilterSite!.isNotEmpty)
                        ? buildCard(
                      selectionPvd.selectionModel.data!.localFilterSite!, 'Local Filter Site',)
                        : Container(),
                    (selectionPvd.selectionModel.data!.localFilter!.isNotEmpty)
                        ? CustomAnimatedSwitcher(
                      condition: selectionPvd.selectionModel.data!.localFilter!.any((element) =>
                          selectionPvd.selectionModel.data!.localFilterSite!.any((site) => site.selected == true && site.id == element.location)),
                      child: buildCard(
                        selectionPvd.selectionModel.data!.localFilter!.where((element) =>
                            selectionPvd.selectionModel.data!.localFilterSite!.any((site) => site.selected == true && site.id == element.location)),
                        'Local Filter',),
                    )
                        : Container(),
                    buildDropdownContainer(
                        "Central Filtration Operation Mode",
                        selectionPvd.selectedCentralFiltrationMode,
                        selectionPvd.filtrationModes,
                            (newValue) => selectionPvd.updateFiltrationMode(newValue, true),
                        selectionPvd.selectedCentralFiltrationMode == selectionPvd.filtrationModes[0]
                            ? Icons.timer
                            : selectionPvd.selectedCentralFiltrationMode == selectionPvd.filtrationModes[1]
                            ? Icons.compress_outlined
                            : Icons.toggle_on
                    ),
                    buildDropdownContainer(
                        "Local Filtration Operation Mode",
                        selectionPvd.selectedLocalFiltrationMode,
                        selectionPvd.filtrationModes,
                            (newValue) => selectionPvd.updateFiltrationMode(newValue, false),
                        selectionPvd.selectedLocalFiltrationMode == selectionPvd.filtrationModes[0]
                            ? Icons.timer
                            : selectionPvd.selectedLocalFiltrationMode == selectionPvd.filtrationModes[1]
                            ? Icons.compress_outlined
                            : Icons.toggle_on
                    ),
                    buildSwitchContainer(
                        "Central Filtration Beginning Only",
                        selectionPvd.centralFiltBegin,
                            (newValue) => selectionPvd.updateFiltBegin(newValue, true),
                        Icons.filter_alt,
                        selectionPvd.centralFiltBegin ? "Description" : "Description",
                        false
                    ),
                    buildSwitchContainer(
                        "Local Filtration Beginning Only",
                        selectionPvd.localFiltBegin,
                            (newValue) => selectionPvd.updateFiltBegin(newValue, false),
                        Icons.filter_center_focus_outlined,
                        selectionPvd.localFiltBegin ? "Local Filtration Beginning Only is enabled" : "Local Filtration Beginning Only is disabled",
                        false
                    ),
                    const SizedBox(height: 10),
                  ],
                ) :
                Container()
              ],
            );
          }
      );
    }
  }
}