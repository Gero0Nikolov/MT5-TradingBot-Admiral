class CCI {
    public:
    double handler;
    double buffer[];

    CCI() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        ArrayFree( this.buffer );
    }

    int calculate(
        ENUM_TIMEFRAMES trade_period, 
        int bars, 
        ENUM_APPLIED_PRICE price_type
    ) {
        int direction = 0; // -1 = SELL; 0 = NEUTRAL; 1 = BUY;
        int scales = 0;

        this.handler = iCCI( Symbol(), trade_period, bars, price_type );
        CopyBuffer( this.handler, 0, 0, bars, this.buffer );

        double current_cci = NormalizeDouble( this.buffer[ bars - 1 ], 2 );

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
            current_cci > 100
        ) { 
            direction = 1; 
        } else if ( 
            scales < 0 &&
            current_cci < -100
        ) { 
            direction = -1; 
        }

        return direction;
    }
};