var fs = require('fs');

function writeuint8array(filename) {
  var infilename = filename;
  var outfilename = "../prime/"+filename+".uint8array";
  
  console.log(outfilename)
  fs.readFile(infilename, 'utf8', function (err, readdata) {
    var textArray = readdata.split(",");
    var dataarray=[];
    for (var i=0; i<textArray.length; i++) {
      dataarray = dataarray.concat(parseInt(textArray[i]))
    }
    
    var data = new Uint8Array(dataarray);
    
    //https://nodejs.org/api/buffer.html
    var buffer = new Buffer(data.length); //1 byte per int aka 8bit per int
    for(var i = 0; i < data.length; i++){
        //write the float in Little-Endian and move the offset
        buffer.writeUInt8(data[i], i);
        //buffer.writeUIntLE(data[i], i*2, 2); //maybe this one is the correct one? lets test the other first
    }
    
    var wstream = fs.createWriteStream(outfilename);
    wstream.write(buffer);
    wstream.end();

  })
}

var filenames=["mz_311_1","mz_311_2","mz_311_3","mz_330_1","mz_330_2","mz_330_3","mz_331_1","mz_331_2","mz_331_3","mz_332_1","mz_332_2","mz_332_3","mz_333_1","mz_333_2","mz_333_3","mz_545_1","mz_545_2","mz_545_3","mz_570_1","mz_570_2","mz_570_3"]
for (var n=0; n<filenames.length; n++) {
  writeuint8array(filenames[n])
}
