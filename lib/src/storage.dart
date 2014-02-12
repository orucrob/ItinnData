part of itinndata;


class IndexDesc{
  String name;
  dynamic keyPath;
  bool unique;
  bool multi;
  IndexDesc(this.name, this.keyPath, {this.unique:false, this.multi:false});
}

/***
 * BASE FOR LocalStorage IMPL
 */

abstract class LocalDataStorage<T extends LocalDO>{
  //int lastId = 0;
  int lastIdCounter = 0;
  String idPrefix = ItinnDataContext.randomStrings(7);

  ItinnDataContext ctx;
  Logger LOG;

//  Stream<String> onChange;
//  StreamController<String> changeCtrl;
  bool suppressStreams = false;

  Stream<T> onUpdate;
  StreamController<T> updateCtrl;
  Stream<T> onInsert;
  StreamController<T> insertCtrl;
  Stream<String> onRemove;
  StreamController<String> removeCtrl;
  Stream<bool> onClearAll;
  StreamController<bool> clearAllCtrl;

  Stream onBatchStart;
  Stream onBatchEnd;
  StreamController batchStartCtrl;
  StreamController batchEndCtrl;

  LocalDataStorage(){
    ctx = new ItinnDataContext();
    LOG = ctx.LOG;

    updateCtrl = new StreamController();
    onUpdate = updateCtrl.stream.asBroadcastStream();
    insertCtrl = new StreamController();
    onInsert = insertCtrl.stream.asBroadcastStream();
    removeCtrl = new StreamController();
    onRemove = removeCtrl.stream.asBroadcastStream();
    clearAllCtrl = new StreamController();
    onClearAll = clearAllCtrl.stream.asBroadcastStream();

    batchStartCtrl = new StreamController();
    onBatchStart = batchStartCtrl.stream.asBroadcastStream();
    batchEndCtrl = new StreamController();
    onBatchEnd = batchEndCtrl.stream.asBroadcastStream();

//    changeCtrl = new StreamController();
//    onChange = changeCtrl.stream;
  }
  ///initialize storage
  Future<bool> init();

  ///Gets [GeneralDO] by it's [id].
  Future<T> getById(String id);

  ///Gets all [GeneralDO] items of this [Storage].
  Future<List<T>> getAll();

  ///Insert [GeneralDO] item into [Storage].
  Future<T> insert(T item);

  ///Update [GeneralDO] item in [Storage].
  Future<T> update(T item);

  ///Remove [GeneralDO] item from [Storage] by its Id.
  Future<bool> removeById(String id);

  ///Clear [Storage].
  Future<bool> clear();

  ///Transform item to JSON for save.
  Map toJsonMap(T item);
  ///Reverse operation to [toJson]. Returns GeneralDO object constructed from json.
  T fromJsonMap(Map json);
}
///***
// * BASE FOR STORAGE IMPL
// */
//abstract class DataStorage<T extends GeneralDO> extends LocalDataStorage<T>{
//
//  bool synced = true;
//  int version = 0;
//
//  Stream<StoreChange> onIdChange;
//  StreamController<StoreChange> idchangeCtrl;
//
//  ///Transform item to JSON MAP for save.
//  Map toJsonMap(T item);
//  ///Reverse operation to [toJsonMap]. Returns [T] (GeneralDO) object constructed from json map.
//  T fromJsonMap(Map map);
//
//  DataStorage():super(){
//    idchangeCtrl = new StreamController();
//    onIdChange = idchangeCtrl.stream.asBroadcastStream();
//  }
////  ///initialize storage
////  Future<bool> init();
//
//  ///Gets info, whether this storrage is synced.
//  Future<bool> isSync({deep: false});
//
//  ///Gets info, whether this storrage is synced.
//  Future<int> getVersion({deep: false}){
//    var c = new Completer<int>();
//    if(deep){
//      getAll(inclDeleted: true).then((all){
//        if(all!=null && all.isNotEmpty){
//          var m = 0;
//          for(var item in all){
//            m = max(m, item.Version==null? 0 : item.Version);
//          }
//          version = m;
//        }
//        c.complete(version);
//      });
//    }else{
//      c.complete(version);
//    }
//    return c.future;
//  }
//
//  ///Gets [GeneralDO] by it's [id].
//  Future<T> getById(String id, { bool inclDeleted:false});
//
//  ///Gets all [GeneralDO] items of this [Storage].
//  Future<List<T>> getAll({bool inclDeleted:false});
//
//  ///Insert [GeneralDO] item into [Storage].
//  Future<T> insert(T item, {sync: GeneralDO.SYNC_CREATE});
//
//  ///Update [GeneralDO] item in [Storage].
//  Future<T> update(T item, {sync: GeneralDO.SYNC_UPDATE, String oldId});
//
//  ///Remove [GeneralDO] item from [Storage] by its Id.
//  Future<bool> removeById(String id, {sync: GeneralDO.SYNC_DELETE});
//
//  ///Remove [GeneralDO] item from [Storage].
//  Future<bool> remove(T item, {sync: GeneralDO.SYNC_DELETE});
//
//  ///Clear [Storage].
//  Future<bool> clear();
//
//  ///Merge item with the one in DB.
//  Future<T> merge({T item, String syncId, String oldId, sync:GeneralDO.SYNC_OK}){
//    var c = new Completer<T>();
//    if(oldId==null){
//      oldId = item.Id;
//    }
//    LOG.finest('Merging item with ID: ${oldId}. Item:${item.toJson()}');
//    getById(oldId, inclDeleted: true).then((child){
//      if(child==null){
//        child = item;
//        //child.Id = id;
//        insert(child, sync:sync).then((T savedItem){
//          LOG.finest('Merged (Inserted) item :${savedItem.toJson()}');
//          c.complete(savedItem);
//        });
//
//      }else{
//        var idChanged = item.Id != oldId;
//        child.merge(item);
//        update(child, sync:sync, oldId: oldId).then((T savedItem){
//          LOG.finest('Merged (UPDATED) item :${savedItem.toJson()}');
//          if(idChanged){
//            idchangeCtrl.add(new StoreChange(oldId, savedItem.Id));
//          }
//
//          c.complete(savedItem);
//        });
//      }
//    });
//    return c.future;
//  }
//
//
//}

/***
 * LDStorage STORAGE IMPL
 */

abstract class LDLocalStorage<T extends LocalDO> extends LocalDataStorage<T>{

  static List allTableNames = [];

  String dbName;
  String tableName;
  ld.Store store;
  bool _saveStrings;
  List<IndexDesc> indexes;

  LDLocalStorage(this.tableName, {this.dbName:"ItinnDB", this.indexes}): super(){
    if(this.tableName == null){
      tableName = runtimeType.toString();
    }
    if(!allTableNames.contains(tableName)){
      allTableNames.add(tableName);
    }
    List<ld.IndexDesc> ldindexes;
    if(indexes!=null){
      ldindexes = new List();
      indexes.forEach((idx){
        ldindexes.add(new ld.IndexDesc(idx.name, idx.keyPath)..multi=idx.multi..unique=idx.unique);
      });
    }
    store = new ld.Store(dbName, tableName, indexes: ldindexes);
    _saveStrings = !ld.IndexedDbStore.supported;//if IDB -> don't need to convert to strings

  }

  dynamic _toDbObj(T item){
    var map = toJsonMap(item);
    if(_saveStrings){
      return map==null?null:JSON.encode(map);
    }else{
      return map;
    }
  }
  T _fromDbObj(var json_or_map){
    if(json_or_map==null){
      return null;
    }else{
      var map;
      if(_saveStrings){
        map= JSON.decode(json_or_map);
      }else{
        map = json_or_map;
      }
      return fromJsonMap(map);
    }
  }
  Map _fromDbObjAsMap(var json_or_map){
    if(json_or_map==null){
      return null;
    }else{
      var map;
      if(_saveStrings){
        map= JSON.decode(json_or_map);
      }else{
        map = json_or_map;
      }
      return map;
    }
  }

  ///initialize DB and return true if upgrade is needed
  Future<bool> init({ctx}){
    LOG.fine('Initializing store $tableName in $dbName ($store)');
    var c = new Completer<bool>();
    if(ctx!=null) ctx.perfLog("App CTX INIT STORAGE $dbName $tableName");
    store.open().then((ok){
      LOG.fine('Initialization of store $tableName in $dbName ($store) successful');
      c.complete(ok);
    }, onError:(err){
      LOG.severe('Initialization of store $tableName in $dbName ($store) FAILED');
        c.complete(false);
    });
    return c.future;
  }

  Future _openF;
  Future get openIfNeed{
    if(_openF==null){
      if(store.isOpen){
        _openF = new Future.value(true);
      }else{
        _openF = init();
      }
    }
    return _openF;
  }

  ///Gets [LocalDO] by it's [id].
  Future<T> getById(String id){
    Completer<T> c = new Completer();
    openIfNeed.then((_){
      if(id==null || id.isEmpty){
        LOG.warning('getById with null or empty id: $id from $tableName ');
        c.complete(null);
      }else{
        store.getByKey(id).then((json){
          T obj = _fromDbObj(json);
          if(obj!=null){
            obj.Id = id;
            c.complete(obj);
          }else{
            LOG.warning('getById returns null from $tableName ');
            c.complete(null);
          }
        });
      }
    });
    return c.future;
  }

  Future<Stream<T>> streamAllByIndex(String idxName,{Object only, Object lower, Object upper, bool lowerOpen:false, bool upperOpen:false} ) {
    return openIfNeed.then((_){
      return store.allByIndex(idxName, only:only, lower:lower, upper:upper, lowerOpen:lowerOpen, upperOpen:upperOpen).map((jsonormap)=>_fromDbObj(jsonormap));
    });
  }


  ///Gets all [LocalDO] items of this [LocalStorage].
  Future<List<T>> getAll(){
    Completer<List<T>> c = new Completer();
    openIfNeed.then((_){
      var data = new List();
      store.all().listen((json){
        if(json!=null){
          var obj = _fromDbObj(json);
          if(obj!=null){
            data.add(obj);
          }
        }
      }, onDone:(){
        c.complete(data);
      });
    });
    return c.future;
  }

  ///Gets all [LocalDO] items as [Map] of this [LocalStorage].
  Future<List<Map>> getAllAsMap(){
    Completer<List<T>> c = new Completer();
    openIfNeed.then((_){
      var data = new List();
      store.all().listen((json){
        if(json!=null){
          var obj = _fromDbObjAsMap(json);
          if(obj!=null){
            data.add(obj);
          }
        }
      }, onDone:(){
        c.complete(data);
      });
    });
    return c.future;
  }


  ///Insert [LocalDO] item into [LocalStorage].
  Future<T> insert(T item,{ bool generateId : true}){
    var c = new Completer();
    openIfNeed.then((_){
      if(generateId){
        ++lastIdCounter;
        item.Id = "$idPrefix$lastIdCounter";
        LOG.finest('generated id: ${item.Id}');
      }
      var json = _toDbObj(item);
      store.save(json, item.Id).then((id){
        LOG.finest('Item ADDed to $tableName with id: $id');
        c.complete(item);
        if(!suppressStreams) insertCtrl.add(item);
      }, onError: (err){
        c.completeError(err);
      });
    });
    return c.future;
  }

  ///Update [LocalDO] item in [LocalStorage].
  Future<T> update(T item, {String oldId, bool quiet:false }){
    var c = new Completer();
    openIfNeed.then((_){
      var json = _toDbObj(item);

      store.save(json, item.Id).then((id){
        LOG.finest('Item PUT to $tableName with id: $id ');
        if(oldId!=null && item.Id!=oldId){
          store.removeByKey(oldId).then((_){
            c.complete(item);
            if(!quiet && !suppressStreams) updateCtrl.add(item);
          }, onError: (err){
            c.completeError(err);
          });
        }else{
          c.complete(item);
          if(!quiet && !suppressStreams) updateCtrl.add(item);
        }
      }, onError: (err){
        c.completeError(err);
      });
    });
    return c.future;
  }

  ///Remove [LocalDO] item from [LocalStorage] by its Id.
  Future<bool> removeById(String id){
    var c = new Completer();
    openIfNeed.then((_){
      store.removeByKey(id).then((_){
        LOG.finest('Local Item HARD DELETE from $tableName  with id: ${id}');
        c.complete(true);
        if(!suppressStreams) removeCtrl.add(id);
      }, onError: (err){
        c.completeError(err);
      });
    });
    return c.future;
  }

  ///Clear [LocalStorage].
  Future<bool> clear(){
    var c = new Completer();
    openIfNeed.then((_){
      store.nuke().then((_){
        lastIdCounter = 0;
        LOG.finest("Store $tableName in $dbName cleared");
        c.complete(true);
        if(!suppressStreams) clearAllCtrl.add(true);
      }, onError: (err){
        c.completeError(err);
      });
    });
    return c.future;
  }
}

/***
 * LDStorage STORAGE IMPL
 */

abstract class LDStorage<T extends GeneralDO> extends LDLocalStorage<T>{

  bool synced = true;
  int version = 0;

  Stream<bool> onSyncNeed;
  StreamController<bool> syncNeedCtrl;
  Stream<StoreChange> onIdChange;
  StreamController<StoreChange> idchangeCtrl;

  LDStorage(String tableName, {String dbName, List<IndexDesc> indexes}): super(tableName, dbName: dbName, indexes: indexes ){
    idchangeCtrl = new StreamController();
    onIdChange = idchangeCtrl.stream.asBroadcastStream();
    syncNeedCtrl = new StreamController();
    onSyncNeed = syncNeedCtrl.stream.asBroadcastStream();
  }

  ///Gets info, whether this storrage is synced.
  Future<int> getVersion({deep: false}){
    var c = new Completer<int>();
    if(deep){
      getAll(inclDeleted: true).then((all){
        if(all!=null && all.isNotEmpty){
          var m = 0;
          for(var item in all){
            m = max(m, item.Version==null? 0 : item.Version);
          }
          version = m;
        }
        c.complete(version);
      });
    }else{
      c.complete(version);
    }
    return c.future;
  }
  ///Merge item with the one in DB.
  Future<T> merge({T item, String syncId, String oldId, sync:GeneralDO.SYNC_OK}){
    var c = new Completer<T>();
    if(oldId==null){
      oldId = item.Id;
    }
    LOG.finest('Merging item with ID: ${oldId}. Item:${item.toJson()}');
    getById(oldId, inclDeleted: true).then((child){
      if(child==null){
        child = item;
        //child.Id = id;
        insert(child, sync:sync).then((T savedItem){
          LOG.finest('Merged (Inserted) item :${savedItem.toJson()}');
          c.complete(savedItem);
        });

      }else{
        var idChanged = item.Id != oldId;
        child.merge(item);
        update(child, sync:sync, oldId: oldId).then((T savedItem){
          LOG.finest('Merged (UPDATED) item :${savedItem.toJson()}');
          if(idChanged){
            idchangeCtrl.add(new StoreChange(oldId, savedItem.Id));
          }

          c.complete(savedItem);
        });
      }
    });
    return c.future;
  }
  ///Gets info, whether this storrage is synced.
  Future<bool> isSync({deep: false}){
    var c = new Completer();
    if(deep){
      synced = true;
      store.all().listen((map){
        if(map!=null){
          var obj = _fromDbObj(map);
          if(obj!=null && obj.Sync != GeneralDO.SYNC_OK){
            LOG.finest('Found not synced child: $map');
            synced = false; //TODO stop looping
//            syncNeedCtrl.add(!synced);
          }
        }
      }, onDone:(){
        c.complete(synced);
      });
    }else{
      c.complete(synced);
    }
    return c.future;
  }

  ///Gets [GeneralDO] by it's [id].
  Future<T> getById(String id,{ bool inclDeleted:false}){
    return super.getById(id).then((obj){
      if(obj!=null && (inclDeleted || obj.Sync != GeneralDO.SYNC_DELETE)){
        return obj;
      }else{
        if(obj!=null){
          LOG.warning('getById returns null (item deleted and ready to sync');
        }
        return null;

      }
    });
  }

  @override
  Future<Stream<T>> streamAllByIndex(String idxName,{Object only, Object lower, Object upper, bool lowerOpen:false, bool upperOpen:false, bool inclDeleted:false} ) {
    if(inclDeleted){
      return super.streamAllByIndex(idxName, only: only, lower: lower, upper: upper, lowerOpen: lowerOpen, upperOpen: upperOpen);
    }else{
      return super.streamAllByIndex(idxName, only: only, lower: lower, upper: upper, lowerOpen: lowerOpen, upperOpen: upperOpen).then((stream){
        return stream.where((act)=>(act.Sync!=GeneralDO.SYNC_DELETE));
      });
    }
  }

  ///Gets all [GeneralDO] items of this [Storage].
  Future<List<T>> getAll({bool inclDeleted:false}){
    return super.getAll().then((all){
      if(!inclDeleted && all!=null){
        var all2 = new List();
        all.forEach((obj){
          if(obj.Sync != GeneralDO.SYNC_DELETE){
            all2.add(obj);
          }
        });
        return all2;
      }else{
        return all;
      }
    });
  }
  ///Gets all [GeneralDO] items as [Map] of this [Storage].
  Future<List<Map>> getAllAsMap({bool inclDeleted:false}){
    return super.getAllAsMap().then((all){
      if(!inclDeleted && all!=null){
        var all2 = new List();
        all.forEach((obj){
          if(obj['Sync'] != GeneralDO.SYNC_DELETE){
            all2.add(obj);
          }
        });
        return all2;
      }else{
        return all;
      }
    });
  }

  ///Insert [GeneralDO] item into [Storage].
  Future<T> insert(T item,{ sync: GeneralDO.SYNC_CREATE, bool generateId: true}){
    if(sync!=GeneralDO.SYNC_OK){
      synced = false;
      if(!suppressStreams) syncNeedCtrl.add(!synced);
    }else{
      generateId = false; //sync ok must have own ID
    }
    item.Sync = sync;
    return super.insert(item,  generateId: generateId );
  }

  ///Update [GeneralDO] item in [Storage].
  Future<T> update(T item, {sync: GeneralDO.SYNC_UPDATE, String oldId, bool quiet:false }){

    if(item.Sync != GeneralDO.SYNC_CREATE || sync == GeneralDO.SYNC_OK){
      item.Sync = sync;
    }
    if(sync != GeneralDO.SYNC_OK){
      synced = false;
      if(!suppressStreams) syncNeedCtrl.add(!synced);
    }

    return super.update(item, oldId: oldId , quiet: quiet );
  }

  ///Remove [GeneralDO] item from [Storage] by its Id.
  Future<bool> removeById(String id, {sync: GeneralDO.SYNC_DELETE}){
    return getById(id, inclDeleted: true).then((T val){
      return remove(val, sync:sync);
    });
  }

  ///Remove [GeneralDO] item from [Storage].
  Future<bool> remove(T item, {sync: GeneralDO.SYNC_DELETE}){
    var c = new Completer();
    if(item!=null){
      if(item.Sync == GeneralDO.SYNC_CREATE || sync == GeneralDO.SYNC_OK ){

        store.removeByKey(item.Id).then((_){
          LOG.finest('Item HARD DELETE with id: ${item.Id}');
          c.complete(true);
          if(!suppressStreams) removeCtrl.add(item.Id);
        }, onError: (err){
          c.completeError(err);
        });
      }else{
        item.Sync = GeneralDO.SYNC_DELETE;
        update(item, sync: GeneralDO.SYNC_DELETE, quiet:true).then((item){
          LOG.finest('Item MARK DELETE with id: ${item.Id}');
          c.complete(true);
          if(!suppressStreams) removeCtrl.add(item.Id);
        }, onError: (err){
          c.completeError(err);
        });
      }
    }else{
      c.completeError("No item.");
    }
    return c.future;
  }

  ///Clear [Storage].
  Future<bool> clear(){
    return super.clear().then((_){
      version = 0;
      synced = true;
      return true;
    });
  }
}


class StoreChange{
  String oldId;
  String newId;
  StoreChange(this.oldId, this.newId);
}



abstract class LocalStorage<T extends LocalDO> extends LDLocalStorage<T>{
  LocalStorage(String tableName, {String dbName}): super(tableName, dbName: dbName);
}

abstract class SyncStorage<T extends GeneralDO> extends LDStorage<T>{
  SyncStorage(String tableName, {String dbName, List<IndexDesc> indexes}): super(tableName, dbName: dbName, indexes: indexes);
}



