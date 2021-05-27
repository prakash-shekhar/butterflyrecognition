import 'package:flutter/material.dart';
import 'result.dart';
import 'dart:io';
import 'dart:convert';

class popUp {
  String _predStr = "";
  String _predPerc = "";
  String _descr = "Description here";
  var _image;
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(35.0),
          topRight: const Radius.circular(35.0),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Image.file(
              File(_image),
              fit: BoxFit.fill,
              width: 250,
              height: 250,
            ),
            Row(
              children: [
                Text(
                  '$_predStr',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                Text(
                  '($_predPerc)',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                )
              ],
            ),
            Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '$_descr',
                  style: TextStyle(fontSize: 15),
                )),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: TextStyle(fontSize: 20),
                ))
          ])),
    );
  }

  void onButtonPressed(BuildContext context, Result re) async {
    _predStr = re.species;
    _predPerc = re.prediction;
    _image = re.image;
    _descr = re.description;
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => build(context));
  }
}
