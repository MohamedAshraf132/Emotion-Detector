
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
import 'main.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController?.startImageStream((imageStream) {
            cameraImage=imageStream;
            runModel(imageStream);
          });
        });
      }
    });
  }
  runModel(CameraImage img) async {
    if(cameraImage!=null){
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(), // required
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 127.5, // defaults to 127.5
          imageStd: 127.5, // defaults to 127.5
          rotation: 90, // defaults to 90, Android only
          numResults: 2, // defaults to 5
          threshold: 0.1, // defaults to 0.1
          asynch: true // defaults to true
      );
      for (var element in recognitions!) {
        setState(() {
          output=element['label'];
        });
      }

    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCamera();
    loadModel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController!.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('3amel mn benha'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width:MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.7,
              child: !cameraController!.value.isInitialized?
              Container():
              AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),),
            ),
          ),
          Text(output,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26),)
        ],
      ),
    );
  }
}
