
var fsReadDir = require('./module/fsReadDir');
var fsReadFile = require('./module/fsReadFile');
var saveData = require('./module/saveData');

var dir = "/home/allen/testdata";

fsReadDir.readDir(dir, fsReadFile.readFile, saveData.save);



      

