library itinndata;

import 'package:lawndart_ext/lawndart_ext.dart' as ld;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:observe/observe.dart';

import 'dart:html';
import 'dart:typed_data';


part 'src/filter.dart';
part 'src/model.dart';
part 'src/sort.dart';
part 'src/storage.dart';
part 'src/storagecontrol.dart';
part 'src/storagemodel.dart';

part 'src/util.dart';



class ItinnDataContext {
  static final ItinnDataContext _singleton = new ItinnDataContext._internal();

  factory ItinnDataContext() {
    return _singleton;
  }
  ItinnDataContext._internal();

  ///logger for library
  final Logger LOG = new Logger('itinndata');

  ///get random string
  static String randomStrings(num length) {
    var rnd = new Random();
    var testVals = new Set<String>();
    int a = 'a'.codeUnitAt(0);
    var buffer = new StringBuffer();
    for(int k = 0; k<length; k++) {
      int randomChar = rnd.nextInt(26) + a;
      buffer.writeCharCode(randomChar);
    }
    return buffer.toString();
  }
}
