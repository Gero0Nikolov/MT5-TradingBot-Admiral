class AGGREGATOR {
    public:

    AGGREGATOR() {}

    bool should_open( int type ) {
        bool flag = false;

        // Recalculate Trend
        trend_1m.get_direction( PERIOD_M1 );

        if (
            !hour_.is_big() &&
            !trend_1m.is_volatile &&
            trend_1m.previous_strength != 1 &&
            trend_1m.strength > -1
        ) {
            if ( type == -1 ) { // Sell
                if (
                    (
                        trend_1m.direction < 0
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
                        trend_1m.direction > 0
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