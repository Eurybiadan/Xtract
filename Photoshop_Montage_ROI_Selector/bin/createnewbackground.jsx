

// =======================================================
var idMk = charIDToTypeID( "Mk  " );
    var desc2 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref1 = new ActionReference();
        var idLyr = charIDToTypeID( "Lyr " );
        ref1.putClass( idLyr );
    desc2.putReference( idnull, ref1 );
executeAction( idMk, desc2, DialogModes.NO );

// =======================================================
var idRset = charIDToTypeID( "Rset" );
    var desc3 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref2 = new ActionReference();
        var idClr = charIDToTypeID( "Clr " );
        var idClrs = charIDToTypeID( "Clrs" );
        ref2.putProperty( idClr, idClrs );
    desc3.putReference( idnull, ref2 );
executeAction( idRset, desc3, DialogModes.NO );

// =======================================================
var idMk = charIDToTypeID( "Mk  " );
    var desc4 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref3 = new ActionReference();
        var idBckL = charIDToTypeID( "BckL" );
        ref3.putClass( idBckL );
    desc4.putReference( idnull, ref3 );
    var idUsng = charIDToTypeID( "Usng" );
        var ref4 = new ActionReference();
        var idLyr = charIDToTypeID( "Lyr " );
        var idOrdn = charIDToTypeID( "Ordn" );
        var idTrgt = charIDToTypeID( "Trgt" );
        ref4.putEnumerated( idLyr, idOrdn, idTrgt );
    desc4.putReference( idUsng, ref4 );
executeAction( idMk, desc4, DialogModes.NO );