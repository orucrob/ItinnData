part of itinndata;
//App app;

class ImageUtil{

  static const String emptyImg = 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs%3D';

  ///Conver base64 [dataUrl] to [Blob]
  static Blob dataUrlToBlob(String dataUrl){

    var byteString = Base64String.decode(dataUrl.split(',')[1]);
    var mimeString = dataUrl.split(',')[0].split(':')[1].split(';')[0];
     // var ab = new ArrayBuffer(byteString.length);
     var ia = new Uint8List(byteString.length);
     for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.codeUnitAt(i);
     }

    var blob =  new Blob([ia], mimeString );

    return blob;
  }
  ///process file -> return image as base64 string or Blob based on parameters
  static Future<dynamic> processFile(Blob f, {bool shrinkImage: true, bool base64:true, int shrinkWidth: 600} ){
    var c = new Completer<dynamic>();
    //      _onStratProcessingCtrl.add(f.name);
    if(shrinkImage && base64){ //base64 and shrink
      resizeImageToDataUrl(f, shrinkWidth:shrinkWidth).then((dataUrl){
        c.complete(dataUrl);
      });
    }else if(shrinkImage){ //not base64 and shrink
      resizeImageToDataUrl(f, shrinkWidth:shrinkWidth).then((dataUrl){
        var ff = dataUrlToBlob(dataUrl);
        c.complete(ff);
      });
    }else if(!shrinkImage && base64){ //base64 and not shrink
      var reader = new FileReader();
      reader.onLoad.listen((event){
        c.complete(reader.result);
      });
      reader.readAsDataUrl(f);
    }else{ //not base and not shrink
      //_onInputCtrl.add(f);
      c.complete(f);
    }
    return c.future;
  }
  ///resizes image [f] according to param [shrinkWidth]. Image is returned as dataurl [String].
  static Future<String> resizeImageToDataUrl(Blob f, {int shrinkWidth:600}){
    int width = shrinkWidth;
    var c = new Completer<String>();
    var reader = new FileReader();

    reader.onLoad.first.then((_){
//      app.log('resizing image - onload start');
      var data = reader.result; //event.target.result;
      ImageElement img = new ImageElement(src: data);
      img.onLoad.first.then((ev){
//        app.log('resizing image - onload img');
        var height;
        if(img.width>width){
          var ratio = img.width/width;
          height =  (img.height/ratio).ceil();
        }else{
          width = img.width;
          height = img.height;
        }
        CanvasElement cvs = new CanvasElement(width: width, height:height);

//        app.log('resizing image - ios hack');
        var vertSquashRatio = detectVerticalSquash(img);//iOS hack

        cvs.context2D.drawImageScaled(img, 0, 0, width, height/vertSquashRatio);
        var dataUrl = cvs.toDataUrl('image/png');
        //print('resizing image done:$dataUrl');
        c.complete(dataUrl);
//        app.log('resizing image - onload END');
      });
    });

    reader.readAsDataUrl(f);
    return c.future;
  }
  /**
   * Detecting vertical squash in loaded image.
   * Fixes a bug which squash image vertically while drawing into canvas for some images.
   * This is a bug in iOS6 devices. This function from https://github.com/stomita/ios-imagefile-megapixel
   */
  static num detectVerticalSquash(ImageElement img) {
    var iw = img.naturalWidth, ih = img.naturalHeight;
    var canvas = document.createElement('canvas');
    CanvasElement cvs = new CanvasElement(width: 1, height:ih);
    var ctx = cvs.context2D;
    ctx.drawImage(img, 0, 0);
    var data = ctx.getImageData(0, 0, 1, ih).data;
    // search image edge pixel position in case it is squashed vertically.
    var sy = 0;
    var ey = ih;
    var py = ih;
    while (py > sy) {
        var alpha = data[(py - 1) * 4 + 3];
        if (alpha == 0) {
            ey = py;
        } else {
            sy = py;
        }
        py = (ey + sy).ceil() >> 1;
    }
    var ratio = (py / ih);
    return (ratio==0)?1:ratio;
  }
}

class Base64String {
  static const List<String> _encodingTable = const [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
      'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
      't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
      '8', '9', '+', '/'];

  static String encode(String income ) {

    List<int> data = income.codeUnits;

    List<String> characters = new List<String>();
    int i;
    for (i = 0; i + 3 <= data.length; i += 3) {
      int value = 0;
      value |= data[i + 2];
      value |= data[i + 1] << 8;
      value |= data[i] << 16;
      for (int j = 0; j < 4; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
    }
    // Remainders.
    if (i + 2 == data.length) {
      int value = 0;
      value |= data[i + 1] << 8;
      value |= data[i] << 16;
      for (int j = 0; j < 3; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
      characters.add("=");
    } else if (i + 1 == data.length) {
      int value = 0;
      value |= data[i] << 16;
      for (int j = 0; j < 2; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
      characters.add("=");
      characters.add("=");
    }
    StringBuffer output = new StringBuffer();
    for (i = 0; i < characters.length; i++) {
      if (i > 0 && i % 76 == 0) {
        output.write("\r\n");
      }
      output.write(characters[i]);
    }
    return output.toString();
  }


  static String decode(String data) {
    List<int> result = new List<int>();
    int padCount = 0;
    int charCount = 0;
    int value = 0;
    for (int i = 0; i < data.length; i++) {
      int char = data.codeUnitAt(i);
      if (65 <= char && char <= 90) {  // "A" - "Z".
        value = (value << 6) | char - 65;
        charCount++;
      } else if (97 <= char && char <= 122) { // "a" - "z".
        value = (value << 6) | char - 97 + 26;
        charCount++;
      } else if (48 <= char && char <= 57) {  // "0" - "9".
        value = (value << 6) | char - 48 + 52;
        charCount++;
      } else if (char == 43) {  // "+".
        value = (value << 6) | 62;
        charCount++;
      } else if (char == 47) {  // "/".
        value = (value << 6) | 63;
        charCount++;
      } else if (char == 61) {  // "=".
        value = (value << 6);
        charCount++;
        padCount++;
      }
      if (charCount == 4) {
        result.add((value & 0xFF0000) >> 16);
        if (padCount < 2) {
          result.add((value & 0xFF00) >> 8);
        }
        if (padCount == 0) {
          result.add(value & 0xFF);
        }
        charCount = 0;
        value = 0;
      }
    }

    return new String.fromCharCodes( result );
  }
}