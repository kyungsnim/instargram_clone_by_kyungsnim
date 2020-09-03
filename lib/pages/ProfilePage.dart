import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/models/user.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/HeaderWidget.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/ProgressWidget.dart';

import 'EditProfilePage.dart';
import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage(this.userProfileId);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id; // 
  
  createProfileTopView() {
    return FutureBuilder(
      // 현재 로그인한 유저의 정보로 DB 데이터 가져오기
      future: userReference.doc(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        // 가져오는 동안 Progress bar
        if(!dataSnapshot.hasData) {
          return circularProgress();
        }

        // 가져온 데이터로 User 인스턴스에 담기
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 게시글, 팔로워, 팔로잉 수 (임시로 숫자 박아놓자)
                            createColumns('posts', 124),
                            createColumns('followers', 1230),
                            createColumns('following', 1100),
                          ],
                        ),
                      ],
                    )
                  )
                ],
              ),
              SizedBox(height: 10),
              Row( // 사용자 이름
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(user.username, style: TextStyle(color: Colors.white, fontSize: 16),),
                ],
              ),
              SizedBox(height: 5),
              Row( // 사용자 이름
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(user.profileName, style: TextStyle(color: Colors.white, fontSize: 18),),
                ],
              ),
              SizedBox(height: 5),
              Row( // 사용자 이름
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(user.bio, style: TextStyle(color: Colors.white, fontSize: 16),),
                ],
              ),
              Row( // 상황에 따라 Edit profile, follow, unfollow 버튼으로 분기처리
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  createButton(),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  // 게시글/팔로워/팔로잉
  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  // 팔로우/언팔로우 상태에 따라 보여줘야 함
  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId; //
    if(ownProfile) { // 본인의 프로필을 보려는 경우
      return createButtonTitleAndFunction(title: 'Edit Profile', performFunction: editUserProfile,);
    } else {
      // return
    }
  }

  // 본인의 프로필인 경우 Edit Profile 버튼을 보여주고, 그에맞게 동작하도록 구
  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.03,
          child: Text(title, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6)
          ),
        ),
      ),
    );
  }

  // 버튼 클릭시 Edit 페이지로 전환
  editUserProfile() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, title: 'Profile',),
      body: ListView(
        children: [
          createProfileTopView(),
        ],
      )
    );
  }
}
