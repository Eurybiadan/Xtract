 
 function isRaster(){
    var ref = new ActionReference();
           ref.putEnumerated( charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );   
           var desc =  executeActionGet(ref);       
              var layerType = typeIDToStringID(desc.getEnumerationValue( stringIDToTypeID( "layerSection" )));
       if( layerType != "layerSectionContent" ) return;// return if layerSet
       if( desc.hasKey( stringIDToTypeID( "textKey" ) ) ) return LayerKind.TEXT;
       if( desc.hasKey( stringIDToTypeID( "smartObject" ) ) ) return LayerKind.SMARTOBJECT;// includes LayerKind.VIDEO
       if( desc.hasKey( stringIDToTypeID( "layer3D" ) ) ) return LayerKind.LAYER3D;
       if( desc.hasKey( stringIDToTypeID( "adjustment" ) ) ){
          switch(typeIDToStringID(desc.getList (stringIDToTypeID("adjustment")).getClass (0))){
             case "photoFilter" : return LayerKind.PHOTOFILTER;
             case "solidColorLayer" : return LayerKind.SOLIDFILL;
             case "gradientMapClass" : return LayerKind.GRADIENTMAP;
             case "gradientMapLayer" : return LayerKind.GRADIENTFILL;
             case "hueSaturation" : return LayerKind.HUESATURATION;
             case "colorLookup" : return; //this does not exist and errors with getting layer kind
             case "colorBalance" : return LayerKind.COLORBALANCE;
             case "patternLayer" : return LayerKind.PATTERNFILL;
             case "invert" : return LayerKind.INVERSION;
             case "posterization" : return LayerKind.POSTERIZE;
             case "thresholdClassEvent" : return LayerKind.THRESHOLD;
             case "blackAndWhite" : return LayerKind.BLACKANDWHITE;
             case "selectiveColor" : return LayerKind.SELECTIVECOLOR;
             case "vibrance" : return LayerKind.VIBRANCE;
             case "brightnessEvent" : return LayerKind.BRIGHTNESSCONTRAST;
             case  "channelMixer" : return LayerKind.CHANNELMIXER;
             case "curves" : return LayerKind.CURVES;
             case "exposure" : return LayerKind.EXPOSURE;
             // if not one of the above adjustments return - adjustment layer type
             default : return typeIDToStringID(desc.getList (stringIDToTypeID("adjustment")).getClass (0));
          }
       }
        return LayerKind.NORMAL;// if we get here normal should be the only choice left.
 };

isRaster() == LayerKind.NORMAL ? 1:0;