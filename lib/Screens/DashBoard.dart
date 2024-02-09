import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Forms/create_account.dart';
import 'package:oro_irrigation_new/screens/product_inventory.dart';
import 'package:oro_irrigation_new/screens/web_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Customer/Dashboard/DashboardNode.dart';
import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'Customer/Dashboard/SentAndReceived.dart';
import 'Customer/Dashboard/FarmSettings.dart';
import 'Customer/customer_home.dart';
import 'my_preference.dart';
import 'product_entry.dart';
import 'AdminDealerHomePage.dart';
import 'login_form.dart';


String appBarTitle = 'Home';
get formKey => null;
TextEditingController dateCtl = TextEditingController();
String selectedCategory = '';

enum Calendar { day, week, month, year }

class MainDashBoard extends StatelessWidget
{
  const MainDashBoard({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      routes: {
        '/': (context) => const DashBoardMain(),
        '/login': (context) => const LoginForm(),
      },
    );
  }
}


class DashBoardMain extends StatefulWidget
{
  const DashBoardMain({super.key});

  @override
  DashBoardMainState createState() => DashBoardMainState();
}

class DashBoardMainState extends State<DashBoardMain> with TickerProviderStateMixin
{
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  get formKey => null;
  String selectedCategory = '';
  String appBarTitle = 'Home';
  int userID = 0;
  String userName = '', userType = '', userCountryCode = '', userMobileNo = '';
  final List<Map> myProducts =  List.generate(5, (index) => {"id": index, "name": "Product $index"}).toList();

  late MqttPayloadProvider payloadProvider;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
    manager = MQTTManager();
    _executeSharedPreferences();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      mqttConfigureAndConnect();
    });
  }


  Future _executeSharedPreferences() async
  {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = (prefs.getString('userName') ?? "");
      userType = (prefs.getString('userType') ?? "");
      userCountryCode = (prefs.getString('countryCode') ?? "");
      userMobileNo = (prefs.getString('mobileNumber') ?? "");
      userID = int.parse(prefs.getString('userId') ?? "");
    });
  }

  void mqttConfigureAndConnect() {
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  @override
  Widget build(BuildContext context)
  {
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints)
        {
          if (constraints.maxWidth < 600) {
            return const DashboardNarrow();//mobile
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const DashboardMiddle();//pad or tap
          } else {
            return DashboardWide(userName: userName, userType: userType, countryCode: userCountryCode, mobileNo: userMobileNo, userID: userID, screenWidth: MediaQuery.sizeOf(context).width,);//desktop or web
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}



//Narrow-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardNarrow extends StatefulWidget {
  const DashboardNarrow({Key? key}) : super(key: key);
  @override
  State<DashboardNarrow> createState() => _DashboardNarrowState();
}

class _DashboardNarrowState extends State<DashboardNarrow> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Middle-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardMiddle extends StatefulWidget {
  const DashboardMiddle({Key? key}) : super(key: key);
  @override
  State<DashboardMiddle> createState() => _DashboardMiddleState();
}

class _DashboardMiddleState extends State<DashboardMiddle> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Wide-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardWide extends StatefulWidget
{
  const DashboardWide({Key? key, required this.userName, required this.userType, required this.countryCode,  required this.mobileNo, required this.userID, required this.screenWidth}) : super(key: key);
  final String userType, userName, countryCode, mobileNo;
  final int userID;
  final double screenWidth;

  @override
  State<DashboardWide> createState() => _DashboardWideState();
}

class _DashboardWideState extends State<DashboardWide> {

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;
  Calendar calendarView = Calendar.day;
  late Widget _centerWidget;
  String currentTap = 'Dashboard';
  List<DashboardModel> siteList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCustomerSite();
  }

  Future<void> getCustomerSite() async
  {
    _centerWidget = Center(child: Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth/2 - 160),
      child: const LoadingIndicator(
        indicatorType: Indicator.ballPulse,
      ),
    ));

    final prefs = await SharedPreferences.getInstance();
    Map<String, Object> body = {"userId" : int.parse(prefs.getString('userId') ?? "")};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        try {
          siteList = cntList.map((json) => DashboardModel.fromJson(json)).toList();
        } catch (e) {
          print('Error: $e');
        }
      }
      callCustomerDashboard();
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> callCustomerDashboard()  async {
    await Future.delayed(const Duration(seconds: 2));
    if(widget.userType =='3'){
      onOptionSelected('Dashboard');
    }
  }

  void onOptionSelected(String option) {
    currentTap = option;
    setState(() {
      if (option == 'Dashboard') {
        _centerWidget = CustomerHome(customerID: widget.userID, type: 0, customerName: '', userID: widget.userID, siteList: siteList,);
      } else if (option == 'My Product') {
        _centerWidget = ProductInventory(userName: widget.userName);
      } else if (option == 'Device Settings') {
        _centerWidget = FarmSettings(customerID: widget.userID, siteList: siteList,);
      }
      else if (option == 'Sent And Received') {
        _centerWidget = SentAndReceived(customerID: widget.userID, siteList: siteList,);
      }
      // Add more conditions for additional options
    });
  }

  @override
  Widget build(BuildContext context)  {
    //var appState = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.1),
      body: widget.userType =='3'? Stack(
        children: [
          MyDrawer(
            userName: widget.userName, countryCode: widget.countryCode, phoneNo: widget.mobileNo, onOptionSelected: onOptionSelected, currentTap: currentTap,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 250),
            child: Container(
                color:Colors.white,
                child: _centerWidget
            ),
          ),
        ],
      ):
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.white,
            labelType: NavigationRailLabelType.all,
            indicatorColor: Colors.black,
            indicatorShape: const CircleBorder(side: BorderSide(color: Colors.black12)),
            //unselectedIconTheme: const IconThemeData(color: Colors.grey),
            elevation: 5,
            leading: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/company_logo.png"),
                  backgroundColor: Colors.white,
                ),
                Divider()
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout, color: Colors.redAccent,),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      await prefs.remove('userName');
                      await prefs.remove('countryCode');
                      await prefs.remove('mobileNumber');
                      await prefs.remove('subscribeTopic');
                      if (mounted){
                        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                      }
                    },
                  ),
                ),
              ),
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                if(_selectedIndex==0){
                  appBarTitle = 'Home';
                }else if(_selectedIndex==1){
                  appBarTitle = 'Product';
                }else{
                  appBarTitle = 'My Preference';
                }
              });
            },
            destinations: widget.userType == '1'? <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.add_chart),
                selectedIcon: Icon(Icons.add_chart, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.topic_outlined),
                selectedIcon: Icon(Icons.topic_outlined, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
            ]:
            <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.add_chart),
                selectedIcon: Icon(Icons.add_chart, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Color(0xFF0D5D9A),),
                label: Text(''),
              ),
            ],
          ),
          Expanded(
            child: widget.userType =='1'? _selectedIndex == 0 ? AdminDealerHomePage(userName: widget.userName, countryCode: widget.countryCode, mobileNo: widget.mobileNo) :
            _selectedIndex == 1 ? ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? const AllEntry() : _selectedIndex == 3 ? const MyPreference(userID: 1,) : const MyWebView():

            _selectedIndex == 0 ? AdminDealerHomePage(userName: widget.userName, countryCode: widget.countryCode, mobileNo: widget.mobileNo) :
            _selectedIndex == 1 ? ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? widget.userType =='1'? const AllEntry() : const MyPreference(userID: 1,) : const MyWebView(),
          ),
        ],
      )
    );

    return widget.userType =='3'? Scaffold(
      body: Stack(
        children: [
          MyDrawer(
            userName: widget.userName, countryCode: widget.countryCode, phoneNo: widget.mobileNo, onOptionSelected: onOptionSelected, currentTap: currentTap,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 250),
            child: Container(
                color:Colors.white,
                child: _centerWidget
            ),
          ),
        ],
      ),
    ):
    Scaffold(
      appBar: widget.userType =='1'?  AppBar(
        title: Text (appBarTitle),
        actions: _selectedIndex==0?[
          IconButton(tooltip: 'Create Dealer account', icon: const Icon(Icons.person_add_outlined), color: Colors.white, onPressed: () async
          {
            await showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  content: CreateAccount(),
                ));

          }),
          const SizedBox(width: 20,),
          const Icon(Icons.notifications_none, color: Colors.white,),
          const SizedBox(width: 30,),
        ] : [],
      ) :
      AppBar(
        title: const Text ('Dashboard'),
        actions: _selectedIndex==0?[
          IconButton(tooltip: 'Create customer account', icon: const Icon(Icons.person_add_outlined), color: Colors.white, onPressed: () async
          {
            await showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  content: CreateAccount(),
                ));

          }),
          const SizedBox(width: 20,),
          const Icon(Icons.notifications_none, color: Colors.white,),
          const SizedBox(width: 30,),
        ] : [
          const SizedBox(width: 20,),
        ],
      ),
      body: Row(
        children: <Widget>[
          SizedBox(
            width: 150,
            child: NavigationRail(
              indicatorColor: myTheme.primaryColor.withOpacity(0.1),
              minWidth: 145.0,
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              labelType: NavigationRailLabelType.all,
              leading: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 3,),
                    Text(widget.userName, style: myTheme.textTheme.titleSmall,),
                    const SizedBox(height: 3,),
                    Text('+${widget.countryCode} ${widget.mobileNo}', style: myTheme.textTheme.titleSmall,),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout, color: Colors.redAccent,),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('userId');
                        await prefs.remove('userName');
                        await prefs.remove('countryCode');
                        await prefs.remove('mobileNumber');
                        await prefs.remove('subscribeTopic');

                        if (mounted){
                          Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                        }
                      },
                    ),
                  ),
                ),
              ),
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                  if(_selectedIndex==0){
                    appBarTitle = 'Home';
                  }else if(_selectedIndex==1){
                    appBarTitle = 'Product';
                  }else{
                    appBarTitle = 'My Preference';
                  }
                });
              },
              destinations: widget.userType == '1'? <NavigationRailDestination>[
                const NavigationRailDestination(
                  padding: EdgeInsets.only(top: 5),
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF0D5D9A),),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.add_chart),
                  selectedIcon: Icon(Icons.add_chart, color: Color(0xFF0D5D9A),),
                  label: Text('Product'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.topic_outlined),
                  selectedIcon: Icon(Icons.topic_outlined, color: Color(0xFF0D5D9A),),
                  label: Text('Master'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_outlined, color: Color(0xFF0D5D9A),),
                  label: Text('My Preference'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info_outline, color: Color(0xFF0D5D9A),),
                  label: Text('App Info'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.help_outline),
                  selectedIcon: Icon(Icons.help_outline, color: Color(0xFF0D5D9A),),
                  label: Text('Help & Support'),
                ),
              ]:
              <NavigationRailDestination>[
                const NavigationRailDestination(
                  padding: EdgeInsets.only(top: 5),
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF0D5D9A),),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.add_chart),
                  selectedIcon: Icon(Icons.add_chart, color: Color(0xFF0D5D9A),),
                  label: Text('Product'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_outlined, color: Color(0xFF0D5D9A),),
                  label: Text('My Preference'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info_outline, color: Color(0xFF0D5D9A),),
                  label: Text('App Info'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.help_outline),
                  selectedIcon: Icon(Icons.help_outline, color: Color(0xFF0D5D9A),),
                  label: Text('Help & Support'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0 ? const AdminDealerHomePage(userName: '', countryCode: '', mobileNo: '',) :
            _selectedIndex == 1 ? ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? widget.userType =='1'? const AllEntry() : const MyPreference(userID: 1,) : const MyWebView(),
          ),
        ],
      ),
    );
  }

}

class MyDrawer extends StatelessWidget {
  final Function(String) onOptionSelected;
  const MyDrawer({super.key, required this.onOptionSelected, required this.userName, required this.countryCode, required this.phoneNo, required this.currentTap});
  final String userName, countryCode, phoneNo, currentTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 250,
        height: MediaQuery.of(context).size.height < 750 ? 750 : MediaQuery.of(context).size.height,
        color: myTheme.primaryColor.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: myTheme.primaryColor,
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 3,),
                    Text(userName, style: const TextStyle(fontSize: 17, color: Colors.white)),
                    const SizedBox(height: 3,),
                    Text('+$countryCode $phoneNo', style: const TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5, top: 10),
              child: Text('HOME', style: TextStyle(color: Colors.white)),
            ),
            buildCustomListTile('Dashboard', Icons.dashboard_outlined, 'Dashboard'),
            buildCustomListTile('My Product', Icons.topic_outlined, 'My Product'),
            buildCustomListTile('Report Overview', Icons.my_library_books_outlined, 'Report Overview'),
            buildCustomListTile('Sent And Received', Icons.question_answer_outlined, 'Sent And Received'),
            buildCustomListTile('Controller Logs', Icons.message_outlined, 'Controller Logs'),
            buildCustomListTile('Device Settings', Icons.settings_outlined, 'Device Settings'),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Text('ORGANIZATION', style: TextStyle(color: Colors.white)),
            ),
            buildCustomListTile('App Info', Icons.info_outline, 'App Info'),
            buildCustomListTile('Help & Support', Icons.help_outline, 'Help & Support'),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Text('ACCOUNT', style: TextStyle(color: Colors.white)),
            ),
            buildCustomListTile('My Preference', Icons.settings_outlined, 'My Preference'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red,),
              title: const Text('Logout', style: TextStyle(fontSize: 14, color: Colors.white)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userId');
                await prefs.remove('userName');
                await prefs.remove('countryCode');
                await prefs.remove('mobileNumber');
                await prefs.remove('subscribeTopic');
                if (context.mounted){
                  Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                }
              },
            ),
            // Add more ListTile widgets for additional options
          ],
        ),
      ),
    );
  }

  Widget buildCustomListTile(String title, IconData icon, String tapOption) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        decoration: BoxDecoration(
          color: currentTap == tapOption ? Colors.white : Colors.transparent,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)), // Adjust the radius as needed
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: currentTap == tapOption ? myTheme.primaryColor : Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: currentTap == tapOption ? myTheme.primaryColor : Colors.white,
            ),
          ),
          onTap: () {
            onOptionSelected(tapOption);
          },
        ),
      ),
    );
  }
}