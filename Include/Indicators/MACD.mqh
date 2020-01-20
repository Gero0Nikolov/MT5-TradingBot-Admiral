class MACD {
    public:
    double handler;
    double main_buffer[];
    double signal_buffer[];

    MACD() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        ArrayFree( this.main_buffer );
        ArrayFree( this.signal_buffer );
    }

    int calculate( 
        ENUM_TIMEFRAMES trade_period, 
        int fast_period,
        int slow_period,
        ENUM_APPLIED_PRICE price_type
    ) {        
        int direction = 0; // -1 = SELL; 0 = NEUTRAL; 1 = BUY;

        this.handler = iMACD( Symbol(), trade_period, fast_period, slow_period, 9, price_type );
        CopyBuffer( this.handler, MAIN_LINE, 0, 1, this.main_buffer );
        CopyBuffer( this.handler, SIGNAL_LINE, 0, 1, this.signal_buffer );
        
        this.main_buffer[ 0 ] = NormalizeDouble( this.main_buffer[ 0 ], 2 );
        this.signal_buffer[ 0 ] = NormalizeDouble( this.signal_buffer[ 0 ], 2 );

        if ( this.main_buffer[ 0 ] > this.signal_buffer[ 0 ] ) {
            direction = 1;
        } else if ( this.main_buffer[ 0 ] < this.signal_buffer[ 0 ] ) {
            direction = -1;
        }

        return direction;
    }
}