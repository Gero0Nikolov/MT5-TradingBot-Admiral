bool should_open( int type ) {
    bool flag = false;

    if ( type == -1 ) { // Sell
        if (
            hour_.is_in_direction( "sell" ) &&
            !hour_.is_big() &&
            trend_.rsi > 30 &&
            trend_.bulls_power < 0 &&
            !is_risky_deal( -1 ) &&
            // minute_.actual_price > trend_.risk_low_price &&
            // minute_.actual_price < trend_.risk_high_price &&
            minute_.opening_price - minute_.actual_price >= instrument_.opm
        ) { flag = true; }
    } else if ( type == 1 ) {
        if (
            hour_.is_in_direction( "buy" ) &&
            !hour_.is_big() &&
            trend_.rsi < 70 &&
            trend_.bulls_power > 0 &&
            !is_risky_deal( 1 ) &&
            // minute_.actual_price > trend_.risk_low_price &&
            // minute_.actual_price < trend_.risk_high_price &&
            minute_.actual_price - minute_.opening_price >= instrument_.opm
        ) { flag = true; }
    }

    return flag;
}

bool should_open_virtual_positions( int type ) {
    bool flag = false;

    if ( type == -1 ) { // Sell
        if (
            hour_.is_in_direction( "sell" ) &&
            !hour_.is_big() &&
            trend_.rsi > 30 &&
            trend_.bulls_power < 0 &&
            !in_library( -1 ) &&
            // minute_.actual_price > trend_.risk_low_price &&
            // minute_.actual_price < trend_.risk_high_price &&
            minute_.opening_price - minute_.actual_price >= instrument_.opm
        ) { flag = true; }
    } else if ( type == 1 ) {
        if (
            hour_.is_in_direction( "buy" ) &&
            !hour_.is_big() &&
            trend_.rsi < 70 &&
            trend_.bulls_power > 0 &&
            !in_library( 1 ) &&
            // minute_.actual_price > trend_.risk_low_price &&
            // minute_.actual_price < trend_.risk_high_price &&
            minute_.actual_price - minute_.opening_price >= instrument_.opm
        ) { flag = true; }
    }

    return flag;
}