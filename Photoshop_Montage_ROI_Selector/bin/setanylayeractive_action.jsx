// This code was presented by Michael L Hale, on Jul 15, 2010
// Accessed 9/10/2014, https://forums.adobe.com/thread/681042
// Modified slightly by Robert Cooper on 9/10/2014, for readability and utility
// in the Photoshop/MATLAB ROI extraction script
 
    var re = "JG_10182_790nm_OS_confocal_0000_ref_113_lps_60_lbss_60_sr_n_50_cropped_5.tif";// a reg exp  
    //var re = "KS_0931_796nm_OD_0008_ref_3_lps_20_lbss_18_sr_n_30_cropped_4";// a reg exp  
    var matches = collectNamesAM(re);// get array of matching layer indexes  
    for( var l = 0; l < matches.length; l++ ){  
        makeActiveByIndex( matches[l], false );  
        // do something with layer  
        //alert(app.activeDocument.activeLayer.name);  
    }// next match if any  
      
    function collectNamesAM(re){  
         var allLayers = new Array();  
       var startLoop = Number( !hasBackground() );  
       var endLoop = getNumberOfLayer();   
       for( var l = startLoop;l <= endLoop; l++){  
            while( !isValidActiveLayer( l ) ) {  
                l++;  
            }  
            if( getLayerNameByIndex( l ).match(re) != null){  
                allLayers.push( l );  
            }  
        }  
         return allLayers;  
    };
    /*//////////////////////////////////////////////////////////////////////////////  
    // Function: getActiveLayerIndex  
    // Description: Gets gets the Action Manager API index  
    //                        of activeLayer corrected for Background Layer  
    // Usage: var idx = getActiveLayerIndex();  
    // Input: None  
    // Return: Number - correct AM itemIndex  
    // Dependices: hasBackground  
    //////////////////////////////////////////////////////////////////////////////*/  
    function getActiveLayerIndex() {  
         var ref = new ActionReference();  
         ref.putProperty( 1349677170 , 1232366921 );  
         ref.putEnumerated( 1283027488, 1332896878, 1416783732 );  
         var res = executeActionGet(ref).getInteger( 1232366921 )  
                                                           - Number( hasBackground() );  
         res == 4 ? res++:res;
         return res;     
    }

    /*//////////////////////////////////////////////////////////////////////////////  
    // Function: isValidActiveLayer( )  
    // Description: Checks LayerSection for 'real' layers  
    // Usage: if( isValidActiveLayer() )  
    // Input: None  
    // Return: Boolean - True if not the end of a Set  
    // Notes:  Needed only if the layer was made active  
    //               using Action Manager API  
    //////////////////////////////////////////////////////////////////////////////*/  
    function isValidActiveLayer( idx ) {  
         var propName = stringIDToTypeID( 'layerSection' );// can't replace  
         var ref = new ActionReference();   
         ref.putProperty( 1349677170 , propName);// TypeID for "Prpr"  
         // 'Lyr ", idx  
         ref.putIndex( 1283027488, idx );  
         var desc =  executeActionGet( ref );  
         var type = desc.getEnumerationValue( propName );  
         var res = typeIDToStringID( type );   
         return res == 'layerSectionEnd' ? false:true;  
    };

    /*//////////////////////////////////////////////////////////////////////////////  
    // Function: hasBackground  
    // Description: Test for background layer using AM API  
    // Usage: if( hasBackground() );  
    // Input: None  
    // Return: Boolean - true if doc has background layer  
    // Notes:  Requires the document to be active  
    //  DOM:  App.Document.backgroundLayer  
    //////////////////////////////////////////////////////////////////////////////*/  
//~     function hasBackground(){  
//~         var res = undefined;  
//~         try{  
//~             var ref = new ActionReference();  
//~             ref.putProperty( 1349677170 , 1315774496);   
//~             ref.putIndex( 1283027488, 0 );  
//~             executeActionGet(ref).getString(1315774496 );;   
//~             res = true;  
//~         }catch(e){ res = false}  
//~         return res;  
//~     }; 
   function hasBackground() {
       var ref = new ActionReference();
       ref.putProperty( charIDToTypeID("Prpr"), charIDToTypeID( "Bckg" ));
       ref.putEnumerated(charIDToTypeID( "Lyr " ),charIDToTypeID( "Ordn" ),charIDToTypeID( "Back" ));
       var desc =  executeActionGet(ref);
       var res = desc.getBoolean(charIDToTypeID( "Bckg" ));
       return res ; 
    };

    function makeActiveByIndex( idx, forceVisible ){  
         try{  
              var desc = new ActionDescriptor();  
              var ref = new ActionReference();  
              ref.putIndex(charIDToTypeID( "Lyr " ), idx)  
              desc.putReference( charIDToTypeID( "null" ), ref );  
              desc.putBoolean( charIDToTypeID( "MkVs" ), forceVisible );  
              executeAction( charIDToTypeID( "slct" ), desc, DialogModes.NO );  
         }catch(e){ return -1;}  
    };

    function getNumberOfLayer(){   
    var ref = new ActionReference();   
    ref.putEnumerated( charIDToTypeID("Dcmn"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt") );   
    var desc = executeActionGet(ref);   
    var numberOfLayer = desc.getInteger(charIDToTypeID("NmbL"));   
    return numberOfLayer;   
    }; 

    function getLayerNameByIndex( idx ) {   
        var ref = new ActionReference();   
        ref.putProperty( charIDToTypeID("Prpr") , charIDToTypeID( "Nm  " ));   
        ref.putIndex( charIDToTypeID( "Lyr " ), idx );  
        return executeActionGet(ref).getString(charIDToTypeID( "Nm  " ));;   
    };  