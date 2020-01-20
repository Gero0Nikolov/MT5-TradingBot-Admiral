class ADX {
    public:
    double handler;
    double buffer[];

    ADX() {
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
        int strength = 0; // -1 = Trend is losing Strength; 0 = Week Trend; 1 = Trend is getting strength
        int scales = 0;

        this.handler = iADX( Symbol(), trade_period, bars );
        CopyBuffer( this.handler, 0, 0, bars, this.buffer );
        
        double current_adx = NormalizeDouble( this.buffer[ bars - 1 ], 2 );
        
        if ( current_adx > 25 ) { // Bigger than 25 because under 25 Trend is considered week
            for ( int count_bars = bars - 1; count_bars >= 1; count_bars-- ) {
                this.buffer[ count_bars ] = NormalizeDouble( this.buffer[ count_bars ], 2 );
                this.buffer[ count_bars - 1 ] = NormalizeDouble( this.buffer[ count_bars - 1 ], 2 );

                if ( this.buffer[ count_bars ] > this.buffer[ count_bars - 1 ] ) {
                    scales += 1;
                } else if ( this.buffer[ count_bars ] < this.buffer[ count_bars - 1 ] ) {
                    scales -= 1;
                }
            }
        }

        if ( scales > 0 ) { strength = 1; }
        else if ( scales < 0 ) { strength = -1; }

        return strength;
    }
};