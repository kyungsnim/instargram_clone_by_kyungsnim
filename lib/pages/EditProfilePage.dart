import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/models/user.dart';
import 'package:instargram_clone_by_kyungsnim/pages/HomePage.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/ProgressWidget.dart';

import 'ProfilePage.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _profileNameValid = true;
  bool _bioValid = true;

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3
          || profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110
          || bioTextEditingController.text.isEmpty
          ? _bioValid = false
          : _bioValid = true;
    });

    if(_bioValid && _profileNameValid) {
      userReference.doc(widget.currentOnlineUserId).update({
        'profileName': profileNameTextEditingController.text,
        'bio': bioTextEditingController.text,
      });

      SnackBar successSnackBar = SnackBar(content: Text('Profile has been updated successfully.'),);
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  @override
  void initState() {
    super.initState();

    // 화면 빌드 전 미리 해당 사용자의 값들로 셋팅해주자
    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    // DB에서 사용자 정보 가져오기
    DocumentSnapshot documentSnapshot = await userReference.doc(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    // profile, bio 입력란에 사용자 정보로 채워주기
    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    // 셋팅 끝나면 loading은 false로 바뀌고 화면에 값들이 보임
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(icon: Icon(Icons.done, color: Colors.white,),
            // profileName, bio값이 수정되므로 완료버튼 클릭시 ProfilePage를 새로 build 해주자.
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => ProfilePage(user.id)))
          ),
        ],
      ),
      body: loading ? circularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 7),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    createProfileNameTextFormField(),
                    createBioTextFormField(),
                  ],),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 29, left: 30, right: 30),
                  child: RaisedButton(
                    onPressed: updateUserData,
                    child: Text(
                      '           Update           ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )
                  )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: RaisedButton(
                      color: Colors.red,
                      onPressed: logoutUser,
                      child: Text(
                        '           Logout           ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    )
                )
              ],
            )
          )
        ],
      )
    );
  }

  logoutUser() async {
    await googleSignIn.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => HomePage()
    ));
  }

  createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text('Profile Name', style: TextStyle(color: Colors.grey),),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: 'Write profile name here...',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _profileNameValid ? null : 'Profile name is very short'
          ),
        )
      ],
    );
  }

  createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text('Bio', style: TextStyle(color: Colors.grey),),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          decoration: InputDecoration(
              hintText: 'Write Bio here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid ? null : 'Bio is very long'
          ),
        )
      ],
    );
  }
}
