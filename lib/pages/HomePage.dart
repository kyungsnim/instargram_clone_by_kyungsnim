import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instargram_clone_by_kyungsnim/models/user.dart';
import 'package:instargram_clone_by_kyungsnim/pages/TimeLinePage.dart';
import 'package:instargram_clone_by_kyungsnim/pages/SearchPage.dart';
import 'package:instargram_clone_by_kyungsnim/pages/ProfilePage.dart';
import 'package:instargram_clone_by_kyungsnim/pages/UploadPage.dart';
import 'package:instargram_clone_by_kyungsnim/pages/NotificationsPage.dart';
import 'package:instargram_clone_by_kyungsnim/pages/CreateAccountPage.dart';

// variable for google sign in (very easy to use)
final GoogleSignIn googleSignIn = new GoogleSignIn();
// variable for firestore collection 'users'
final userReference = FirebaseFirestore.instance.collection('users');

final DateTime timestamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  // 페이지 컨트롤
  PageController pageController;
  int getPageIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    pageController = PageController();

    // 앱 실행시 구글 사용자의 변경여부를 확인함
    googleSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount); // 사용자가 있다면 로그인
    }, onError: (gError) {
      print("Error Message : " + gError);
    });

    googleSignIn.signInSilently();
    // suppressErrors: false).then((gSignInAccount) {
    //   controlSignIn(gSignInAccount);
    // }).catchError((gError) {
    //   print("Error Message : " + gError);
    // });
  }

  // 로그인 상태 여부에 따라 isSignedIn flag값을 변경해줌
  controlSignIn(GoogleSignInAccount signInAccount) async {
    if(signInAccount != null) {
      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  saveUserInfoToFirestore() async {
    // 현재 구글 로그인된 사용자 정보 가져오기
    final GoogleSignInAccount gCurrentUser = googleSignIn.currentUser;
    // 해당 유저의 db정보 가져오기
    DocumentSnapshot documentSnapshot = await userReference.doc(gCurrentUser.id).get();

    // 해당 유저의 db정보가 없다면
    if(!documentSnapshot.exists) {
      // 유저정보를 셋팅하는 페이지로 이동
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      // 유저정보 셋팅된 값으로 db에 set
      userReference.doc(gCurrentUser.id).set({
        'id' : gCurrentUser.id,
        'profileName' : gCurrentUser.displayName,
        'username' : username,
        'url' : gCurrentUser.photoUrl,
        'email' : gCurrentUser.email,
        'bio' : '',
        'timestamp' : timestamp
      });

      // 해당 정보 다시 가져오기
      documentSnapshot = await userReference.doc(gCurrentUser.id).get();
    }

    // 현재 유저정보에 값 셋팅하기
    currentUser = User.fromDocument(documentSnapshot);
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginUser() {
    googleSignIn.signIn();
  }

  logoutUser() {
    googleSignIn.signOut();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // 정상 로그인시 홈스크린 보인다.
          TimeLinePage(), // 0번 pageIndex
          SearchPage(), // 1번 pageIndex
          UploadPage(currentUser), // 2번 pageIndex
          NotificationsPage(), // 3번 pageIndex
          ProfilePage(), // 4번 pageIndex
        ],
        controller: pageController, // controller를 지정해주면 각 페이지별 인덱스로 컨트롤 가능
        onPageChanged: whenPageChanges, // page가 바뀔때마다 whenPageChanges 함수가 호출되고 현재 pageIndex 업데이트해줌
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Instargram',
              style: TextStyle(
                fontSize: 70,
                color: Colors.white,
                fontFamily: 'Signatra'
              ),
            ),
            SizedBox(height: 200),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }

  }
}