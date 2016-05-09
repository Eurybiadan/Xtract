function getLayerSetsIndex(){
    
   var i = getNumberLayers();
   var res = new Array();
   
  
   var prop =  stringIDToTypeID("layerSection"); 
   
   var startingsectiondepth = 0;
   var sectiondepth = 0;
   var visibilitylock = false;
   
    for(i; i > hasBackground() ;i--){
      var type = getLayerType(i,prop);
      
       if( type == "layerSectionStart" && getLayerName(i).match("""1.5""" ){
                
       }

    }
   return res;
   
   function getNumberLayers(){
       var ref = new ActionReference();
       ref.putProperty( charIDToTypeID("Prpr") , charIDToTypeID("NmbL") );
       ref.putEnumerated( charIDToTypeID("Dcmn"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );
       return executeActionGet(ref).getInteger(charIDToTypeID("NmbL"));
   }

   function hasBackground() {
       var ref = new ActionReference();
       ref.putProperty( charIDToTypeID("Prpr"), charIDToTypeID( "Bckg" ));
       ref.putEnumerated(charIDToTypeID( "Lyr " ),charIDToTypeID( "Ordn" ),charIDToTypeID( "Back" ));
       var desc =  executeActionGet(ref);
       var res = desc.getBoolean(charIDToTypeID( "Bckg" ));
       if(res){
            return 1;
       }else{
            return 0;
       }
    };

   function getLayerType(idx,prop) {
       var ref = new ActionReference();
       ref.putIndex(charIDToTypeID( "Lyr " ), idx);
       var desc =  executeActionGet(ref);
       var type = desc.getEnumerationValue(prop);
       var res = typeIDToStringID(type);
       return res;   
    };

    function getLayerName(idx){
        var ref = new ActionReference();
        ref.putProperty( charIDToTypeID("Prpr"), charIDToTypeID("Nm  ") );
        ref.putIndex( charIDToTypeID("Lyr "), idx);
        var desc = executeActionGet(ref);
        var res = desc.getString( charIDToTypeID("Nm  ") );
        return res;
    };

    function isVisible( idx ) {
        var ref = new ActionReference();
        ref.putProperty( charIDToTypeID("Prpr") , charIDToTypeID( "Vsbl" ));
        ref.putIndex( charIDToTypeID( "Lyr " ), idx );
        return executeActionGet(ref).getBoolean(charIDToTypeID( "Vsbl" ));
    };
};
var allnames = getLayerSetsIndex();

allnames;