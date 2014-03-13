library store_tests;

import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'package:itinndata/itinndata.dart';
import 'dart:async';

run(StorageCtrl ctrl) {

  group('validation',(){
    test('not null',(){
      expect(ctrl.storeClob, isNotNull);
      expect(ctrl.storeSett, isNotNull);
      expect(ctrl.storeUser, isNotNull);
    });
  });

  group('initialization',(){
    test('init',(){
      var f = ctrl.init();
      expect(f, completion(true));
      return f;
    });
    test('clear',(){
      var f = ctrl.clearAll();
      expect(f, completion(true));
      return f;
    });
  });

  group('inserts and count store user',(){
    test('single insert', (){
      UserDO user = new UserDO();
      user.Name = "aaaa";
      var f = ctrl.storeUser.insert(user);
      expect(f, completes);
      f.then((item){
        print('inserted');
        expect(item.Sync, GeneralDO.SYNC_CREATE);
        expect(ctrl.storeUser.lastIdCounter, equals(1), reason:"Last ID of first record is not 1." );
      });
      return f;
    });
    test('second insert', (){
      UserDO user = new UserDO();
      user.Name = "bbbbb";
      var f = ctrl.storeUser.insert(user);
      expect(f, completes);
      f.then((item){
        print('inserted');
        expect(item.Sync, GeneralDO.SYNC_CREATE);
        expect(ctrl.storeUser.lastIdCounter, equals(2), reason:"Last ID of secind record is not 2." );
      });
      return f;
    });
    test('count 2 items', (){
      var f = ctrl.storeUser.getAll();
      expect(f, completes);
      f.then((all){
        expect(all, hasLength(2));
      });
      return f;
    });
    test('bulk insert', (){
      var counter = 100;
      var futures = new List();
      while(counter-->0){
        UserDO user = new UserDO();
        user.Name = "Name-$counter";
        var f = ctrl.storeUser.insert(user);
        expect(f, completes);
        futures.add(f);
      }
      var f = Future.wait(futures);
      expect(f, completes);
      return f;
    });
    test('count after bulk', (){
      var f = ctrl.storeUser.getAll();
      expect(f, completes);
      f.then((all){
        expect(all, hasLength(102));
      });
      return f;
    });


  });
}

main() {
  var ctrl;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.loggerName}: ${rec.time}: ${rec.message}');
  });

  group('constructor', () {
    test('store controller instance returns', () {
      ctrl = new StorageCtrl('dbName');
      expect(ctrl,isNotNull);
    });
  });

  group('run', () {
    run(new StorageCtrl('dbName'));
  });
}