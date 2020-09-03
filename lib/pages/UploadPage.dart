import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instargram_clone_by_kyungsnim/models/user.dart';
import 'package:instargram_clone_by_kyungsnim/pages/HomePage.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/ProgressWidget.dart';

class UploadPage extends StatefulWidget {
  final User gCurrentUser;
  UploadPage(this.gCurrentUser);
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  File imgFile;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  void dispose() {
    descTextEditingController.dispose();
    locationTextEditingController.dispose();
    super.dispose();
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    PickedFile imageFile = await _picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.imgFile = File(imageFile.path);
    });
  }

  captureImageWithCamera() async {
    Navigator.pop(context);
    PickedFile imageFile = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.imgFile = File(imageFile.path);
    });
  }

  takeImage(mContext) {
      return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text('New Post', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Capture Image with Camera', style: TextStyle(color: Colors.black)),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text('Select Image from Gallery', style: TextStyle(color: Colors.black)),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
      );
  }

  displayUploadScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Colors.grey, size: 150,),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Upload Image', style: TextStyle(color: Colors.white, fontSize: 20)),
              color: Colors.green,
              onPressed: () => takeImage(context),
            )
          )
        ],
      )
    );
  }

  clearPostInfo() {
    uploading = false;
    postId = Uuid().v4();
    descTextEditingController.clear();
    locationTextEditingController.clear();
    setState(() {
      imgFile = null;
    });
  }

  getUserCurrentLocation() async {
    print('여기1');
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('여기2');
    // List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark mPlaceMark = placeMarks[0];
    print('여기3');
    // String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}';
    // String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    print('여기4');
    locationTextEditingController.text = '${position.latitude}';
    print('locationTextEditingController.text : ${locationTextEditingController.text}');
  }

  compressingPhoto() async { // 업로드 전 사진 준비
    final tDirectory = await getTemporaryDirectory(); // path_provider에서 제공
    final path = tDirectory.path; // 임시 path를 만들어서
    ImD.Image mImageFile = ImD.decodeImage(imgFile.readAsBytesSync()); // image file을 읽어서
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90)); // jpg양식의 신규파일로 만듦
    setState(() {
      imgFile = compressedImageFile;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto(); // 업로드 전 사진 준비
    String downloadUrl = await uploadPhoto(imgFile); // 업로드 후 url 저장
    savePostInfoToFireStore(url: downloadUrl, location: locationTextEditingController.text, desc: descTextEditingController.text);  // location은 에러나서 잠시 보류
    clearPostInfo();
  }

  savePostInfoToFireStore({String url, String location, String desc}) {
    postsReference.doc(widget.gCurrentUser.id).collection('usersPosts').doc(postId).set({
      'postId': postId,
      'ownerId': widget.gCurrentUser.id,
      'timestamp': timestamp,
      'likes': {},
      'username': widget.gCurrentUser.username,
      'description': desc,
      'location': location,
      'url': url
    });
  }

  Future<String> uploadPhoto(mImgFile) async {
    StorageUploadTask storageUploadTask = storageReference.child('post_$postId.jpg').putFile(mImgFile); // 파일명을 지정해서 Storage에 저장
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete; // 저장이 완료되면
    return await storageTaskSnapshot.ref.getDownloadURL(); // 저장된 url값을 return
  }

  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: clearPostInfo,),
        title: Text(
          'New Post',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => uploading ? null : controlUploadAndSave(),
            child: Text('Share',
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15
              )
            )
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(''),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(imgFile),
                      fit: BoxFit.cover
                    )
                  ),
                )
              )
            )
          ),
          Padding(padding: EdgeInsets.only(top: 12),),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.gCurrentUser.url
              ),
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: descTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Say something about image',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
              )
            )
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.person_pin_circle, color: Colors.white, size: 36),
              title: Container(
                  width: 250,
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    controller: locationTextEditingController,
                    decoration: InputDecoration(
                      hintText: 'Write the location here',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                  )
              )
          ),
          Container(
            width: 220,
            height: 110,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((35)),
              ),
              color: Colors. green,
              icon: Icon(Icons.location_on, color: Colors.white),
              label: Text('Get my Current Location', style: TextStyle(color: Colors.white)),
              // onPressed: getUserCurrentLocation,
            )
          )
        ],
      )
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 카메라 또는 갤러리에서 사진 선택한 후엔 UploadFormScreen으로 보여준다.
    return imgFile == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}