class VIRTUAL_POSITION {
    public:    
    int type;
    double opening_price;
    double closing_price;
    bool is_opened; // Status of the VP; If it's FALSE the position was closed, if it's TRUE then the VP is still on the run
    bool success; // If the success flag is TRUE then the position was closed by the TP, else if it's FALSE then the position was closed by SL

    POSITION_DATA data_1m;
    POSITION_DATA data_5m;
    POSITION_DATA data_15m;
    POSITION_DATA data_30m;
    POSITION_DATA data_1h;

    VIRTUAL_POSITION() {
        this.type = 0;
        this.opening_price = 0;
        this.closing_price = 0;
        this.is_opened = false;
        this.success = false;
    }

    bool should_close() {
        return aggregator_.should_close( this.type );
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
        this.opening_price = vp_.opening_price;
        this.closing_price = vp_.closing_price;
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
        this.opening_price = position_.opening_price;
        this.closing_price = position_.closing_price;
        this.is_opened = false; // The Position will be destroyed after that so assume it's closed :D
        this.success = position_.success;
        
        // Copy Data Info
        this.data_1m.copy_data_info( position_.data_1m );
        this.data_5m.copy_data_info( position_.data_5m );
        this.data_15m.copy_data_info( position_.data_15m );
        this.data_30m.copy_data_info( position_.data_30m );
        this.data_1h.copy_data_info( position_.data_1h );
    }
}