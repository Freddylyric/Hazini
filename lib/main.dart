import 'package:flutter/material.dart';
import 'package:hazini/screens/login_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'adapters/user_model.dart';


Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('userBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/hazini_logo.png"),
                  fit: BoxFit.cover,
                ),
                // color: Color(0xff0B615E),
              ),
              height: MediaQuery.of(context).size.height * 0.4,

            ),
            SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(

                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Hive.box<UserModel>('userBox').clear();
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginScreen()));
                    },
                    style: ButtonStyleConstants.secondaryButtonStyle,
                    child: Row(
                      children:  [
                        Icon(Icons.login, color: styles.secondaryColor), // add an Icon as the first child of the Row
                        const SizedBox(width: 20), // add some spacing between the icon and the text
                        const Text("Login to Hazini", style: styles.purpleText, textAlign: TextAlign.center,),
                      ],
                    ),
                  ),const SizedBox(height: 20,),
                  Divider(
                    thickness: 1.0,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20,),

                ],
              ),
            ),




          ],

        )
      ),
    );
  }
  }
