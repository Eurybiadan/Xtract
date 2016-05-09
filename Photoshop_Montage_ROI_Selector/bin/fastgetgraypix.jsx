
var desc = new ActionDescriptor();
desc.putString( charIDToTypeID( "ChnN" ), "Gray" );

var rectDesc = new ActionDescriptor();
// Values are for layer: JC_0677_790nm_OS_confocal_0128_ref_42_lps_12_lbss_10_sr_n_50_cropped_5
rectDesc.putInteger( app.charIDToTypeID( "Top " ), 385);
rectDesc.putInteger( app.charIDToTypeID( "Left" ), 6594);
rectDesc.putInteger( app.charIDToTypeID( "Btom" ), 1175);
rectDesc.putInteger( app.charIDToTypeID( "Rght" ), 7270);

desc.putObject( app.charIDToTypeID( "T   " ),  app.charIDToTypeID( "Type" ), rectDesc );

var result = executeActionGet( desc);

result;