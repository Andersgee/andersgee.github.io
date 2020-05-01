//https://stackoverflow.com/questions/20306750/what-is-a-compact-way-to-save-a-float32array-to-disk-on-node-js/23347027
var fs = require('fs');

function writef32array(folder,filename) {
  var infilename = folder+filename;
  var outfilename = folder+filename+".float32array";
  
  console.log(outfilename)
  fs.readFile(infilename, 'utf8', function (err, readdata) {
    var textArray = readdata.split(",");
    var dataarray=[];
    for (var i=0; i<textArray.length; i++) {
      dataarray = dataarray.concat(parseFloat(textArray[i]))
    }
    var data = new Float32Array(dataarray);
    var buffer = new Buffer(data.length*4); //4 bytes per float aka 32bit per float
    for(var i = 0; i < data.length; i++){
      buffer.writeFloatLE(data[i], i*4); //write in Little-Endian format, at offset
    }
    
    var wstream = fs.createWriteStream(outfilename);
    wstream.write(buffer);
    wstream.end();
  })
}

var alfanames = ["W","bz1","bz2","b","Ur1","Ur2","bh1","bh2","bm","Uh1","Uh2","Wh1","Wh2","br1","br2","Wr1","Wr2","Uz1","Uz2","Wz1","Wz2", "Wm"]
var betanames = ["W","bz1","bz2","b","Ur1","Ur2","bh1","bh2","bm","Uh1","Uh2","Wh1","Wh2","br1","br2","Wr1","Wr2","Uz1","Uz2","Wz1","Wz2", "Wm", "Wp1", "Wp2", "Wp3", "bp1", "bp2", "bp3"]

for (var n=0; n<alfanames.length; n++) {writef32array("alfa/",alfanames[n])}
for (var n=0; n<betanames.length; n++) {writef32array("beta1/",betanames[n])}
for (var n=0; n<betanames.length; n++) {writef32array("beta2/",betanames[n])}
for (var n=0; n<betanames.length; n++) {writef32array("beta3/",betanames[n])}
