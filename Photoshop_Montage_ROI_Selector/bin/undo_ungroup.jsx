// Robert Cooper
// This script ungroups all of the layers, so that we can do a quick dissection of the layers.
// The ActionReference codes were determined by Mike Hale- in order to reproduce, one would need to put a 
// ScriptListener on photoshop, then perform the action to get the event ID and class ID to construct the reference.
$.writeln("--------- SCRIPT BEGINS ---------");

for(var i=0;i<6;i++){
     var desc = new ActionDescriptor();
     var ref = new ActionReference();
     ref.putEnumerated( charIDToTypeID( "HstS" ), charIDToTypeID( "Ordn" ), charIDToTypeID( "Prvs" )  );
     desc.putReference( charIDToTypeID( "null" ), ref );
     try {
         executeAction( charIDToTypeID( "slct" ), desc, DialogModes.NO );
     } catch(e) {
         $.writeln(e)
     }
  }
