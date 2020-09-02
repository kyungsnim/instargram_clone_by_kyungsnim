import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/pages/HomePage.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/ProgressWidget.dart';
import 'package:instargram_clone_by_kyungsnim/models/user.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

// with AutomaticKeepAliveClientMixin를 추가해주면 다른 Tap으로 다녀와도 이전 검색기록이 남아 있게 된다.
class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  // 검색창 입력내용 controller
  TextEditingController searchTextEditingController = TextEditingController();
  // DB에서 검색된 사용자를 가져오는데 활용되는 변수
  Future<QuerySnapshot> futureSearchResults;

  // X 아이콘 클릭시 검색어 삭제
  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  // 검색어 입력후 submit하게되면 DB에서 검색어와 일치하거나 포함하는 결과 가져와서 future변수에 저장
  controlSearching(str) {
    print(str);
    Future<QuerySnapshot> allUsers = userReference.where('profileName', isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

// 검색페이지 상단부분
AppBar searchPageHeader() {
  return AppBar(
    backgroundColor: Colors.black,
    title: TextFormField(
      controller: searchTextEditingController, // 검색창 controller
      decoration: InputDecoration(
        hintText: 'Search here....',
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey,)
        ),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white,)
        ),
        filled: true,
        prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30),
        suffixIcon: IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: emptyTheTextFormField)
      ),
      style: TextStyle(
        fontSize: 18,
        color: Colors.white
      ),
      onFieldSubmitted: controlSearching,
    )
  );
}

  displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.grey, size: 150),
            Text(
              'Search Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 40
              ),
            ),
          ],
        )
      )
    );
  }

  displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];
        snapshot.data.documents.forEach((document) {
          User users = User.fromDocument(document);
          UserResult userResult = UserResult(users);
          searchUserResult.add(userResult);
        });

        return ListView(
          children: searchUserResult
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }

  // with AutomaticKeepAliveClientMixin를 추가해주고 아래 값을 true로 설정해주면 다른탭 다녀와도 initState안함
  @override
  bool get wantKeepAlive => true;
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                print('tapped');
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: eachUser.url == null ? circularProgress() : CachedNetworkImageProvider(eachUser.url,),
                ),
                title: Text(eachUser.profileName, style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
                subtitle: Text(eachUser.username, style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                )),
              ),
            )
          ],
        ),
      )
    );
  }
}
