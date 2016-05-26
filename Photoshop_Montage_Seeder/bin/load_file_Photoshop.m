function [  ] = load_file_Photoshop( filepath, shiftx, shifty, percentwidth, percentheight )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

script = ['var idPlc = charIDToTypeID( "Plc " );'...
'    var desc11 = new ActionDescriptor();'...
'    var idnull = charIDToTypeID( "null" );'...
'    desc11.putPath( idnull, new File( "' filepath '" ) );'...
'    var idFTcs = charIDToTypeID( "FTcs" );'...
'    var idQCSt = charIDToTypeID( "QCSt" );'...
'    var idQcsa = charIDToTypeID( "Qcsa" );'...
'    desc11.putEnumerated( idFTcs, idQCSt, idQcsa );'...
'    var idOfst = charIDToTypeID( "Ofst" );'...
'        var desc12 = new ActionDescriptor();'...
'        var idHrzn = charIDToTypeID( "Hrzn" );'...
'        var idPxl = charIDToTypeID( "#Pxl" );'...
'        desc12.putUnitDouble( idHrzn, idPxl, ' num2str(shiftx) ' );'...
'        var idVrtc = charIDToTypeID( "Vrtc" );'...
'        var idPxl = charIDToTypeID( "#Pxl" );'...
'        desc12.putUnitDouble( idVrtc, idPxl, ' num2str(shifty) ' );'...
'    var idOfst = charIDToTypeID( "Ofst" );'...
'    desc11.putObject( idOfst, idOfst, desc12 );'...
'    var idWdth = charIDToTypeID( "Wdth" );'...
'    var idPrc = charIDToTypeID( "#Prc" );'...
'    desc11.putUnitDouble( idWdth, idPrc, ' num2str(percentwidth) ' );'...
'    var idHght = charIDToTypeID( "Hght" );'...
'    var idPrc = charIDToTypeID( "#Prc" );'...
'    desc11.putUnitDouble( idHght, idPrc, ' num2str(percentheight) ' );'...
'    var idLnkd = charIDToTypeID( "Lnkd" );'...
'    desc11.putBoolean( idLnkd, true );'...
'    var idIntr = charIDToTypeID( "Intr" );'...
'    var idIntp = charIDToTypeID( "Intp" );'...
'    var idBcbc = charIDToTypeID( "Bcbc" );'...
'    desc11.putEnumerated( idIntr, idIntp, idBcbc );'...
'executeAction( idPlc, desc11, DialogModes.NO );' ];

psjavascript(script);

end
