part of itinndata;

///Controller to access storages and perform common storages operation.
class StorageCtrl{
  UserStorage storeUser;
  ClobStorage storeClob;
  //DevIssueStorage storeDevIssue;
  LocalSettStorage storeSett;
  ThumbnailClobStorage storeThumbnailClob;

  Stream<bool> onSyncNeed;
  StreamController<bool> syncNeedCtrl;
  String dbName;

  StorageCtrl(this.dbName){
    storeUser = new UserStorage(dbName);
    storeClob = new ClobStorage(dbName);
    //storeDevIssue = new DevIssueStorage(dbName);
    storeSett = createSettStorage(dbName);
    storeThumbnailClob = new ThumbnailClobStorage(dbName, storeClob);
    storeClob.thumbClobStorage = storeThumbnailClob;

    syncNeedCtrl = new StreamController();
    onSyncNeed = syncNeedCtrl.stream.asBroadcastStream();
  }

  LocalSettStorage createSettStorage(String dbName){
    return new CommonSettStorage(dbName);//TODO must be initialized in child class
  }

  Future<bool> init({ctx}){
    return storeSett.init(ctx: ctx).then((_){
      return storeUser.init().then((_){
        storeUser.onSyncNeed.listen((event){
          syncNeedCtrl.add(event);
        });
//        return storeDevIssue.init().then((_){
//          storeDevIssue.onSyncNeed.listen((event){
//            syncNeedCtrl.add(event);
//          });
          return storeClob.init().then((_){
            storeClob.onSyncNeed.listen((event){
              syncNeedCtrl.add(event);
            });
            return true;
          });
//        });
      });
    });
  }

  Future<bool> clearAll({bool deep: false}){
    var c = new Completer<bool>();
    var gOK = true;
    storeUser.clear().then((ok){
      if(!ok) gOK=false;
      storeClob.clear().then((ok){
        if(!ok) gOK=false;
        if(deep){
          storeSett.clear().then((ok){
            if(!ok) gOK=false;
            c.complete(gOK);
          });
        }else{
          c.complete(gOK);
        }
      });
    });
    return c.future;
  }
  Future<bool> dropAll({bool deep: false}){
    var c = new Completer<bool>();
    var gOK = true;
    storeUser.drop().then((ok){
      if(!ok) gOK=false;
      storeClob.drop().then((ok){
        if(!ok) gOK=false;
        if(deep){
          storeSett.drop().then((ok){
            if(!ok) gOK=false;
            c.complete(gOK);
          });
        }else{
          c.complete(gOK);
        }
      });
    });
    return c.future;
  }

//  void flagSave(){
//    if(app.serverMode){
//      app.showSaveBtt();
//    }
//  }

  Future<LocalSettingsDO> settAction(action(LocalSettingsDO sett)){
    var c  = new Completer<LocalSettingsDO>();
    storeSett.getSett().then((sett){
      var f = action(sett);
      if(f!=null && f is Future){
        f.then((_){
          storeSett.setSett(sett).then((sett){
            c.complete(sett);
          });
        });
      }else{
        storeSett.setSett(sett).then((sett){
          c.complete(sett);
        });
      }
    });
    return c.future;
  }

  ///Get single [LocalSettings] object.
  Future<LocalSettingsDO> getSett({bool deep: false, ctx}){
    return storeSett.getSett(deep: deep);
  }


  Future<bool> isSync({bool deep:false}){
    var c = new Completer();
    //TODO sync clob?
//    storeUser.isSync(deep:deep).then((synced){
//      if(!synced){
//        c.complete(synced);
//      }else{
//        storeClob.isSync(deep:deep).then((synced){
//          c.complete(synced);
//        });
//      }
//    });
    c.complete(true);
    return c.future;
  }
  void checkSave({bool deep:false}) {
    isSync(deep:deep).then((synced){
      syncNeedCtrl.add(!synced);
    });
  }
}