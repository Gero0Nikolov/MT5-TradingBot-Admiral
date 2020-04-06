class VIRTUAL_POSITION {
    public:    
    int type;
    int curve;
    double opening_price;
    double closing_price;
    double tp_price;
    double sl_price;
    bool is_opened; // Status of the VP; If it's FALSE the position was closed, if it's TRUE then the VP is still on the run
    bool success; // If the success flag is TRUE then the position was closed by the TP, else if it's FALSE then the position was closed by SL

    POSITION_DATA data_1m;
    POSITION_DATA data_5m;
    POSITION_DATA data_15m;
    POSITION_DATA data_30m;
    POSITION_DATA data_1h;

    VIRTUAL_POSITION() {
        this.type = 0;
        this.curve = 0;
        this.opening_price = 0;
        this.closing_price = 0;
        this.tp_price = 0;
        this.sl_price = 0;
        this.is_opened = false;
        this.success = false;
    }

    bool should_close() {
        return aggregator_.should_close( this.type, this.opening_price, this.tp_price, this.sl_price );
    }

    bool was_profit() {
        bool flag = false;

        if ( type == -1 ) { // Sell
            flag = this.closing_price < this.opening_price ? true : false;
        } else if ( type == 1 ) { // Buy
            flag = this.closing_price > this.opening_price ? true : false;
        }

        return flag;
    }

    void copy_vp( VIRTUAL_POSITION &vp_ ) {
        this.type = vp_.type;
        this.curve = vp_.curve;
        this.opening_price = vp_.opening_price;
        this.closing_price = vp_.closing_price;
        this.tp_price = vp_.tp_price;
        this.sl_price = vp_.sl_price;
        this.is_opened = vp_.is_opened;
        this.success = vp_.success;

        // Copy Data Info
        this.data_1m.copy_data_info( vp_.data_1m );
        this.data_5m.copy_data_info( vp_.data_5m );
        this.data_15m.copy_data_info( vp_.data_15m );
        this.data_30m.copy_data_info( vp_.data_30m );
        this.data_1h.copy_data_info( vp_.data_1h );
    }

    void copy_position( POSITION &position_ ) {
        this.type = position_.type == "sell" ? -1 : 1;
        this.curve = position_.curve;
        this.opening_price = position_.opening_price;
        this.closing_price = position_.closing_price;
        this.tp_price = position_.tp_price;
        this.sl_price = position_.sl_price;
        this.is_opened = false; // The Position will be destroyed after that so assume it's closed :D
        this.success = position_.success;
        
        // Copy Data Info
        this.data_1m.copy_data_info( position_.data_1m );
        this.data_5m.copy_data_info( position_.data_5m );
        this.data_15m.copy_data_info( position_.data_15m );
        this.data_30m.copy_data_info( position_.data_30m );
        this.data_1h.copy_data_info( position_.data_1h );
    }

    void calculate_tp_sl() {
        if ( type == -1 ) { // Sell
            this.tp_price = this.opening_price - ( this.opening_price * instrument_.tpm );
            this.sl_price = this.opening_price + ( this.opening_price * instrument_.slm );
        } else if ( type == 1 ) { // Buy
            this.tp_price = this.opening_price + ( this.opening_price * instrument_.tpm );
            this.sl_price = this.opening_price - ( this.opening_price * instrument_.tpm );
        }
    }

    bool is_equal_to_vp( VIRTUAL_POSITION &vp_ ) {
        bool flag = false;

        if (
            this.type == vp_.type &&
            this.data_1m.is_volatile == vp_.data_1m.is_volatile &&
            this.data_1m.previous_strength == vp_.data_1m.previous_strength &&
            this.data_1m.strength == vp_.data_1m.strength &&
            this.data_1m.direction == vp_.data_1m.direction &&
            this.data_5m.is_volatile == vp_.data_5m.is_volatile &&
            this.data_5m.previous_strength == vp_.data_5m.previous_strength &&
            this.data_5m.strength == vp_.data_5m.strength &&
            this.data_5m.direction == vp_.data_5m.direction &&
            this.data_15m.is_volatile == vp_.data_15m.is_volatile &&
            this.data_15m.previous_strength == vp_.data_15m.previous_strength &&
            this.data_15m.strength == vp_.data_15m.strength &&
            this.data_15m.direction == vp_.data_15m.direction &&
            this.data_30m.is_volatile == vp_.data_30m.is_volatile &&
            this.data_30m.previous_strength == vp_.data_30m.previous_strength &&
            this.data_30m.strength == vp_.data_30m.strength &&
            this.data_30m.direction == vp_.data_30m.direction &&
            this.data_1h.is_volatile == vp_.data_1h.is_volatile &&
            this.data_1h.previous_strength == vp_.data_1h.previous_strength &&
            this.data_1h.strength == vp_.data_1h.strength &&
            this.data_1h.direction == vp_.data_1h.direction
        ) {
            flag = true;
        }

        return flag;
    }

    bool is_equal_to_position( POSITION &position_ ) {
        bool flag = false;

        if (
            this.type == position_.type &&
            this.data_1m.is_volatile == position_.data_1m.is_volatile &&
            this.data_1m.previous_strength == position_.data_1m.previous_strength &&
            this.data_1m.strength == position_.data_1m.strength &&
            this.data_1m.direction == position_.data_1m.direction &&
            this.data_5m.is_volatile == position_.data_5m.is_volatile &&
            this.data_5m.previous_strength == position_.data_5m.previous_strength &&
            this.data_5m.strength == position_.data_5m.strength &&
            this.data_5m.direction == position_.data_5m.direction &&
            this.data_15m.is_volatile == position_.data_15m.is_volatile &&
            this.data_15m.previous_strength == position_.data_15m.previous_strength &&
            this.data_15m.strength == position_.data_15m.strength &&
            this.data_15m.direction == position_.data_15m.direction &&
            this.data_30m.is_volatile == position_.data_30m.is_volatile &&
            this.data_30m.previous_strength == position_.data_30m.previous_strength &&
            this.data_30m.strength == position_.data_30m.strength &&
            this.data_30m.direction == position_.data_30m.direction &&
            this.data_1h.is_volatile == position_.data_1h.is_volatile &&
            this.data_1h.previous_strength == position_.data_1h.previous_strength &&
            this.data_1h.strength == position_.data_1h.strength &&
            this.data_1h.direction == position_.data_1h.direction
        ) {
            flag = true;
        }

        return flag;
    }
}