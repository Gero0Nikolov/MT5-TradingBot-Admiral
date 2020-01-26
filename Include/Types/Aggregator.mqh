class AGGREGATOR {
    public:

    AGGREGATOR() {}

    bool should_open( int type ) {
        bool flag = false;

        // Recalculate Trend
        trend_1m.get_direction( PERIOD_M1 );
        trend_5m.get_direction( PERIOD_M5 );
        trend_15m.get_direction( PERIOD_M15 );
        trend_30m.get_direction( PERIOD_M30 );
        trend_1h.get_direction( PERIOD_H1 );

        if (
            !hour_.is_big() &&
            trend_1h.is_volatile
        ) {
            if ( type == -1 ) { // Sell
                if (
                    (
                        trend_1m.direction < 0 &&
                        trend_1m.strength == 1
                    ) &&
                    (
                        trend_5m.direction < 0 &&
                        trend_5m.strength == 1
                    ) &&
                    minute_.is_spike()
                ) { 
                    if ( hour_.is_in_direction( "sell" ) ) {
                        flag = true;
                    }
                }
            } else if ( type == 1 ) { // Buy
                if (
                    (
                        trend_1m.direction > 0 &&
                        trend_1m.strength == 1
                    ) &&
                    (
                        trend_5m.direction > 0 &&
                        trend_5m.strength == 1
                    ) &&
                    minute_.is_spike()
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