import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trafficsignclassifier/components/roundedbutton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() {
  runApp(TrafficSignClassifierApp());
}

class TrafficSignClassifierApp extends StatelessWidget {
  static const String id = 'home_screen';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Sign Classifier',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        accentColor: Colors.purple,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: MyHomePage(title: 'Traffic Sign Classifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  List _recognitions;
  AnimationController controller;
  Animation animation;

  File imageURI;
  String result;
  String path;

  Future getImageFromCamera() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageURI = image;
      path = image.path;
    });
  }

  Future classifyImage() async {
    await Tflite.loadModel(
        model: "assets/tf_lite_model.tflite", labels: "assets/labels.txt");
    var output = await Tflite.runModelOnImage(path: path);

    setState(() {
      _recognitions = output;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      upperBound: 0.6,
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
//        title: Text(
////          widget.title,
////          style: GoogleFonts.lato(
////              fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 0.75),
//            ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 300,
                child: ColorizeAnimatedTextKit(
                  text: ['Traffic Sign Classifier'],
                  textStyle: GoogleFonts.lato(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.75,
                  ),
                  colors: [
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            imageURI == null
                ? Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/trafficsign.png'),
                      height: animation.value * 400,
                    ),
                  )
                : Image.file(imageURI,
                    width: 300, height: 200, fit: BoxFit.cover),
            SizedBox(
              height: 15,
            ),
            RoundedButton(
              text: 'Take a photo',
              color: Colors.lightBlueAccent,
              onPress: () {
                getImageFromCamera();
              },
            ),
            RoundedButton(
              text: 'Choose from gallery',
              color: Colors.lightBlueAccent,
              onPress: () {
                getImageFromGallery();
//                initGalleryPickUp();
              },
            ),
            RoundedButton(
              text: 'Classify',
              color: Colors.blue,
              onPress: () {
                classifyImage();
              },
            ),
            SizedBox(
              height: 7,
            ),
            _recognitions == null
                ? Text(
                    'Remember to crop the image carefully for correct results!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Text(
                    _recognitions[0]['label'].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            _recognitions == null
                ? Text(
                    'Also, do check how confident I am of my choice :)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Text(
                    ((_recognitions[0]['confidence'] * 100).toInt())
                            .toString() +
                        '% confident',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
