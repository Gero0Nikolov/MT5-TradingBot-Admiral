bool is_risky_deal( int type ) {
    bool flag = false;
    int in_library = exists_in_library( trend_.rsi, trend_.bulls_power, type );

    if ( in_library > -1 ) { // Make an inspection only if position exists in library, otherwise we can't know :|
        flag = library_[ in_library ].success == true ? false : true;        
    }    

    return flag;
}