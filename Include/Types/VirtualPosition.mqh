class VIRTUAL_POSITION {
    public:    
    string type;
    double opening_price;
    double rsi;
    double bulls_power;
    double tp_price; // Calculated upon opening based on the Opening Price and the Instrument Setup TPM %
    double sl_price; // Calculated upon opening based on the Opening Price and the Instrument Setup SLM %
    bool is_opened; // Status of the VP; If it's FALSE the position was closed, if it's TRUE then the VP is still on the run
    bool success; // If the success flag is TRUE then the position was closed by the TP, else if it's FALSE then the position was closed by SL
    double lowest_price;
    double highest_price;
    double spread;

    VIRTUAL_POSITION() {
        this.type = "";
        this.opening_price = 0;
        this.rsi = 0;
        this.bulls_power = 0;
        this.tp_price = 0;
        this.sl_price = 0;
        this.is_opened = false;
        this.success = false;
        this.lowest_price = 0;
        this.highest_price = 0;
        this.spread = 0;
    }    
}