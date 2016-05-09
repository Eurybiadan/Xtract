

function selectBackgroundLayer(){;
        try{;
            var idslct = charIDToTypeID( "slct" );
            var desc13 = new ActionDescriptor();
            var idnull = charIDToTypeID( "null" );
                var ref12 = new ActionReference();
                var idLyr = charIDToTypeID( "Lyr " );
                ref12.putName( idLyr, "Background" );
            desc13.putReference( idnull, ref12 );
            var idMkVs = charIDToTypeID( "MkVs" );
            desc13.putBoolean( idMkVs, false );
        executeAction( idslct, desc13, DialogModes.NO );
        return true;
    
        }catch(e){;
            return false;
        }
};

function showByName() {  
    var desc = new ActionDescriptor();  
        var list = new ActionList();  
            var ref = new ActionReference();  
            ref.putName( charIDToTypeID('Lyr '), "Background" );  
        list.putReference( ref );  
    desc.putList( charIDToTypeID('null'), list );  
    executeAction( charIDToTypeID('Shw '), desc, DialogModes.NO );  
};

selectBackgroundLayer();
showByName();