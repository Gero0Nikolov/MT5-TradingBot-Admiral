class AGGREGATOR {
    public:

    AGGREGATOR() {}

    bool should_open( int type ) {
        bool flag = false;

        // Recalculate Trend
        trend_1m.get_direction( PERIOD_M1 );
        trend_1m.current_rsi = rsi_.get_rsi( PERIOD_M1, 14, PRICE_CLOSE );

        if (
            !hour_.is_big() &&
            !trend_1m.is_volatile
        ) {
            if ( type == -1 ) { // Sell
                if (
                    (
                        trend_1m.direction < 0 &&
                        trend_1m.current_rsi > 25
                    ) &&              
                    minute_.is_spike( "sell" )
                ) { 
                    if ( hour_.is_in_direction( "sell" ) ) {
                        flag = true;
                    }
                }
            } else if ( type == 1 ) { // Buy
                if (
                    (
                        trend_1m.direction > 0 &&
                        trend_1m.current_rsi < 75
                    ) &&
                    minute_.is_spike( "buy" )
                ) { 
                    if ( hour_.is_in_direction( "buy" ) ) {
                        flag = true;
                    }
                }
            }
        }

        return flag;
   }
};