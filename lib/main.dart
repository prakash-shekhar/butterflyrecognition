import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'result_popup.dart';
import 'result.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butterfly Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  File _image;
  double _imageWidth;
  double _imageHeight;
  var _recognitions;
  List<Result> resultlist = [];

  void _addBtrflyItem(Result re) {
    setState(() {
      int index = resultlist.length;
      resultlist.add(re);
      write();
    });
  }

  // Build the whole list of todo items
  Widget _buildBtrflyList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < resultlist.length) {
          return _buildBtrflyItem(resultlist[index]);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildBtrflyItem(Result Btrfly) {
    return new ListTile(
      leading: CircleAvatar(
        backgroundImage: FileImage(File(Btrfly.image)),
      ),
      title: new Text(Btrfly.species),
      trailing: new Text(Btrfly.prediction),
      onTap: () {
        popUp pu = new popUp();
        pu.onButtonPressed(context, Btrfly);
      },
    );
  }

  loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/descriptions.txt');
  }

  // run prediction using TFLite on given image
  Future predict(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    // print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
    String lelstr = await loadAsset(context);
    Map<String, dynamic> descrmap = jsonDecode(lelstr);
    String predStr = recognitions[0]['label'];
    Result re = Result(predStr, recognitions[0]['confidence'],
        '${descrmap['$predStr']}', image.path);
    popUp pu = new popUp();
    await pu.onButtonPressed(context, re);
    _addBtrflyItem(re);
  }

  write() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/serializedlist.txt');
    String jsonTags = jsonEncode(resultlist);
    await file.writeAsString(jsonTags);
  }

  read() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/serializedlist.txt');
    String text = await file.readAsString();
    var v = json.decode(text);
    resultlist.clear();
    for (var i in v) {
      Result re = Result(i['species'], 0.99, i['description'], i['image']);
      _addBtrflyItem(re);
    }
  }

  allclear() async {
    resultlist.clear();
    animationController.reverse();
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/serializedlist.txt');
    await file.writeAsString('[]');
  }

  // send image to predict method selected from gallery or camera
  sendImage(File image) async {
    if (image == null) return;
    await predict(image);

    // get the width and height of selected image
    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
            _image = image;
          });
        })));
  }

  // select image from gallery
  selectFromGallery() async {
    final _picker = ImagePicker();
    PickedFile file = await _picker.getImage(source: ImageSource.gallery);
    var image = File(file.path);
    if (image == null) return;
    setState(() {});
    sendImage(image);
  }

  // select image from camera
  selectFromCamera() async {
    final _picker = ImagePicker();
    PickedFile file = await _picker.getImage(source: ImageSource.camera);
    var image = File(file.path);
    if (image == null) return;
    setState(() {});
    sendImage(image);
  }

  @override
  void initState() {
    read();
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Butterfly Classifier'),
          actions: [
            IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  allclear();
                })
          ],
        ),
        body: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            children: <Widget>[
              _buildBtrflyList(),
              Positioned(
                  right: 30,
                  bottom: 30,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      IgnorePointer(
                        child: Container(
                          color: Colors.transparent,
                          height: 150.0,
                          width: 150.0,
                        ),
                      ),
                      Transform.translate(
                        offset:
                            Offset.fromDirection(getRadiansFromDegree(180), 75),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degTwoTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            color: Colors.teal,
                            width: 50,
                            height: 50,
                            icon: Icon(
                              Icons.camera,
                              color: Colors.white,
                            ),
                            onClick: () {
                              selectFromCamera();
                            },
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset:
                            Offset.fromDirection(getRadiansFromDegree(270), 75),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degTwoTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            color: Colors.blueGrey,
                            width: 50,
                            height: 50,
                            icon: Icon(
                              Icons.folder,
                              color: Colors.white,
                            ),
                            onClick: () {
                              selectFromGallery();
                            },
                          ),
                        ),
                      ),
                      Transform(
                        transform: Matrix4.rotationZ(
                            getRadiansFromDegree(rotationAnimation.value)),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.blue,
                          width: 60,
                          height: 60,
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onClick: () {
                            if (animationController.isCompleted) {
                              animationController.reverse();
                            } else {
                              animationController.forward();
                            }
                          },
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton(
      {this.color, this.width, this.height, this.icon, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon, enableFeedback: true, onPressed: onClick),
    );
  }
}
