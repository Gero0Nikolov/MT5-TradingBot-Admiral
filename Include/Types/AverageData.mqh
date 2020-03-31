class AVERAGE_DATA {
    public:
    double av_bar_size;
    
    AVERAGE_DATA(
        ENUM_TIMEFRAMES timeframe,
        int bars
    ) {
        this.av_bar_size = 0;
        double bar_size = 0;

        for ( int shift = 0; shift < bars; shift++ ) {
            // Get Bar Info
            double open = iOpen( Symbol(), timeframe, shift );
            double high = iHigh( Symbol(), timeframe, shift );
            double low = iLow( Symbol(), timeframe, shift );
            double close = iClose( Symbol(), timeframe, shift );

            // Calculate Bar Size
            bar_size += NormalizeDouble( high - low, 2 );
        }

        // Calculate Avarage Bar Size
        this.av_bar_size = NormalizeDouble( bar_size / bars, 0 );
    }
}