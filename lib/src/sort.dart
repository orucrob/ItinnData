part of itinndata;


class Sort<T extends GeneralDO>{
  bool on = true;
  List<String> sortFields;
  List<bool> sortAsc;
  bool ignoreCase = true;

  int _compare(int level, Map a, Map b){
    var valA = a[sortFields[level]];
    var valB = b[sortFields[level]];
    if(valA==null && valB==null){
      return 0;
    }
    if(valA==null){
      return -1;
    }
    if(valB==null){
      return 1;
    }
    if(ignoreCase){
      if(valA is String){
        return valA.toLowerCase().compareTo(valB.toLowerCase());
      }else{
        return valA.compareTo(valB);
      }
    }else{
      return valA.compareTo(valB);
    }
  }

  ///filter items represented as list of [Map]s
  List<Map> sort(List<Map> all) {
    if(sortFields!=null && sortFields.isNotEmpty){
      all.sort((Map a, Map b){
        var result = 0 ;
        var idx = 0;
        while (result == 0 && idx<sortFields.length ){
          result = _compare(idx, a, b);
          idx++;
        }

        idx--;
        if(sortAsc!=null && idx < sortAsc.length && !sortAsc[idx]){
          result = result * (-1); //desc
        }

        return result;
      });
    }

    return all;
  }
}
