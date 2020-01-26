class VIRTUAL_POSITION {
    public:    
    int type;
    double opening_price;
    double profit_price;
    double tp_price; // Calculated upon opening based on the Opening Price and the Instrument Setup TPM %
    double sl_price; // Calculated upon opening based on the Opening Price and the Instrument Setup SLM %
    bool is_opened; // Status of the VP; If it's FALSE the position was closed, if it's TRUE then the VP is still on the run
    bool success; // If the success flag is TRUE then the position was closed by the TP, else if it's FALSE then the position was closed by SL
    bool is_profit;

    POSITION_DATA data_1m;
    POSITION_DATA data_5m;
    POSITION_DATA data_15m;
    POSITION_DATA data_30m;
    POSITION_DATA data_1h;

    VIRTUAL_POSITION() {
        this.type = 0;
        this.opening_price = 0;
        this.profit_price = 0;
        this.tp_price = 0;
        this.sl_price = 0;
        this.is_opened = false;
        this.success = false;
        this.is_profit = false;
    }

    void update_profit() {
        if ( this.type == -1 ) { // Sell
            this.is_profit = hour_.actual_price < this.profit_price ? true : false;
        } else if ( this.type == 1 ) { // Buy
            this.is_profit = hour_.actual_price > this.profit_price ? true : false;
        }
    }

    bool should_close() {
        bool flag = false;

        if ( this.is_profit ) { // Take Profit Listener
            if ( this.type == -1 ) {
                if ( hour_.actual_price <= this.tp_price ) { flag = true; }
            } else if ( this.type == 1 ) {
                if ( hour_.actual_price >= this.tp_price ) { flag = true; }
            }
        } else { // Stop Loss Listener
            if ( this.type == -1 ) {
                if ( hour_.actual_price >= this.sl_price ) { flag = true; }
            } else if ( this.type == 1 ) {
                if ( hour_.actual_price <= this.sl_price ) { flag = true; }
            }
        }

        return flag;
    }
}