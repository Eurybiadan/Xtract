function getLayerBoundaries(){
    
   var i = getNumberLayers();
   var res =[];
 
 // This doesn't work if the user makes a layer into the background! So we'll just assume they do...
//~    if(hasBackground()){
//~          var hasbkgrd = 1;
//~       }else{
//~          var hasbkgrd = 0;
//~       }
  
   var prop =  stringIDToTypeID("layerSection") ;
   
   var startingsectiondepth = 0;
   var sectiondepth = 0;
   var visibilitylock = false;
   
    for(i; i > 1 ;i--){
     var type = getLayerType(i,prop);
      
    if( type == "layerSectionStart" ){
                sectiondepth++;   
    }else if( type == "layerSectionEnd" ){
                sectiondepth--;
    }         

    if( visibilitylock ){        
        if( type == "layerSectionEnd" && sectiondepth == startingsectiondepth){
            visibilitylock=false;
        }
    }else{
            if( type == "layerSectionStart" ){
                if( !isVisible( i ) ){
                    visibilitylock = true;
                    startingsectiondepth = (sectiondepth-1);
                }
            }else if( type == "layerSectionContent" && isVisible( i ) ){
                var laybound = getLayerBounds(i);
                res += laybound;
            }
      }
   }
    return res;

   function getNumberLayers(){
       var ref = new ActionReference();
       ref.putProperty( charIDToTypeID("Prpr") , charIDToTypeID("NmbL") );
       ref.putEnumerated( charIDToTypeID("Dcmn"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );
       return executeActionGet(ref).getInteger(charIDToTypeID("NmbL"));
   };

   function hasBackground() {
       var ref = new ActionReference();
       ref.putProperty( charIDToTypeID("Prpr"), charIDToTypeID( "Bckg" ));
       ref.putEnumerated(charIDToTypeID( "Lyr " ),charIDToTypeID( "Ordn" ),charIDToTypeID( "Back" ));
       var desc =  executeActionGet(ref);
       var res = desc.getBoolean(charIDToTypeID( "Bckg" ));
       return res ; 
    };

   function getLayerType(idx,prop) {        
       var ref = new ActionReference();
       ref.putIndex(charIDToTypeID( "Lyr " ), idx);
       var desc =  executeActionGet(ref);
       var type = desc.getEnumerationValue(prop);
       var res = typeIDToStringID(type);
       return res ;
    };

   function getLayerBounds(idx){
        var ref = new ActionReference();
        ref.putProperty( charIDToTypeID("Prpr"), stringIDToTypeID("bounds") );
        ref.putIndex( charIDToTypeID("Lyr "), idx);
        var desc = executeActionGet(ref);
        var boundsobj = desc.getObjectValue( stringIDToTypeID("bounds") );
        var res = [];
        res += (boundsobj.getUnitDoubleValue( stringIDToTypeID("left") ) )+ ",";
        res += (boundsobj.getUnitDoubleValue( stringIDToTypeID("top") ) )+ ",";
        res += ( boundsobj.getUnitDoubleValue( stringIDToTypeID("right") ) )+ ",";
        res += ( boundsobj.getUnitDoubleValue( stringIDToTypeID("bottom") )+ ";" );
        
        return res;
    };

   function isVisible( idx ) {
           var ref = new ActionReference();
           ref.putProperty( charIDToTypeID("Prpr") , charIDToTypeID( "Vsbl" ));
           ref.putIndex( charIDToTypeID( "Lyr " ), idx );
           return executeActionGet(ref).getBoolean(charIDToTypeID( "Vsbl" ));;
    };
};
var allbounds = getLayerBoundaries();

allbounds;