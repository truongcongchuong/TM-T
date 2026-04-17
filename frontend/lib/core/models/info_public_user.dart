class InfoPublicUserModel {
  final int id;
  final String userName;
  //final String avatar;

  InfoPublicUserModel({
    required this.id,
    required this.userName,
    //required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': userName,
      //'avatar': avatar,
    };
  }

  factory InfoPublicUserModel.fromMap(Map<String, dynamic> map) {
    return InfoPublicUserModel(
      id: map['id'] as int,
      userName: map['username'] as String,
      //avatar: map['avatar'] as String,
    );
  }
}