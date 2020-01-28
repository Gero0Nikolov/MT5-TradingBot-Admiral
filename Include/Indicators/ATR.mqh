class ATR {
    public:
    double handler;
    double buffer[];

    ATR() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        ArrayFree( this.buffer );
    }

    bool calculate(
        ENUM_TIMEFRAMES trade_period, 
        int bars
    ) {
        bool volatility = false; // FALSE = Low Volatility; TRUE = High Volatility
        int scales = 0;

        this.handler = iATR( Symbol(), trade_period, bars );
        bars = 3;
        CopyBuffer( this.handler, 0, 0, bars, this.buffer );

        for ( int count_bars = bars - 1; count_bars >= 1; count_bars-- ) {
            this.buffer[ count_bars ] = NormalizeDouble( this.buffer[ count_bars ], 2 );
            this.buffer[ count_bars - 1 ] = NormalizeDouble( this.buffer[ count_bars - 1 ], 2 );

            if ( this.buffer[ count_bars ] > this.buffer[ count_bars - 1 ] ) {
                scales += 1;
            } else if ( this.buffer[ count_bars ] < this.buffer[ count_bars - 1 ] ) {
                scales -= 1;
            }
        }

        if ( scales > 0 ) { volatility = true; }
        else if ( scales < 0 ) { volatility = false; }

        // Reset Indicator
        this.reset();

        return volatility;
    }
};