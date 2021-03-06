part of itinndata;

///BASE DOMAIN FOR LOCAL OBJECTS
abstract class LocalDO  extends Object with Observable{
  @observable String Id;
  Map toJsonMap(){
    return {
      'id' : this.Id,
    };
  }
  String toJson(){
    return JSON.encode(toJsonMap());
  }
  String toString(){
    return toJsonMap().toString();
  }

}


///BASE DOMAIN FOR OBJECTS THAT ARE SYNCHRONIZING to server
abstract class GeneralDO extends LocalDO {
  static const  String SYNC_CONFLICT = 'conflict';
  static const  String SYNC_CREATE = 'create';
  static const  String SYNC_DELETE = 'delete';
  static const  String SYNC_UPDATE = 'update';
  static const  bool SYNC_OK = true;
  var Sync;
  String SyncId;
  int Version;
  Map toJsonMap(){
    return {
      'id' : this.Id,
      'syncId' : this.SyncId,
      'version' : this.Version,
      'sync': this.Sync
    };
  }
  String toJson(){
    return JSON.encode(toJsonMap());
  }
  void merge(other){
    this.Id = other.Id;
    this.Sync = other.Sync;
    this.Version = other.Version;
  }
  int compare(other){
    if(Id==null){
      return -1;
    }else if(other.Id==null){
      return 1;
    }else{
      return Id.compareTo(other.Id);
    }
  }
}

///DOMAIN OBJECT REPRESENTING USER
class UserDO extends GeneralDO{
    String ProfileID;
    @observable String Name;
    @observable List<String> ProfileIDs;

    Map toJsonMap(){
      var map = super.toJsonMap();
      map['activeProfile'] = this.ProfileID;
      map['name'] = this.Name;
      map['profileIds'] = this.ProfileIDs;
      return map;
    }
    static UserDO fromJsonMap(Map jsonMap, [UserDO item]){
      if(jsonMap==null){
        return null;
      }
      if(item == null){
        item = new UserDO();
      }
      item.Id = jsonMap['id'];
      item.Sync = jsonMap['sync'];
      item.SyncId = jsonMap['syncId'];
      item.Version = jsonMap['version']!=null ? jsonMap['version'].floor() : 0;

      item.ProfileID = jsonMap['activeProfile'];
      item.Name = jsonMap['name'];
      item.ProfileIDs = jsonMap['profileIds'];

      return item;
    }
    void merge(UserDO other){
      super.merge(other);
      this.Name = other.Name;
      this.ProfileID = other.ProfileID;
      this.ProfileIDs = other.ProfileIDs;
    }
}

///DOMAIN OBJECT REPRESENTING USER's profile
class ProfileDO extends LocalDO{
  String ProfileKey;
  List<String> UserIDs;
  Map Roles;
  Map toJsonMap(){
    var map = super.toJsonMap();
    map['key'] = this.ProfileKey;
    map['userIds'] = this.UserIDs;
    map['roles'] = this.Roles;
    return map;
  }
  static ProfileDO fromJsonMap(Map jsonMap, [ProfileDO item]){
    if(jsonMap==null){
      return null;
    }
    if(item == null){
      item = new ProfileDO();
    }
    item.Id = jsonMap['id'];

    item.ProfileKey = jsonMap['key'];
    item.UserIDs = jsonMap['userIds'];
    item.Roles = jsonMap['roles'];
    return item;
  }
  bool isUserInRole(String userId, String role){
    //update role to key
    if(Roles!=null){
      for(String key in Roles.keys){
        if(key.toLowerCase() == role.toLowerCase()){
          //get users
          List<String> users = this.Roles[key];
          return users!=null && users.contains(userId);
        }
      }
    }
    return false;
  }
  List<String> getUserRoles(String userid){
    List<String> ret = new List();
    if(Roles!=null){
      for(String role in Roles.keys){
        if(Roles[role].contains(userid)){
          ret.add(role);
        }
      }
    }
    return ret;
  }
  List<String> addUserToRole(String userId, String role){
    var userRoles = getUserRoles(userId);
    //update role to key
    if(Roles!=null){
      for(String key in Roles.keys){
        if(key.toLowerCase() == role.toLowerCase()){
          if(!Roles[key].contains(userId)){
            Roles[key] =Roles[key].toList()..add(userId);
            userRoles.add(key);
          }
          //role found, user added and return
          return userRoles;
        }
      }
    }else{
      Roles = new Map();
    }
    //role not found
    Roles[role] = [userId];
    userRoles.add(role);

    return userRoles;
  }
  List<String> removeUserFromRole(String userId, String role){
    var userRoles = getUserRoles(userId);
    //update role to key
    if(Roles!=null){
      for(String key in Roles.keys){
        if(key.toLowerCase() == role.toLowerCase()){
          if(Roles[key].contains(userId)){
            Roles[key] = Roles[key].toList()..remove(userId);
            userRoles.remove(key);
          }
          //role found, removed and return
          return userRoles;
        }
      }
    }

    //user not found in role, nothing to remove
    return userRoles;
  }
}

///DOMAIN OBJECT REPRESENTING Local settings
class LocalSettingsDO extends LocalDO{

  UserDO me;
  ProfileDO profile;

  bool offline = true;
  bool moreAnimations = true;
  String lang = 'en';
  String lastProfileId;
  String token;
  String login;

  Map toJsonMap(){
    var map = super.toJsonMap();
    map['me'] = me==null?null:me.toJsonMap();
    map['profile'] = profile == null?null:profile.toJsonMap();
    map['offline'] = offline;
    map['moreAnimations'] = moreAnimations;
    map['lang'] = lang;
    map['lastProfileId'] = lastProfileId;
    map['token'] = token;
    map['login'] = login;
    return map;
  }
  static LocalSettingsDO fromJsonMap(Map jsonMap, [LocalSettingsDO item]){
    if(jsonMap==null){
      return null;
    }
    if(item == null){
      item = new LocalSettingsDO();
    }
    item.Id = jsonMap['Id'];

    item.profile = ProfileDO.fromJsonMap(jsonMap['profile']);
    item.me = UserDO.fromJsonMap(jsonMap['me']);
    item.offline = jsonMap['offline']==null? true: jsonMap['offline'];
    item.moreAnimations = jsonMap['moreAnimations']==null? true: jsonMap['moreAnimations'];
    item.lang = jsonMap['lang'];
    item.lastProfileId = jsonMap['lastProfileId'];

    item.token = jsonMap['token'];
    item.login= jsonMap['login'];

    return item;
  }
}

//CLOB
///Domain object holding big string data.
class BlobDO extends GeneralDO{
  var Data;
  String name;
  String type;
  dynamic toJsonMap(){
    var map = super.toJsonMap();
    map['data'] = this.Data;
    map['type'] = this.type;
    map['name'] = this.name;
    return map;
  }
  static BlobDO fromJsonMap(var jsonMap, [BlobDO item]){
    if(jsonMap==null){
      return null;
    }
    if(item == null){
      item = new BlobDO();
    }
    item.Id = jsonMap['id'];
    item.Sync = jsonMap['sync'];
    item.SyncId = jsonMap['syncId'];
    item.Version = jsonMap['version'] !=null ? jsonMap['version'].floor() : 0;

    item.Data = jsonMap['data'];
    item.name = jsonMap['name'];
    item.type = jsonMap['type'];
    return item;
  }
}