import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker=ImagePicker();

  @override
  void initState(){
    super.initState();
    loadModel().then((value){
      setState(() {});
    });
  }

  classifyImage(File image) async{
    var output=await Tflite.runModelOnImage(path: image.path, numResults: 38, threshold: 0.5, imageMean: 127.5, imageStd: 127.5);
    setState(() {
      _output=output!;
      _loading=false;
    });
  }

  loadModel() async{
    await Tflite.loadModel(model: 'assets/model_new_mnv2.tflite', labels: 'assets/labels_plant.txt');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Tflite.close();
    super.dispose();
  }

  pickImage() async{
    var image=await picker.pickImage(source:ImageSource.camera);
    if (image==null) return null;

    setState(() {
      _image=File(image.path);
    });
    
    classifyImage(_image);
  }

  pickGalleryImage() async{
    var image=await picker.pickImage(source:ImageSource.gallery);
    if (image==null) return null;

    setState(() {
      _image=File(image.path);
    });

    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF377212),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 85),
                Text(
                  'MobileNetv2',
                  style: TextStyle(color: Color(0xFFEEDA28), fontSize: 20),
                ),
                SizedBox(height: 6),
                Text(
                  'Detect Plant Diseases',
                  style: TextStyle(
                      color: Color(0xFFE99600),
                      fontWeight: FontWeight.w500,
                      fontSize: 28),
                ),
                SizedBox(height: 40),
                Center(
                  child: _loading
                      ? Container(
                          width: 300,
                          child: Column(children: <Widget>[
                          Image.asset('assets/agro_icon.png'),
                          SizedBox(height: 50),
                        ]))
                      : Container(
                          child: Column(children:<Widget>[
                            Container(height:250, child:Image.file(_image),
                            ),
                            SizedBox(height:20),
                            _output.length>0?Text('$_output', style: TextStyle(color:Colors.white, fontSize: 20)):Text('Image unclear/Cannot be identified', style: TextStyle(color:Colors.white, fontSize: 20)),
                          ],
                          )
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: <Widget>[
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 150,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                              color: Color(0xFFE99600),
                              borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Take a Photo', style:TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height:10),
                      GestureDetector(
                        onTap: pickGalleryImage,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 150,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                            color: Color(0xFFE99600),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('From Gallery', style:TextStyle(color: Colors.white)),
                        ),
                      ),
                    ]))
              ],
            )));
  }
}
