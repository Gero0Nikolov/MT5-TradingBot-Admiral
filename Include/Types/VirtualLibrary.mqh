class VIRTUAL_LIBRARY {
    public:
    VIRTUAL_POSITION vp[];

    VIRTUAL_LIBRARY() {
        ArrayFree( this.vp );
    }

    void print_library_size() {
        Print( "VL Size: "+ ArraySize( this.vp ) );
    }

    void print_library() {
        int count_vl = ArraySize( this.vp );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            Print( "Position #"+ count_vp +" Success: "+ this.vp[ count_vp ].success );
            Print( "Position #"+ count_vp +" Direction: "+ this.vp[ count_vp ].data_5m.direction );
        }
    }

    bool was_success( int type ) {
        bool flag = false;
        int count_vl = ArraySize( this.vp );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            if ( type == this.vp[ count_vp ].type ) {
                if (
                    this.vp[ count_vp ].data_1m.direction == trend_1m.direction &&
                    this.vp[ count_vp ].data_5m.direction == trend_5m.direction &&
                    this.vp[ count_vp ].data_15m.direction == trend_15m.direction      
                ) {
                    flag = true;
                }
            }
        }

        return flag;
    }

    void add_new_vp( VIRTUAL_POSITION &vp_ ) {
        int key = ArraySize( this.vp );
        int new_size = ArraySize( this.vp ) + 1;

        ArrayResize( this.vp, new_size );

        this.vp[ key ].type = vp_.type;
        this.vp[ key ].opening_price = vp_.opening_price;
        this.vp[ key ].profit_price = vp_.profit_price;
        this.vp[ key ].tp_price = vp_.tp_price;
        this.vp[ key ].sl_price = vp_.sl_price;
        this.vp[ key ].is_opened = vp_.is_opened; // Status of the VP; If it's FALSE the position was closed, if it's TRUE then the VP is still on the run
        this.vp[ key ].success = vp_.success; // If the success flag is TRUE then the position was closed by the TP, else if it's FALSE then the position was closed by SL
        this.vp[ key ].is_profit = vp_.is_profit;

        // Copy Data Info
        this.vp[ key ].data_1m.copy_data_info( vp_.data_1m );
        this.vp[ key ].data_5m.copy_data_info( vp_.data_5m );
        this.vp[ key ].data_15m.copy_data_info( vp_.data_15m );
        this.vp[ key ].data_30m.copy_data_info( vp_.data_30m );
        this.vp[ key ].data_1h.copy_data_info( vp_.data_1h );
    }
};