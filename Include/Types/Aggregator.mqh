class AGGREGATOR {
    public:

    AGGREGATOR() {}

    bool should_open( int type ) {
        bool flag = false;

        // Recalculate Trend
        trend_1m.get_direction( PERIOD_M1 );
        trend_1h.get_direction( PERIOD_H1 );

        if (
            !trend_1m.is_volatile &&
            trend_1m.previous_strength != 1 &&
            trend_1m.strength > -1
        ) {
            if ( type == -1 ) { // Sell
                if (
                    trend_1m.direction < 0
                ) { 
                    if ( hour_.is_in_direction( "sell" ) ) {
                        flag = true;
                    }
                }
            } else if ( type == 1 ) { // Buy
                if ( trend_1m.direction > 0 ) { 
                    if ( hour_.is_in_direction( "buy" ) ) {
                        flag = true;
                    }
                }
            }
        }

        return flag;
   }

    bool should_close( int type, double opening_price, double tp_price, double sl_price ) {
        bool flag = false;

        // Cache Origianl Type
        int original_type = type;

        // Convert Position Type to the oposite direction;
        type = type == -1 ? 1 : -1;

        // Recalculate Trend
        trend_1m.get_direction( PERIOD_M1 );

        if (            
            !trend_1m.is_volatile &&
            trend_1m.previous_strength != 1 &&
            trend_1m.strength > -1
        ) {
            if ( type == -1 ) { // Sell
                if ( trend_1m.direction < 0 ) { 
                    flag = true;
                }
            } else if ( type == 1 ) { // Buy
                if ( trend_1m.direction > 0 ) { 
                    flag = true;
                }
            }
        }

        return flag;
    }
};