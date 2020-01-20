class STOCH {
    public:
    double handler;
    double main_buffer[];
    double signal_buffer[];

    STOCH() {
        this.reset();
    }

    void reset() {
        this.handler = 0;
        ArrayFree( this.main_buffer );
        ArrayFree( this.signal_buffer );
    }

    int calculate( 
        ENUM_TIMEFRAMES trade_period, 
        int k_period,
        int d_period
    ) {        
        int direction = 0; // -1 = SELL; 0 = NEUTRAL; 1 = BUY;

        this.handler = iStochastic( Symbol(), trade_period, k_period, d_period, 3, MODE_SMA, STO_CLOSECLOSE );
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