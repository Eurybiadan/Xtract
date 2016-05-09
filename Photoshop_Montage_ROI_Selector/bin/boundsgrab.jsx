$.writeln("--------- SCRIPT BEGINS ---------");
var layers = app.activeDocument.artLayers;
var len = layers.length;
var allbounds = ";";

    for(var i=0;i<len;i++){
            var layer = layers[i];
             if(layer.kind==undefined){
                     continue;
              }
            var laybounds = layers[i].bounds;
            allbounds = allbounds + laybounds[0].as("px") +","+ laybounds[1].as("px") +", "+ laybounds[2].as("px") + ","+laybounds[3].as("px")+";";
    
    }
allbounds;