class WPR {
    public:
    double handler;
    double buffer[];

    WPR() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        ArrayFree( this.buffer );
    }

    int calculate(
        ENUM_TIMEFRAMES trade_period, 
        int bars
    ) {
        int direction = 0; // -1 = SELL; 0 = Neutral; 1 = BUY
        int scales = 0;

        this.handler = iWPR( Symbol(), trade_period, bars );
        bars = 3;
        CopyBuffer( this.handler, 0, 0, bars, this.buffer );

        double current_wpr = NormalizeDouble( this.buffer[ bars - 1 ], 2 );

        for ( int count_bars = bars - 1; count_bars >= 1; count_bars-- ) {
            this.buffer[ count_bars ] = NormalizeDouble( this.buffer[ count_bars ], 2 );
            this.buffer[ count_bars - 1 ] = NormalizeDouble( this.buffer[ count_bars - 1 ], 2 );

            if ( this.buffer[ count_bars ] > this.buffer[ count_bars - 1 ] ) {
                scales += 1;
            } else if ( this.buffer[ count_bars ] < this.buffer[ count_bars - 1 ] ) {
                scales -= 1;
            }
        }

        if ( 
            scales > 0 &&
            current_wpr < -20
        ) { 
            direction = 1; 
        } else if ( 
            scales < 0 &&
            current_wpr > -80
        ) { 
            direction = -1; 
        }

        // Reset Indicator
        this.reset();

        return direction;
    }
};