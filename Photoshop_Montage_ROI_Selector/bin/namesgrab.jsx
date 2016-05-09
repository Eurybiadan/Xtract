$.writeln("--------- SCRIPT BEGINS ---------");
var layers = app.activeDocument.artLayers;
var len = layers.length;
var allnames = ";";

    for(var i=0;i<len;i++){
            var layer = layers[i];
             if(layer.kind==undefined){
                     continue;
              }
            allnames = allnames +layers[i].name+";";
    }
allnames;