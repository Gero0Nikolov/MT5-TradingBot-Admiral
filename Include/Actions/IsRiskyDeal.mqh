bool is_risky_deal( string type ) {
    bool flag = false;

    // Calculate Risk Difference    
    double risk_difference = ( instrument_.tpm * hour_.actual_price ) + 10;

    if (
        type == "sell" &&
        (
            hour_.actual_price < trend_.risk_low_price_24 ||
            hour_.actual_price - trend_.risk_low_price_24 < risk_difference
        )
    ) {
        flag = true;
    } else if (
        type == "buy" &&
        (
            hour_.actual_price > trend_.risk_high_price_24 ||
            trend_.risk_high_price_24 - hour_.actual_price < risk_difference
        )
    ) {
        flag = true;
    }

    return flag;
}