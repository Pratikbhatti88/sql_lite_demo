import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todoapp/dbhelper.dart';

class todoui extends StatefulWidget {
  @override
  _todouiState createState() => _todouiState();
}

class _todouiState extends State<todoui> {
  final dbhelper = Databasehelper.instance;

  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  bool validated = true;
  String errtext = "";
  String email = "";
  String password = '';
  bool isupdate = false;
  var myitems = [];
  bool isCameraupdate = false;
  List<Widget> children = [];
  dynamic result;

  File imgFile;
  File clearFile;
  final imgPicker = ImagePicker();
  String imagepathdata;
  bool permissionGranted;
  bool directoryExists;
  bool fileExists = false;

//   void openCamera1() async {
//     var imgCamera = await imgPicker.pickImage(source: ImageSource.camera);
//
//     setState(() {
//       File test = File(imgCamera.path);
//       print('image=============$test');
//
//       var basNameWithExtension = path.basename(test.path);
//
//       print('file name=============$basNameWithExtension');
//       createnewfile(test, basNameWithExtension);
//
//       // imgFile = (imgCamera);
//       // Navigator.pop(context);
//     });
//   }
//
//   void createnewfile(File file, String filename) async {
//     print('image=============fghg5636');
//
//     final directory = await getExternalStorageDirectory();
//
//     print('image=============00000');
//
//     final String path = directory.path;
//
//     print('directory============$path');
//
//     /*  var basNameWithExtension = path.basename(file.path);
//
//     print('file name=============$basNameWithExtension');
// */
//     newImage = await file.copy('$path/$filename');
//
//     print('new file============${newImage.path}');
//
//     // imgFile = File(newImage.path);
//     // Navigator.pop(context);
//   }

  void openCamera() async {
    var imgCamera = await imgPicker.pickImage(source: ImageSource.camera);
    setState(() {
      imgFile = File('');
      imgFile = File(imgCamera.path);

      print('imagefile=======$imgFile');

      imagepathdata = imgFile.path;
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void openGallery() async {
    var imgGallery = await imgPicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imgFile = File(imgGallery.path);
      imagepathdata = imgFile.path;
    });
    Navigator.of(context).pop();
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  void addtodo() async {
    Map<String, dynamic> row = {
      Databasehelper.columnEmail: email,
      Databasehelper.columnPassword: password,
      Databasehelper.columnImagePath: imagepathdata,
    };
    final id = await dbhelper.insert(row);
    print(id);
    Navigator.pop(context);
    email = '';
    password = '';
    imgFile = clearFile;

    setState(() {
      validated = true;
      errtext = "";
    });
  }

  // Uint8List convertStringToUint8List(String str) {
  //   final List<int> codeUnits = str.codeUnits;
  //   final Uint8List unit8List = Uint8List.fromList(codeUnits);
  //
  //   return unit8List;
  // }

  Future<bool> query({Widget emailTextfield, Widget passwordtextfield}) async {
    myitems = [];
    children = [];

    var allrows = await dbhelper.queryall();

    allrows.forEach((row) {
      fileExists = File(row['imagePath']).existsSync();

      print('filexist  $fileExists');

      myitems.add(row.toString());
      //print(myitems);
      print('imagepath....................');
      print(row['imagePath']);

      children.add(Card(
        elevation: 0.2,
        margin: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        child: Container(
            color: Color(0xff121212),
            padding: EdgeInsets.all(5.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: fileExists
                                  ? FileImage(File(row['imagePath']))
                                  : NetworkImage(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSs2SRiqXBIJrTOZ5vL0wSUvz3MHavuW5rWYhfz6T_PGeZG3PnlRcjTyXZN6dj4J_KE_bE&usqp=CAU')))),
                  // child: Image.file(
                  //     (File(row['imagePath']))),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                      ),
                      Text(
                        row['Email'],
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Raleway",
                        ),
                      ),
                      Text(
                        row['Password'],
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                      height: 35,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: IconButton(
                          onPressed: () {
                            dbhelper.deletedata(row['id']);
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ))),
                  Container(
                      height: 35,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              isCameraupdate = true;
                              isupdate = true;
                              showalertdialog(
                                  emailTextField: emailTextfield,
                                  passwordTextField: passwordtextfield,
                                  id: row['id'],
                                  Updateemail: row['Email'],
                                  Password: row['Password'],
                                  base64: row['imagePath']);
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.black,
                          ))),
                ],
              ),
            )),
      ));
    });
    return Future.value(true);
  }

  void _update(
    int id,
    String UpdateEmail,
    String UpdatePassword,
    String UpdatedImage,
  ) async {
    // row to update
    Map<String, dynamic> row = {
      Databasehelper.columnID: id,
      Databasehelper.columnEmail: UpdateEmail,
      Databasehelper.columnPassword: UpdatePassword,
      Databasehelper.columnImagePath: UpdatedImage
    };
    final rowsAffected = await dbhelper.update(row);
    print('updated $rowsAffected row(s)');
    imgFile = clearFile;
    setState(() {
      Navigator.pop(context);
    });
  }

  void showalertdialog(
      {Widget emailTextField,
      Widget passwordTextField,
      int id,
      String Updateemail,
      String Password,
      String base64}) {
    if (isupdate) {
      emailcontroller = TextEditingController(text: Updateemail);
      passwordcontroller = TextEditingController(text: Password);
    } else {
      emailcontroller.text = "";
      passwordcontroller.text = "";
    }
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: isupdate
                  ? Text('Update Task')
                  : Text(
                      "Add Task",
                    ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(children: [
                      Container(
                        height: 77,
                        width: 83,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                    image: isCameraupdate
                                        ? FileImage(File(base64))
                                        : imgFile != null
                                            ? FileImage(imgFile)
                                            : NetworkImage(
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSs2SRiqXBIJrTOZ5vL0wSUvz3MHavuW5rWYhfz6T_PGeZG3PnlRcjTyXZN6dj4J_KE_bE&usqp=CAU'),
                                    fit: BoxFit.cover)),
                            // child:base64!=null?Utility.imageFromBase64String(base64):Text(''),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 5,
                          right: 4,
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffD226AB)),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () async {
                                    await _getStoragePermission();
                                    showModalBottomSheet<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                              height: 150,
                                              color: Colors.white,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffebebeb),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40)),
                                                          child: IconButton(
                                                            onPressed:
                                                                () async {
                                                              await openCamera();
                                                              setState(() {
                                                                isCameraupdate =
                                                                    false;
                                                                FileImage(
                                                                    imgFile);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.camera_alt,
                                                              color: Color(
                                                                  0xffD226AB),
                                                              size: 40,
                                                            ),
                                                          )),
                                                      Text(
                                                        'Camera',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffebebeb),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40)),
                                                          child: IconButton(
                                                            onPressed:
                                                                () async {
                                                              await openGallery();
                                                              setState(() {
                                                                isCameraupdate =
                                                                    false;
                                                                FileImage(
                                                                    imgFile);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.photo,
                                                              color: Color(
                                                                  0xffD226AB),
                                                              size: 40,
                                                            ),
                                                          )),
                                                      Text(
                                                        'Gallery',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ));
                                        });
                                  },
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              )))
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(50)),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: emailTextField),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(50)),
                        child: passwordTextField),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              if (!isupdate) {
                                if (emailcontroller.text.isEmpty ||
                                    passwordcontroller.text.isEmpty ||
                                    imgFile == null) {
                                  setState(() {
                                    errtext = "Can't Be Empty";
                                    validated = false;
                                  });
                                } else if (emailcontroller.text.length > 512) {
                                  setState(() {
                                    errtext = "Too may Chanracters";
                                    validated = false;
                                  });
                                } else {
                                  isupdate
                                      ? _update(
                                          id, email, password, imagepathdata)
                                      : addtodo();
                                }
                              } else {
                                isupdate
                                    ? _update(
                                        id, email, password, imagepathdata)
                                    : addtodo();
                              }
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xffD226AB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )),
                            child: isupdate
                                ? Text("Update",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Raleway",
                                        color: Colors.white))
                                : Text("ADD",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "Raleway",
                                        color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    print('===================================================');
    final emailTextfield = TextField(
      controller: emailcontroller,
      autofocus: true,
      onChanged: (_val) {
        email = _val;
      },
      style: TextStyle(
        fontSize: 18.0,
        fontFamily: "Raleway",
      ),
      decoration: InputDecoration(
        errorText: validated ? null : null,
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.email,
          color: Colors.white,
        ),
        hintText: 'Email',
      ),
    );
    final PasswordTextfield = TextField(
      controller: passwordcontroller,
      autofocus: true,
      onChanged: (_val) {
        password = _val;
      },
      style: TextStyle(
        fontSize: 18.0,
        fontFamily: "Raleway",
      ),
      decoration: InputDecoration(
          errorText: validated ? null : null,
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          hintText: 'Password'),
    );

    return FutureBuilder(
      builder: (context, snap) {
        if (snap.hasData == null) {
          return Center(
            child: Text(
              "No Data",
            ),
          );
        } else {
          if (children.length == 0) {
            return SafeArea(
              child: Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showalertdialog(
                          emailTextField: emailTextfield,
                          passwordTextField: PasswordTextfield);
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  backgroundColor: Color(0xffD226AB),
                ),
                appBar: AppBar(
                  backgroundColor: Color(0xffD226AB),
                  centerTitle: true,
                  title: Text(
                    "My Tasks",
                    style: TextStyle(
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                backgroundColor: Colors.black,
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(50)),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "No Task Avaliable",
                        style: TextStyle(fontFamily: "Raleway", fontSize: 20.0),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          } else {

            print('snapshotdata---------');
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  setState(() {});
                  isCameraupdate = false;
                  isupdate = false;
                  showalertdialog(
                      emailTextField: emailTextfield,
                      passwordTextField: PasswordTextfield);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Color(0xffD226AB),
              ),
              appBar: AppBar(
                backgroundColor: Colors.black,
                centerTitle: true,
                title: Text(
                  "My Tasks",
                  style: TextStyle(
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.black,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(children: children),
                  ],
                ),
              ),
            );
          }
        }
      },
      future: query(
          emailTextfield: emailTextfield, passwordtextfield: PasswordTextfield),
    );
  }
}
