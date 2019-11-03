bool is_risky_deal( string type ) {
    bool flag = false;

    if ( 
        type == "sell" &&
        day_.yesterday_direction == "sell"
    ) {        
        flag = true;
    } else if ( 
        type == "buy" &&
        day_.yesterday_direction == "buy"
    ) {
        flag = true;
    }

    return flag;
}