// Robert Cooper 09-08-2014
// This script ungroups all of the layers, so that we can do a quick dissection of the layers.
// The ActionReference codes were determined by putting a ScriptListener on photoshop, 
// then perform the action to get the event ID and class ID to construct the reference.
$.writeln("--------- SCRIPT BEGINS ---------");
var unrolledcount = 0;
var i=0;

 while( i < app.activeDocument.layerSets.length ){
     var layergroup = app.activeDocument.layerSets[i];
     
     //$.writeln( layergroup.name)
     
    if( layergroup.visible ){
        app.activeDocument.activeLayer = layergroup;
        ungroupLayerSet();
        unrolledcount++;
        i=0;
    }else{
        i++;
    }
 }
 
 function ungroupLayerSet() {
     var desc = new ActionDescriptor();
     var ref = new ActionReference();
     ref.putEnumerated( charIDToTypeID( "Lyr " ), charIDToTypeID( "Ordn" ), charIDToTypeID( "Trgt" ) );
     desc.putReference( charIDToTypeID( "null" ), ref );
     try {
         executeAction( stringIDToTypeID( "ungroupLayersEvent" ), desc, DialogModes.NO );
     } catch(e) {$.write(e)}
 }
 unrolledcount;