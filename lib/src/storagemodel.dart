part of itinndata;

///[Storage] for [UserDO],
class UserStorage extends SyncStorage<UserDO>{
  UserStorage(String dbName):super('Users', dbName: dbName);
  Map toJsonMap(UserDO item) => item.toJsonMap();
  UserDO fromJsonMap(Map map) => UserDO.fromJsonMap(map);
}

//////[Storage] for [DevIssueDO],
//class DevIssueStorage extends SyncStorage<DevIssueDO>{
//  DevIssueStorage(String dbName):super('DevIssues', dbName: dbName);
//  Map toJsonMap(DevIssueDO item) => item.toJsonMap();
//  DevIssueDO fromJsonMap(Map map) => DevIssueDO.fromJsonMap(map);
//}



///[Storage] for [BlobDO].
class ClobStorage extends SyncStorage<BlobDO>{
  ThumbnailClobStorage thumbClobStorage;
  ClobStorage(String dbName):super('Clobs', dbName: dbName);
  BlobDO fromJsonMap(map) => BlobDO.fromJsonMap(map);
  Map toJsonMap(BlobDO item) => item.toJsonMap();

  Future<bool> clear(){
    return super.clear().then((ok){
      if(thumbClobStorage!=null){
        return thumbClobStorage.clear().then((ok2){
          return ok && ok2;
        });
      }else{
        return ok;
      }
    });
  }

}
///[Storage] for thumbnails of [BlobDO]s.
class ThumbnailClobStorage extends LocalStorage<BlobDO>{
  ClobStorage clobStorage;

  ThumbnailClobStorage(String dbName, this.clobStorage):super('ThmbClobs', dbName: dbName);
  BlobDO fromJsonMap(map) => BlobDO.fromJsonMap(map);
  Map toJsonMap(BlobDO item) => item.toJsonMap();

  Future<BlobDO> getById(String id){
    return super.getById(id).then((val){
      if(val!=null || clobStorage==null){
        return val;
      }else{
        return clobStorage.getById(id).then((fullVal){
          if(fullVal==null || fullVal.Data==null || (fullVal.Data is String && fullVal.Data.isEmpty)){
            return fullVal;
          }else{
            if(fullVal.Data is String || fullVal.Data is Blob){
              var blob = fullVal.Data is Blob? fullVal.Data : ImageUtil.dataUrlToBlob(fullVal.Data);
              return ImageUtil.resizeImageToDataUrl(blob, shrinkWidth: 50).then((thumbnailDataUrl){
                BlobDO item = new BlobDO();
                item.Id = fullVal.Id;
                item.Data = thumbnailDataUrl;
                return insert(item, generateId: false);
              });
            }else{
              //not supported
              ctx.LOG.severe('NOT SUPPORTED FILE TYPE for blob with id ${fullVal.Id}?!?!');
              return fullVal;
            }
          }
        });
      }
    });
  }
}

///common settings used for test purposes-> for settings app should create own storage
class CommonSettStorage extends LocalSettStorage<LocalSettingsDO>{
  LocalSettingsDO getDefaultSettings(){
    return new LocalSettingsDO();
  }
  CommonSettStorage(String dbName):super('Sett', dbName: dbName);
  Map toJsonMap(LocalSettingsDO item) => item.toJsonMap();
  LocalSettingsDO fromJsonMap(Map map) => LocalSettingsDO.fromJsonMap(map);

}
///base class for setting storrage
abstract class LocalSettStorage<T extends LocalSettingsDO> extends LocalStorage<T>{

  LocalSettStorage(String tableName, {String dbName}):super(tableName, dbName: dbName);

  String id = 'settings';
  T settings;

  T getDefaultSettings();

  Future<T> setSett(T sett){
   return update(sett).then((sett){
     settings = sett;
     return sett;
   });
  }

  ///Get single [LocalSettings] object.
  Future<T> getSett({bool deep: false}){
    var c  = new Completer<T>();
    if(deep==true || settings==null){
      if(id==null){
        getAll().then((all){
          if(all!=null && all.isNotEmpty){
            id = all[0].Id;
            settings = all[0];
            c.complete(all[0]);
          }else{
            T ls =getDefaultSettings();
            ls.Id = 'settings';
            insert(ls, generateId: false).then((ls){
              id = ls.Id;
              settings = ls;
              c.complete(ls);
            });
          }
        });
      }else{
        getById(id).then((ls){
          if(ls==null){
            id = null;
            getSett().then((ls){
              if(ls==null){
                LOG.severe('Cannot get LocalSettings ?!?');
                c.complete(getDefaultSettings());
              }else{
                id = ls.Id;
                settings = ls;
                c.complete(ls);
              }
            });
          }else{
            //id = ls.Id;
            settings = ls;
            c.complete(ls);
          }
        });
      }
    }else{
      c.complete(settings);
    }
    return c.future;
  }
}



