$.writeln("--------- SCRIPT BEGINS ---------");
var layers = app.activeDocument.artLayers;
var len = layers.length;
var background = layers[len-1]; // With the assumption that the background is always the last layer

app.activeDocument.activeLayer = background;

// This section resets the color palette to black/white
var idRset = charIDToTypeID( "Rset" );
    var desc63 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref47 = new ActionReference();
        var idClr = charIDToTypeID( "Clr " );
        var idClrs = charIDToTypeID( "Clrs" );
        ref47.putProperty( idClr, idClrs );
    desc63.putReference( idnull, ref47 );
executeAction( idRset, desc63, DialogModes.NO );

// This selects the bucket tool
var idslct = charIDToTypeID( "slct" );
    var desc84 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref60 = new ActionReference();
        var idbucketTool = stringIDToTypeID( "bucketTool" );
        ref60.putClass( idbucketTool );
    desc84.putReference( idnull, ref60 );
    var iddontRecord = stringIDToTypeID( "dontRecord" );
    desc84.putBoolean( iddontRecord, true );
    var idforceNotify = stringIDToTypeID( "forceNotify" );
    desc84.putBoolean( idforceNotify, true );
executeAction( idslct, desc84, DialogModes.NO );

// This block was copied from the action to fill
var idFl = charIDToTypeID( "Fl  " );
    var desc64 = new ActionDescriptor();
    var idFrom = charIDToTypeID( "From" );
        var desc65 = new ActionDescriptor();
        var idHrzn = charIDToTypeID( "Hrzn" );
        var idRlt = charIDToTypeID( "#Rlt" );
        desc65.putUnitDouble( idHrzn, idRlt, 100 );
        var idVrtc = charIDToTypeID( "Vrtc" );
        var idRlt = charIDToTypeID( "#Rlt" );
        desc65.putUnitDouble( idVrtc, idRlt, 100 );
    var idPnt = charIDToTypeID( "Pnt " );
    desc64.putObject( idFrom, idPnt, desc65 );
    var idTlrn = charIDToTypeID( "Tlrn" );
    desc64.putInteger( idTlrn, 0 );
    var idAntA = charIDToTypeID( "AntA" );
    desc64.putBoolean( idAntA, true );
    var idUsng = charIDToTypeID( "Usng" );
    var idFlCn = charIDToTypeID( "FlCn" );
    var idFrgC = charIDToTypeID( "FrgC" );
    desc64.putEnumerated( idUsng, idFlCn, idFrgC );
    var idCntg = charIDToTypeID( "Cntg" );
    desc64.putBoolean( idCntg, false );
executeAction( idFl, desc64, DialogModes.NO );