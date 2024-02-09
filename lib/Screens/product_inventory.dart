import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/src/response.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/customer_product.dart';
import '../Models/product_inventrory_model.dart';
import '../Models/product_model.dart';
import '../Models/product_stock.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';

enum SampleItem { itemOne, itemTwo}

class ProductInventory extends StatefulWidget {
  const ProductInventory({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  State<ProductInventory> createState() => ProductInventoryState();
}

class ProductInventoryState extends State<ProductInventory> {

  String userID = '0';
  int userType = 0;
  List<ProductListModel> productInventoryList = [];
  List<ProductListModel> filterProductInventoryList = [];

  List<CustomerProductModel> productInventoryListCus = [];
  List<CustomerProductModel> filterProductInventoryListCus = [];

  SampleItem? selectedMenu;

  List<String> jsonDataByImeiNo = [];
  String searchedChipName = '';
  bool filterActive = false;
  bool searched = false;

  int totalProduct = 0;
  int totalCategory = 0;
  int totalModel = 0;
  int outOfStockModel = 0;

  int batchSize = 30;
  int currentSet = 1;

  bool isNextButtonEnabled = true;
  bool isPreviousButtonEnabled = false;

  String jsonOptions = '';
  late Map<String, dynamic> jsonDataMap;

  bool visibleLoading = false;

  late List<DropdownMenuEntry<PrdModel>> selectedModel;
  List<PrdModel> activeModelList = <PrdModel>[];
  int sldModID = 0;
  String mdlDis = 'Product Description';
  PrdModel? initialSelectedModel;
  int indexOfInitialSelection = 0;


  late List<DropdownMenuEntry<ProductStockModel>> ddCategoryList;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  String rplMdl = '-', rplImeiNo = '-';


  @override
  void initState() {
    super.initState();
    ddCategoryList =  <DropdownMenuEntry<ProductStockModel>>[];
    selectedModel =  <DropdownMenuEntry<PrdModel>>[];
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    indicatorViewShow();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userId') ?? "";
      userType = int.parse(prefs.getString('userType') ?? "");
    });
    getProductList(currentSet, batchSize);
    fetchCatModAndImeiData();
    getProductStock();
  }

  Future<void> getProductList(int set, int limit) async {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null, "set":set, "limit":limit} :
    {"fromUserId": null, "toUserId": userID, "set":set, "limit":limit};
    print(body);
    Response response;
    if(userType == 3){
      response = await HttpService().postRequest("getCustomerProduct", body);
    }else{
      response = await HttpService().postRequest("getProduct", body);
    }

    if (response.statusCode == 200)
    {
      if(jsonDecode(response.body)["code"]==200)
      {
        setState(()
        {
          totalProduct = jsonDecode(response.body)["data"]["totalProduct"];

          if(userType != 3){
            totalCategory = jsonDecode(response.body)["data"]["totalCategory"];
            totalModel = jsonDecode(response.body)["data"]["totalModel"];
            outOfStockModel = jsonDecode(response.body)["data"]["outOfStockModel"];
            productInventoryList = (jsonDecode(response.body)["data"]["product"] as List).map((data) => ProductListModel.fromJson(data)).toList();
            isNextButtonEnabled = productInventoryList.length >= limit;
          }
          else{
            productInventoryListCus = (jsonDecode(response.body)["data"]["product"] as List).map((data) => CustomerProductModel.fromJson(data)).toList();
            isNextButtonEnabled = productInventoryListCus.length >= limit;
          }

          isPreviousButtonEnabled = currentSet > 1;
          indicatorViewHide();
        });

      }

      indicatorViewHide();

    }else {
      //_showSnackBar(response.body);
      indicatorViewHide();
    }
  }

  Future<void> fetchCatModAndImeiData() async {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null} : {"fromUserId": null, "toUserId": userID};
    final response = await HttpService().postRequest("getFilterCategoryModelAndImei", body);
    if (response.statusCode == 200) {
      final jsonDCode = json.decode(response.body)["data"];

      setState(() {
        jsonDataMap = json.decode(response.body);
        List<dynamic> dynamicImeiList = jsonDCode['imei'];
        jsonDataByImeiNo = List<String>.from(dynamicImeiList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchFilterData(dynamic categoryId, dynamic modelId, dynamic deviceId) async {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null, "categoryId": categoryId, "modelId": modelId, "deviceId": deviceId} : {"fromUserId": null, "toUserId": userID, "categoryId": categoryId, "modelId": modelId, "deviceId": deviceId};
    final response = await HttpService().postRequest("getFilteredProduct", body);
    if (response.statusCode == 200)
    {
      if(jsonDecode(response.body)["code"]==200)
      {
        setState(() {
          searched = true;
          if(userType==3){
            filterProductInventoryListCus = (jsonDecode(response.body)["data"] as List).map((data) => CustomerProductModel.fromJson(data)).toList();
          }else{
            filterProductInventoryList = (jsonDecode(response.body)["data"] as List).map((data) => ProductListModel.fromJson(data)).toList();
          }
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> getProductStock() async {
    Map<String, dynamic> body = {"fromUserId" : null, "toUserId" : userID};
    final response = await HttpService().postRequest("getProductStock", body);
    if (response.statusCode == 200)
    {
      productStockList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          productStockList.add(ProductStockModel.fromJson(cntList[i]));
        }
      }

      ddCategoryList =  <DropdownMenuEntry<ProductStockModel>>[];
      for (final ProductStockModel index in productStockList) {
        ddCategoryList.add(DropdownMenuEntry<ProductStockModel>(value: index, label: index.imeiNo));
      }

      setState(() {
        ddCategoryList;
      });

    }
    else{
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Product Inventory'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              totalProduct > 50 ?Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<dynamic>(
                    icon: const Icon(Icons.filter_alt_outlined),
                    tooltip: 'filter by category or model',
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuEntry<dynamic>> menuItems = [];
                      menuItems.add(
                        const PopupMenuItem<dynamic>(
                          enabled: false,
                          child: Text("Category"),
                        ),
                      );

                      List<dynamic> categoryItems = jsonDataMap['data']['category'];
                      menuItems.addAll(
                        categoryItems.map((dynamic item) {
                          return PopupMenuItem<dynamic>(
                            value: item,
                            child: Text(item['categoryName']),
                          );
                        }),
                      );
                      menuItems.add(
                        const PopupMenuItem<dynamic>(
                          enabled: false,
                          child: Text("Model"),
                        ),
                      );
                      List<dynamic> modelItems = jsonDataMap['data']['model'];
                      menuItems.addAll(
                        modelItems.map((dynamic item) {
                          return PopupMenuItem<dynamic>(
                            value: item,
                            child: Text('${item['categoryName']} - ${item['modelName']}'),
                          );
                        }),
                      );

                      return menuItems;
                    },
                    onSelected: (dynamic selectedItem) {
                      if (selectedItem is Map<String, dynamic>) {
                        filterActive = true;
                        if (selectedItem.containsKey('categoryName') && selectedItem.containsKey('modelName')) {
                          setState(() {
                            searchedChipName = '${selectedItem['categoryName']} - ${selectedItem['modelName']}';
                            fetchFilterData(null, selectedItem['modelId'], null);
                          });
                        } else {
                          setState(() {
                            searchedChipName = '${selectedItem['categoryName']}';
                            fetchFilterData(selectedItem['categoryId'], null, null);
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 10,),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'search by imei number',
                    onPressed: () {
                      setState(() {
                        showSearch(
                          context: context,
                          delegate: SearchPage<String>(
                            items: jsonDataByImeiNo,
                            searchLabel: 'Search items',
                            searchStyle: const TextStyle(color: Colors.white),
                            itemEndsWith: true,
                            suggestion: const Center(
                              child: Text('Filter items by typing'),
                            ),
                            failure: const Center(
                              child: Text('No items found'),
                            ),
                            filter: (String term) {
                              return jsonDataByImeiNo.where((item) => item.toLowerCase().contains(term.toLowerCase())).toList();
                            },
                            builder: (String item) {
                              return ListTile(
                                title: Text(item),
                                onTap: () {
                                  Navigator.of(context).pop(item);
                                  setState(() {
                                    filterActive = true;
                                    searchedChipName = item;
                                    fetchFilterData(null, null, item);
                                  });
                                },
                              );
                            },
                          ),
                        );
                      });
                    },
                  )
                ],
              ) :
              Container(),
            ],),
          const SizedBox(width: 10)
        ],
        //scrolledUnderElevation: 5.0,
        //shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: mediaQuery.size.height,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 75, 0, mediaQuery.size.width/2 - 75, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      userType == 3? buildCustomerDataTable():
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildAdminOrDealerHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                  child: buildAdminOrDealerDataTable(),
                ),
              ),
            ),
            buildFooterView(),
          ],
        ),
      ),
    );
  }

  Widget buildAdminOrDealerHeader()
  {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          searchedChipName != ''? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5),
                child: Chip(
                    backgroundColor: Colors.yellow,
                    label: Text('filtered By $searchedChipName'),
                    onDeleted: (){
                      setState(() {
                        searchedChipName = '';
                        filterActive = false;
                        searched = false;
                        filterProductInventoryList.clear();
                      });
                    }),
              ),
            ],
          ) :
          const SizedBox(),
        ],
      ),
    );
  }

  Widget buildAdminOrDealerDataTable()
  {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      dataRowHeight: 40.0,
      headingRowHeight: 40,
      headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
      border: TableBorder.all(color: Colors.grey),
      columns: const [
        DataColumn2(
            label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
            fixedWidth: 70
        ),
        DataColumn2(
            label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
            size: ColumnSize.M
        ),
        DataColumn2(
            label: Text('Model Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
            size: ColumnSize.M
        ),
        DataColumn2(
          label: Text('Device Id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
          fixedWidth: 170,
        ),
        DataColumn2(
          label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 95,
        ),
        DataColumn2(
          label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 80,
        ),
        DataColumn2(
          label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 90,
        ),
        DataColumn2(
          label: Center(child: Text('Sales Person', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Center(child: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 100,
        ),
        DataColumn2(
          label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
          fixedWidth: 50,
        ),
      ],
      rows: searched ? List<DataRow>.generate(filterProductInventoryList.length, (index) => DataRow(cells: [
        DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}'))),
        DataCell(Text(filterProductInventoryList[index].categoryName)),
        DataCell(Text(filterProductInventoryList[index].modelName)),
        DataCell(Text(filterProductInventoryList[index].deviceId)),
        DataCell(Center(child: Text(filterProductInventoryList[index].dateOfManufacturing))),
        DataCell(Center(child: Text('${filterProductInventoryList[index].warrantyMonths}'))),
        DataCell(
            Center(
              child: userType == 1? Row(
                children: [
                  CircleAvatar(radius: 5,
                    backgroundColor:
                    filterProductInventoryList[index].productStatus==1? Colors.pink:
                    filterProductInventoryList[index].productStatus==2? Colors.blue:
                    filterProductInventoryList[index].productStatus==3? Colors.purple:
                    filterProductInventoryList[index].productStatus==4? Colors.yellow:
                    filterProductInventoryList[index].productStatus==5? Colors.deepOrangeAccent:
                    Colors.green,
                  ),
                  const SizedBox(width: 5,),
                  filterProductInventoryList[index].productStatus==1? const Text('In-Stock'):
                  filterProductInventoryList[index].productStatus==2? const Text('Stock'):
                  filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                  filterProductInventoryList[index].productStatus==4? const Text('Pending'):
                  filterProductInventoryList[index].productStatus==5? const Text('Installed'):
                  const Text('Active'),
                ],
              ):
              Row(
                children: [
                  CircleAvatar(radius: 5,
                    backgroundColor:
                    filterProductInventoryList[index].productStatus==1? Colors.pink:
                    filterProductInventoryList[index].productStatus==2? Colors.purple:
                    filterProductInventoryList[index].productStatus==3? Colors.yellow:
                    filterProductInventoryList[index].productStatus==4? Colors.deepOrangeAccent:
                    Colors.green,
                  ),
                  const SizedBox(width: 5,),
                  filterProductInventoryList[index].productStatus==2? const Text('In-Stock'):
                  filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                  filterProductInventoryList[index].productStatus==4? const Text('Pending'):
                  filterProductInventoryList[index].productStatus==5? const Text('Installed'):
                  const Text('Active'),
                ],
              ),
            )
        ),
        DataCell(Center(child: widget.userName==filterProductInventoryList[index].latestBuyer? Text('-'):Text(filterProductInventoryList[index].latestBuyer))),
        const DataCell(Center(child: Text('25-09-2023'))),
        userType == 1 ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
          getModelByActiveList(context, filterProductInventoryList[index].categoryId, filterProductInventoryList[index].categoryName,
              filterProductInventoryList[index].modelName, filterProductInventoryList[index].modelId, filterProductInventoryList[index].deviceId,
              filterProductInventoryList[index].warrantyMonths, filterProductInventoryList[index].productId);
        }, icon: const Icon(Icons.edit_outlined),))):
        DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
          _displayReplaceProductDialog(context, filterProductInventoryList[index].categoryId, filterProductInventoryList[index].categoryName,
              filterProductInventoryList[index].modelName, filterProductInventoryList[index].modelId, filterProductInventoryList[index].deviceId,
              filterProductInventoryList[index].warrantyMonths, filterProductInventoryList[index].productId, filterProductInventoryList[index].buyerId);
        }, icon: const Icon(Icons.repeat),)))
      ])):
      List<DataRow>.generate(productInventoryList.length, (index) => DataRow(cells: [
        DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}'))),
        DataCell(Text(productInventoryList[index].categoryName)),
        DataCell(Text(productInventoryList[index].modelName)),
        DataCell(Text(productInventoryList[index].deviceId)),
        DataCell(Center(child: Text(productInventoryList[index].dateOfManufacturing))),
        DataCell(Center(child: Text('${productInventoryList[index].warrantyMonths}'))),
        DataCell(
            Center(
              child: userType == 1? Row(
                children: [
                  CircleAvatar(radius: 5,
                    backgroundColor:
                    productInventoryList[index].productStatus==1? Colors.pink:
                    productInventoryList[index].productStatus==2? Colors.blue:
                    productInventoryList[index].productStatus==3? Colors.purple:
                    productInventoryList[index].productStatus==4? Colors.yellow:
                    productInventoryList[index].productStatus==5? Colors.deepOrangeAccent:
                    Colors.green,
                  ),
                  const SizedBox(width: 5,),
                  productInventoryList[index].productStatus==1? const Text('In-Stock'):
                  productInventoryList[index].productStatus==2? const Text('Stock'):
                  productInventoryList[index].productStatus==3? const Text('Sold-Out'):
                  productInventoryList[index].productStatus==4? const Text('Pending'):
                  productInventoryList[index].productStatus==5? const Text('Installed'):
                  const Text('Active'),
                ],
              ):
              Row(
                children: [
                  CircleAvatar(radius: 5,
                    backgroundColor:
                    productInventoryList[index].productStatus==1? Colors.pink:
                    productInventoryList[index].productStatus==2? Colors.purple:
                    productInventoryList[index].productStatus==3? Colors.yellow:
                    productInventoryList[index].productStatus==4? Colors.deepOrangeAccent:
                    Colors.green,
                  ),
                  const SizedBox(width: 5,),
                  productInventoryList[index].productStatus==2? const Text('In-Stock'):
                  productInventoryList[index].productStatus==3? const Text('Sold-Out'):
                  productInventoryList[index].productStatus==4? const Text('Pending'):
                  productInventoryList[index].productStatus==5? const Text('Installed'):
                  const Text('Active'),
                ],
              ),
            )
        ),
        DataCell(Center(child: widget.userName==productInventoryList[index].latestBuyer? Text('-'):Text(productInventoryList[index].latestBuyer))),
        const DataCell(Center(child: Text('25-09-2023'))),
        userType == 1 ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
          getModelByActiveList(context, productInventoryList[index].categoryId, productInventoryList[index].categoryName,
              productInventoryList[index].modelName, productInventoryList[index].modelId, productInventoryList[index].deviceId,
              productInventoryList[index].warrantyMonths, productInventoryList[index].productId);
        }, icon: const Icon(Icons.edit_outlined),))):
        DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
          _displayReplaceProductDialog(context, productInventoryList[index].categoryId, productInventoryList[index].categoryName,
              productInventoryList[index].modelName, productInventoryList[index].modelId, productInventoryList[index].deviceId,
              productInventoryList[index].warrantyMonths, productInventoryList[index].productId, productInventoryList[index].buyerId);
        }, icon: const Icon(Icons.repeat),)))
      ])),
    );
  }

  Widget buildCustomerDataTable()
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PRODUCT'),
        backgroundColor: myTheme.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 12, top: 5),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 35.0,
                headingRowHeight: 33,
                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                border: TableBorder.all(color: Colors.grey),
                columns: const [
                  DataColumn2(
                      label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      fixedWidth: 70
                  ),
                  DataColumn2(
                      label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Text('Model Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                    label: Text('Device ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                    fixedWidth: 170,
                  ),
                  DataColumn2(
                      label: Center(child: Text('Site Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                    label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                    fixedWidth: 90,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                    fixedWidth: 100,
                  ),
                ],
                rows: searched ? List<DataRow>.generate(filterProductInventoryListCus.length, (index) => DataRow(cells: [
                  DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}'))),
                  DataCell(Text(filterProductInventoryListCus[index].categoryName)),
                  DataCell(Text(filterProductInventoryListCus[index].model)),
                  DataCell(Text(filterProductInventoryListCus[index].deviceId)),
                  DataCell(Center(child: Text(filterProductInventoryListCus[index].siteName))),
                  DataCell(Center(child: filterProductInventoryListCus[index].productStatus==3? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('Free')],):
                  const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active')],))),
                  const DataCell(Center(child: Text('25-09-2023'))),
                ])):
                List<DataRow>.generate(productInventoryListCus.length, (index) => DataRow(cells: [
                  DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                  DataCell(Text(productInventoryListCus[index].categoryName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataCell(Text(productInventoryListCus[index].model, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataCell(Text(productInventoryListCus[index].deviceId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataCell(Center(child: Text(productInventoryListCus[index].productStatus==3? '-' : productInventoryListCus[index].siteName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                  DataCell(Center(child: productInventoryListCus[index].productStatus==3? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('Free', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],):
                  const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],))),
                  const DataCell(Center(child: Text('25-09-2023', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                ])),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: buildFooterView(),
          ),
        ],
      ),
    );
  }

  Widget buildFooterView()
  {
    return filterActive ? Container() : Container(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 5),
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
      ),
      height: 60,
      child: userType == 3? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${(currentSet - 1) * batchSize + 1} to ${currentSet * batchSize > totalProduct ? totalProduct : currentSet * batchSize}  of  $totalProduct'),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Previous page', onPressed: isPreviousButtonEnabled ? () => _onPreviousButtonPressed() : null , icon: const Icon(Icons.arrow_left)),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Next page', onPressed: isNextButtonEnabled ? () => _onNextButtonPressed() : null , icon: const Icon(Icons.arrow_right)),
                const SizedBox(width: 10,),
                IconButton(tooltip:'Settings',onPressed:() {}, icon: const Icon(Icons.settings_outlined))
              ],
            ),
          ),
        ],
      ):
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(children: [
            const SizedBox(height: 5,),
            const Text('Total Category', style: TextStyle(fontSize: 13)),
            Text('$totalCategory',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const SizedBox(height: 5,),
            const Text("Total Products", style: TextStyle(fontSize: 13)),
            Text('$totalModel', style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const SizedBox(height: 5,),
            const Text("Out of stock", style: TextStyle(fontSize: 13)),
            Text('$outOfStockModel',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const SizedBox(height: 5,),
            const Text("Total Items", style: TextStyle(fontSize: 13)),
            Text('$totalProduct', style: const TextStyle(fontSize: 17)),
          ],),
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${(currentSet - 1) * batchSize + 1} to ${currentSet * batchSize > totalProduct ? totalProduct : currentSet * batchSize}  of  $totalProduct'),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Previous page', onPressed: isPreviousButtonEnabled ? () => _onPreviousButtonPressed() : null , icon: const Icon(Icons.arrow_left)),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Next page', onPressed: isNextButtonEnabled ? () => _onNextButtonPressed() : null , icon: const Icon(Icons.arrow_right)),
                const SizedBox(width: 10,),
                IconButton(tooltip:'Settings',onPressed:() {}, icon: const Icon(Icons.settings_outlined))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _displayEditProductDialog(BuildContext context, int catId, String catName, String mdlName, int mdlId, String imeiNo, int warranty, int productId) async
  {
    int indexOfInitialSelection = activeModelList.indexWhere((model) => model.modelName == mdlName);
    final formKey = GlobalKey<FormState>();
    final TextEditingController textFieldModelList = TextEditingController();
    final TextEditingController ctrlIMI = TextEditingController();
    final TextEditingController ctrlWrM = TextEditingController();
    ctrlIMI.text = imeiNo;
    ctrlWrM.text = warranty.toString();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Update Product Details'),
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: SizedBox(
                    height: 260,
                    child: Column(
                      children: [
                        Text('Category : $catName'),
                        const SizedBox(height: 15,),
                        DropdownMenu<PrdModel>(
                          controller: textFieldModelList,
                          //errorText: vldErrorMDL ? 'Select model' : null,
                          hintText: 'Model',
                          width: 275,
                          dropdownMenuEntries: selectedModel,
                          initialSelection: initialSelectedModel = activeModelList[indexOfInitialSelection],
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            border: OutlineInputBorder(),
                          ),
                          onSelected: (PrdModel? mdl) {
                            setState(() {
                              mdlId = mdl!.modelId;
                            });
                          },
                        ),
                        const SizedBox(height: 15,),
                        TextFormField(
                          validator: (value){
                            if(value==null ||value.isEmpty){
                              return 'Please fill out this field';
                            }
                            return null;
                          },
                          maxLength: 20,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'IMEi number',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              //valueText = value;
                            });
                          },
                          controller: ctrlIMI,
                        ),
                        const SizedBox(height: 15,),
                        TextFormField(
                          controller: ctrlWrM,
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Please fill out this field';
                            }
                          },
                          maxLength: 2,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            labelText: 'warranty months',
                            suffixIcon: const Icon(Icons.close),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Cancel'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () async {
                  if (formKey.currentState!.validate())
                  {
                    final body = {"productId": productId, "modelId": mdlId, "deviceId": ctrlIMI.text, "warrantyMonths": ctrlWrM.text, 'modifyUser': userID};
                    final response = await HttpService().putRequest("updateProduct", body);
                    print(response.body);
                    if (response.statusCode == 200)
                    {
                      if(jsonDecode(response.body)["code"]==200)
                      {
                        if(searched){
                          fetchFilterData(catId, null, null);
                        }else{
                          getProductList(currentSet, batchSize);
                          _showSnackBar(jsonDecode(response.body)["message"]);
                        }
                      }else{
                        _showSnackBar(jsonDecode(response.body)["message"]);
                      }

                      if(mounted){
                        Navigator.pop(context);
                      }

                    } else {
                      throw Exception('Failed to load data');
                    }
                  }
                  setState(() {
                    //codeDialog = valueText;
                    //Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayReplaceProductDialog(BuildContext context, int catId, String catName, String mdlName, int mdlId, String imeiNo, int warranty, int productId, int customerId) async
  {
    final TextEditingController dropdownCatList = TextEditingController();
    TextEditingController txtEdControllerMdlName = TextEditingController();
    TextEditingController txtEdControllerIMEi = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Replace Product           '),
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  height: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FROM'),
                      const Divider(),
                      Text('Category : $catName'),
                      const SizedBox(height: 5,),
                      Text('Model : $mdlName'),
                      const SizedBox(height: 5,),
                      Text('IMEI No : $imeiNo'),
                      const Divider(),
                      const Text('TO'),
                      const SizedBox(height: 5,),
                      DropdownMenu<ProductStockModel>(
                        controller: dropdownCatList,
                        hintText: 'IMEi Number',
                        width: 270,
                        //label: const Text('Category'),
                        dropdownMenuEntries: ddCategoryList,
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(),
                        ),
                        onSelected: (ProductStockModel? item) {
                          setState(() {
                            txtEdControllerMdlName.text = item!.categoryName;
                            txtEdControllerIMEi.text = item.model;
                          });
                        },
                      ),
                      TextField(
                        enabled: false,
                        controller: txtEdControllerMdlName,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                      TextField(
                        enabled: false,
                        controller: txtEdControllerIMEi,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Cancel'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Replace'),
                onPressed: () async {
                  final body = {"userId": customerId, "oldDeviceId": imeiNo, "newDeviceId": txtEdControllerIMEi.text, 'modifyUser': userID};
                  final response = await HttpService().postRequest("replaceProduct", body);
                  if (response.statusCode == 200)
                  {
                    if(jsonDecode(response.body)["code"]==200)
                    {
                      getProductStock();
                      getProductList(currentSet, batchSize);
                      _showSnackBar(jsonDecode(response.body)["message"]);

                    }else{
                      _showSnackBar(jsonDecode(response.body)["message"]);
                    }

                    if(mounted){
                      Navigator.pop(context);
                    }

                  } else {
                    throw Exception('Failed to load data');
                  }

                  setState(() {
                    //codeDialog = valueText;
                    //Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> getModelByActiveList(BuildContext context, int catId, String catName, String mdlName, int mdlId, String imeiNo, int warranty, int productId) async
  {
    Map<String, Object> body = {
      "categoryId" : catId.toString(),
    };
    final response = await HttpService().postRequest("getModelByCategoryId", body);
    if (response.statusCode == 200)
    {
      activeModelList.clear();
      selectedModel.clear();

      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        activeModelList.add(PrdModel.fromJson(cntList[i]));
      }

      selectedModel =  <DropdownMenuEntry<PrdModel>>[];
      for (final PrdModel index in activeModelList) {
        selectedModel.add(DropdownMenuEntry<PrdModel>(value: index, label: index.modelName));
      }

      setState(() {
        selectedModel;
        _displayEditProductDialog(context, catId, catName, mdlName, mdlId, imeiNo, warranty, productId);
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onNextButtonPressed() {
    getProductList(currentSet = currentSet+1, batchSize);
  }

  void _onPreviousButtonPressed() {
    getProductList(currentSet = currentSet-1, batchSize);
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}