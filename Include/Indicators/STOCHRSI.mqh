class STOCHRSI {
    public:
    double handler;
    double buffer[];
    double max_rsi;
    double min_rsi;
    double current_rsi;

    STOCHRSI() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        this.max_rsi = 0;
        this.min_rsi = 0;
        this.current_rsi = 0;
        ArrayFree( this.buffer );
    }

    int calculate( 
        ENUM_TIMEFRAMES trade_period, 
        int bars, 
        ENUM_APPLIED_PRICE price_type 
    ) {
        int direction = 0; // -1 = SELL; 0 = NEUTRAL; 1 = BUY;
        double stoch_rsi = 0;

        this.handler = iRSI( Symbol(), trade_period, bars, price_type );
        CopyBuffer( this.handler, 0, 0, bars, this.buffer );

        this.max_rsi = NormalizeDouble( this.buffer[ 0 ], 2 );
        this.min_rsi = NormalizeDouble( this.buffer[ 0 ], 2 );
        this.current_rsi = NormalizeDouble( this.buffer[ bars - 1 ], 2 );

        for ( int count_bars = 0; count_bars < bars; count_bars++ ) {
            this.max_rsi = this.buffer[ count_bars ] > this.max_rsi ? this.buffer[ count_bars ] : this.max_rsi;
            this.min_rsi = this.buffer[ count_bars ] < this.min_rsi ? this.buffer[ count_bars ] : this.min_rsi;
        }

        stoch_rsi = NormalizeDouble( ( this.current_rsi - this.min_rsi ) / ( this.max_rsi - this.min_rsi ), 2 );

        if (
            stoch_rsi < 0.50 &&
            stoch_rsi > 0.20
        ) {
            direction = -1;
        } else if (
            stoch_rsi > 0.50 &&
            stoch_rsi < 0.80
        ) {
            direction = 1;
        }

        return direction;
    }
}