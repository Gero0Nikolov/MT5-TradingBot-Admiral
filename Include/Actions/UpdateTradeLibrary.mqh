void update_trade_library( double rsi, double bulls_power, string type, double price, bool is_sl ) {
    int type_ = type == "sell" ? -1 : 1;
    int in_library = exists_in_library( rsi, bulls_power, type_, price );
    
    if ( in_library > -1 ) { // Change the Success property if needed
        update_element_in_library( in_library, is_sl );
    } else { // Add the Trade to the Library
        add_to_library( rsi, bulls_power, type_, is_sl, price );
    }   
}

int exists_in_library( double rsi, double bulls_power, int type, double price ) {
    int key = -1;

    rsi = NormalizeDouble( rsi, 0 );
    bulls_power = NormalizeDouble( bulls_power, 0 );
    price = NormalizeDouble( price, 0 );

    for ( int count_lib_elements = 0; count_lib_elements < ArraySize( library_ ); count_lib_elements++ ) {
        if ( 
            library_[ count_lib_elements ].rsi == rsi && 
            library_[ count_lib_elements ].bulls_power == bulls_power &&
            library_[ count_lib_elements ].type == type &&
            library_[ count_lib_elements ].price == price
        ) {
            key = count_lib_elements;

            // Print( "Position: "+ key );
            // Print( "Success: "+ library_[ key ].success );
            // Print( "RSI: "+ library_[ key ].rsi );
            // Print( "BP: "+ library_[ key ].bulls_power );
            // Print( "Type: "+ library_[ key ].type );
            // Print( "Price: "+ library_[ key ].price );

            break;
        }
    }

    return key;
}

void add_to_library( double rsi, double bulls_power, int type, bool is_sl, double price ) {    
    int key = ArraySize( library_ );
    int new_size = ArraySize( library_ ) + 1;

    ArrayResize( library_, new_size );

    rsi = NormalizeDouble( rsi, 0 );
    bulls_power = NormalizeDouble( bulls_power, 0 );
    price = NormalizeDouble( price, 0 );

    library_[ key ].success = !is_sl ? true : false;
    library_[ key ].rsi = rsi;
    library_[ key ].bulls_power = bulls_power;
    library_[ key ].type = type;    
    library_[ key ].price = price;
}

void update_element_in_library( int key, bool is_sl ) {    
    library_[ key ].success = !is_sl ? true : false;
}

void print_library() {
    for ( int count_lib = 0; count_lib < ArraySize( library_ ); count_lib++ ) {
        Print( "Key: "+ count_lib );        
    }
}

void read_library() {
    for ( int item = 0; item < ArraySize( old_library ); item++ ) {
        string old_item[];
        bool split_result = StringSplit( old_library[ item ], StringGetCharacter( ",", 0 ), old_item );

        bool is_sl = old_item[ 0 ] == "true" ? false : true;        

        add_to_library( old_item[ 1 ], old_item[ 2 ], old_item[ 3 ], is_sl, old_item[ 4 ] );      
    }
}

void store_to_library() {   
    Print( "Start Storing" );

    Print( "#string old_library[] = {" );
    for ( int item = 0; item < ArraySize( library_ ); item++ ) {
        string element_ = library_[ item ].success +","+ library_[ item ].rsi +","+ library_[ item ].bulls_power +","+ library_[ item ].type +","+ library_[ item ].price;
        Print( "#\""+ element_ +"\"," );
    }
    Print( "#};" );

    Print( "End Storing" );
}