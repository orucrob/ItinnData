part of itinndata;

///BASE DOMAIN FOR LOCAL OBJECTS
abstract class LocalDO  extends Object with Observable{
  @observable String Id;
  Map toJsonMap(){
    return {
      'Id' : this.Id,
    };
  }
  String toJson(){
    return JSON.encode(toJsonMap());
    //return stringify(toJsonMap());
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
      'Id' : this.Id,
      'SyncId' : this.SyncId,
      'Version' : this.Version,
      'Sync': this.Sync
    };
  }
  String toJson(){
    return JSON.encode(toJsonMap());
    //return stringify(toJsonMap());
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
      Id.compareTo(other.Id);
    }
  }
}

///DOMAIN OBJECT REPRESENTING USER
class UserDO extends GeneralDO{
    String LoginID;
    String ProfileID;
    String Name;
    List<String> Roles;
    List<String> ProfileIDs;
//    ProfileDO Profile;

    Map toJsonMap(){
      var map = super.toJsonMap();
      map['LoginID'] = this.LoginID;
      map['ProfileID'] = this.ProfileID;
      map['Name'] = this.Name;
      map['Roles'] = this.Roles;
      map['ProfileIDs'] = this.ProfileIDs;
      return map;
    }
    static UserDO fromJsonMap(Map jsonMap, [UserDO item]){
      if(jsonMap==null){
        return null;
      }
      if(item == null){
        item = new UserDO();
      }
      item.Id = jsonMap['Id'];
      item.Sync = jsonMap['Sync'];
      item.SyncId = jsonMap['SyncId'];
      item.Version = jsonMap['Version']!=null ? jsonMap['Version'].floor() : 0;

      item.LoginID = jsonMap['LoginID'];
      item.ProfileID = jsonMap['ProfileID'];
      item.Name = jsonMap['Name'];
      item.Roles = jsonMap['Roles'];
      item.ProfileIDs = jsonMap['ProfileIDs'];

      return item;
    }
    void merge(UserDO other){
      super.merge(other);
      this.Name = other.Name;
      this.LoginID = other.LoginID;
      this.ProfileID = other.ProfileID;
      this.Roles = other.Roles;
      this.ProfileIDs = other.ProfileIDs;
 //     this.Profile = other.Profile;
    }

}

//////DOMAIN OBJECT REPRESENTING USER
//class DevIssueDO extends GeneralDO{
//  @observable String AppID;
//  @observable String Type;
//  @observable String Status;
//  @observable List<String> Starred;
//  @observable String Title;
//  @observable String Desc;
//  @observable int Created;
//  @observable String CreatedBy;
//
//    Map toJsonMap(){
//      var map = super.toJsonMap();
//      map['AppID'] = this.AppID;
//      map['Type'] = this.Type;
//      map['Status'] = this.Status;
//      map['Starred'] = this.Starred;
//      map['Title'] = this.Title;
//      map['Desc'] = this.Desc;
//      map['Created'] = this.Created;
//      map['CreatedBy'] = this.CreatedBy;
//      return map;
//    }
//    static DevIssueDO fromJsonMap(Map jsonMap, [DevIssueDO item]){
//      if(jsonMap==null){
//        return null;
//      }
//      if(item == null){
//        item = new DevIssueDO();
//      }
//      item.Id = jsonMap['Id'];
//      item.Sync = jsonMap['Sync'];
//      item.SyncId = jsonMap['SyncId'];
//      item.Version = jsonMap['Version']!=null ? jsonMap['Version'].floor() : 0;
//
//      item.AppID = jsonMap['AppID'];
//      item.Type = jsonMap['Type'];
//      item.Status = jsonMap['Status'];
//      item.Starred = jsonMap['Starred'];
//      item.Title = jsonMap['Title'];
//      item.Desc = jsonMap['Desc'];
//      item.Created = jsonMap['Created'];
//      item.CreatedBy = jsonMap['CreatedBy'];
//
//      return item;
//    }
//    void merge(DevIssueDO other){
//      super.merge(other);
//      this.AppID = other.AppID;
//      this.Type = other.Type;
//      this.Status = other.Status;
//      this.Starred = other.Starred;
//      this.Title = other.Title;
//      this.Desc = other.Desc;
//      this.Created = other.Created;
//      this.CreatedBy = other.CreatedBy;
//    }
//
//}
///DOMAIN OBJECT REPRESENTING USER's profile
class ProfileDO extends LocalDO{
  String ProfileKey;
  List<String> UserIDs;
  Map Roles;
  Map toJsonMap(){
    var map = super.toJsonMap();
    map['ProfileKey'] = this.ProfileKey;
    map['UserIDs'] = this.UserIDs;
    map['Roles'] = this.Roles;
    return map;
  }
  static ProfileDO fromJsonMap(Map jsonMap, [ProfileDO item]){
    if(jsonMap==null){
      return null;
    }
    if(item == null){
      item = new ProfileDO();
    }
    item.Id = jsonMap['Id'];

    item.ProfileKey = jsonMap['ProfileKey'];
    item.UserIDs = jsonMap['UserIDs'];
    item.Roles = jsonMap['Roles'];
    return item;
  }
}

///DOMAIN OBJECT REPRESENTING Local settings
class LocalSettingsDO extends LocalDO{

  UserDO me;
  ProfileDO profile;

  bool offline = true;
  bool moreAnimations = true;
  String lastProfileId;
  String token;

  Map toJsonMap(){
    var map = super.toJsonMap();
    map['me'] = me==null?null:me.toJsonMap();
    map['profile'] = profile == null?null:profile.toJsonMap();
    map['offline'] = offline;
    map['moreAnimations'] = moreAnimations;
    map['lastProfileId'] = lastProfileId;
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
    item.lastProfileId = jsonMap['lastProfileId'];

    return item;
  }
}

//CLOB
///Domain object holding big string data.
class BlobDO extends GeneralDO{
  var Data;
  dynamic toJsonMap(){
    var map = super.toJsonMap();
    map['Data'] = this.Data;
    return map;
  }
  static BlobDO fromJsonMap(var jsonMap, [BlobDO item]){
    if(jsonMap==null){
      return null;
    }
    if(item == null){
      item = new BlobDO();
    }
    item.Id = jsonMap['Id'];
    item.Sync = jsonMap['Sync'];
    item.SyncId = jsonMap['SyncId'];
    item.Version = jsonMap['Version'] !=null ? jsonMap['Version'].floor() : 0;

    item.Data = jsonMap['Data'];
    return item;
  }
}