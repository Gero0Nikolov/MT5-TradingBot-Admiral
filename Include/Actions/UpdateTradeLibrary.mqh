void update_trade_library( double rsi, double bulls_power, string type, bool is_sl ) {
    int type_ = type == "sell" ? -1 : 1;
    int in_library = exists_in_library( rsi, bulls_power, type_ );
    
    if ( in_library > -1 ) { // Change the Success property if needed
        update_element_in_library( in_library, is_sl );
    } else { // Add the Trade to the Library
        add_to_library( rsi, bulls_power, type_, is_sl );
    }   
}

int exists_in_library( double rsi, double bulls_power, int type ) {
    int key = -1;

    //rsi = NormalizeDouble( rsi, 0 );
    //bulls_power = NormalizeDouble( bulls_power, 0 );

    for ( int count_lib_elements = 0; count_lib_elements < ArraySize( library_ ); count_lib_elements++ ) {
        if ( 
            library_[ count_lib_elements ].rsi == rsi && 
            library_[ count_lib_elements ].bulls_power == bulls_power &&
            library_[ count_lib_elements ].type == type
        ) {
            key = count_lib_elements;
            break;
        }
    }

    return key;
}

void add_to_library( double rsi, double bulls_power, int type, bool is_sl ) {    
    int key = ArraySize( library_ );
    int new_size = ArraySize( library_ ) + 1;

    ArrayResize( library_, new_size );

    library_[ key ].success = !is_sl ? true : false;
    library_[ key ].rsi = rsi;
    library_[ key ].bulls_power = bulls_power;
    library_[ key ].type = type;    
}

void update_element_in_library( int key, bool is_sl ) {    
    library_[ key ].success = !is_sl ? true : false;
}