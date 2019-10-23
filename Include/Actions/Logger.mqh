void logger( string text, double value, string value_string = "" ) {
    if ( value != -69 ) {
        Print( text +": "+ value );
    } else {
        Print( text +": "+ value_string );
    }
}