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

    int calculate(
        ENUM_TIMEFRAMES trade_period, 
        int bars
    ) {
        int volatility = 0; // 0 = Low Volatility; 1 = High Volatility
        int scales = 0;

        this.handler = iATR( Symbol(), trade_period, bars );
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

        if ( scales > 0 ) { volatility = 1; }
        else if ( scales < 0 ) { volatility = 0; }

        return volatility;
    }
};