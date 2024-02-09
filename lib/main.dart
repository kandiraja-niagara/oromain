import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/config_maker.dart';
import 'package:oro_irrigation_new/screens/DashBoard.dart';
import 'package:oro_irrigation_new/screens/login_form.dart';
import 'package:oro_irrigation_new/state_management/FertilizerSetProvider.dart';
import 'package:oro_irrigation_new/state_management/GlobalFertLimitProvider.dart';
import 'package:oro_irrigation_new/state_management/MqttPayloadProvider.dart';
import 'package:oro_irrigation_new/state_management/SelectedGroupProvider.dart';
import 'package:oro_irrigation_new/state_management/constant_provider.dart';
import 'package:oro_irrigation_new/state_management/data_acquisition_provider.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:oro_irrigation_new/state_management/mqtt_message_provider.dart';
import 'package:oro_irrigation_new/state_management/overall_use.dart';
import 'package:oro_irrigation_new/state_management/preferences_screen_main_provider.dart';
import 'package:oro_irrigation_new/state_management/program_queue_provider.dart';
import 'package:oro_irrigation_new/state_management/schedule_view_provider.dart';
import 'package:oro_irrigation_new/state_management/system_definition_provider.dart';
import 'package:oro_irrigation_new/widgets/drop_down_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state_management/config_maker_provider.dart';

void main() {
  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  myMqtt.editMySchedule(mySchedule);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ConfigMakerProvider()),
      ChangeNotifierProvider(create: (context) => PreferencesMainProvider()),
      ChangeNotifierProvider(create: (context) => DataAcquisitionProvider()),
      ChangeNotifierProvider(create: (context) => OverAllUse()),
      ChangeNotifierProvider(create: (context) => MessageProvider()),
      ChangeNotifierProvider(create: (context) => IrrigationProgramMainProvider()),
      ChangeNotifierProvider(create: (context) => ConstantProvider()),
      ChangeNotifierProvider(create: (context) => SelectedGroupProvider()),
      ChangeNotifierProvider(create: (context) => FertilizerSetProvider()),
      ChangeNotifierProvider(create: (context) => GlobalFertLimitProvider()),
      ChangeNotifierProvider(create: (context) => myMqtt),
      ChangeNotifierProvider(create: (context) => SystemDefinitionProvider()),
      ChangeNotifierProvider(create: (context) => ProgramQueueProvider()),
      ChangeNotifierProvider(create: (context) => mySchedule),

    ],
    child: const MyApp(),
  )
  );
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
      statusBarBrightness: Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      // home: ConfigMakerScreen(userID: 15, customerID: 15, siteID: 1, imeiNumber: ''),
      home: ClickableWidget(),
      // routes: {
      //   '/': (context) => const Landing(),
      //   '/login': (context) => const LoginForm(),
      //   '/dashboard': (context) => const MainDashBoard(),
      // },
    );
  }
}
class ClickableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _showPositionDetails(context, details.globalPosition);
      },
      child: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
        child: Center(
          child: Text(
            'Click me!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showPositionDetails(BuildContext context, Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(globalPosition);

    print('Global Position: $globalPosition');
    print('Local Position: $localPosition');

    // You can use the position information as needed.
    // For example, display it in a dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Widget Position'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Global Position: $globalPosition'),
              Text('Local Position: $localPosition'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


class Sam extends StatefulWidget {
  const Sam({super.key});

  @override
  State<Sam> createState() => _SamState();
}

class _SamState extends State<Sam> {
  FocusNode myFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('app'),),
      body: Column(
        children: [
          DropdownButton(
            focusNode: myFocus,
            focusColor: Colors.transparent,
            // style: ioText,
            value: '-',
            underline: Container(),
            items: ['-','open'].map((dynamic items) {
              return DropdownMenuItem(

                onTap: (){
                },
                value: items,
                child: Container(
                    child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                ),
              );
            }).toList(), onChanged: (Object? value) {  },
            // After selecting the desired option,it will
            // change button value to selected value
          ),
          ElevatedButton(onPressed: (){
            setState(() {
              myFocus.requestFocus();
              myFocus.hasPrimaryFocus;
              myFocus.canRequestFocus;
              myFocus.enclosingScope;
              print('req ${myFocus.canRequestFocus}');
              print('has  ${myFocus.hasFocus}');
            });
          }, child: Text('open'))
        ],
      ),
    );
  }
}


class Landing extends StatefulWidget {
  const Landing({super.key});
  @override
  LandingState createState() => LandingState();
}

class LandingState extends State<Landing>
{
  String username = "";

  @override
  void initState() {
    super.initState();
    checkUserInfo();
  }

  void checkUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    username = (prefs.getString('userName') ?? "");
    if (mounted){
      if (username == "") {
        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
      }else{
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  void dispose() {
    super.dispose();
  }

}