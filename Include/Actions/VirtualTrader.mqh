class VIRTUAL_TRADER {
    public:
    int closed_positions;

    VIRTUAL_TRADER() {
        this.closed_positions = 0;
    }

    void open_virtual_position( string type, double opening_price ) {
        int key = ArraySize( vp_ );
        int new_size = ArraySize( vp_ ) + 1;

        ArrayResize( vp_, new_size );
        
        vp_[ key ].type = type == "sell" ? -1 : 1;
        vp_[ key ].opening_price = type == "sell" ? opening_price : opening_price + instrument_.spread;
        vp_[ key ].profit_price = type == "sell" ? opening_price - instrument_.spread : opening_price + instrument_.spread;
        vp_[ key ].tp_price = this.calculate_tp_price( type, vp_[ key ].profit_price );
        vp_[ key ].sl_price = this.calculate_sl_price( type, vp_[ key ].opening_price );
        vp_[ key ].is_opened = true;
        vp_[ key ].is_profit = false;

        // Copy Trend Info
        vp_[ key ].data_1m.copy_trend( trend_1m );
        vp_[ key ].data_5m.copy_trend( trend_5m );
        vp_[ key ].data_15m.copy_trend( trend_15m );
        vp_[ key ].data_30m.copy_trend( trend_30m );
        vp_[ key ].data_1h.copy_trend( trend_1h );
    }

    double calculate_tp_price( string type, double profit_price ) {
        double tp_price;

        if ( type == "sell" ) {
            tp_price = profit_price - instrument_.tpm;
        } else if ( type == "buy" ) {
            tp_price = profit_price + instrument_.tpm;
        }

        tp_price = NormalizeDouble( tp_price, 4 );

        return tp_price;
    }

    double calculate_sl_price( string type, double opening_price ) {
        double sl_price = 0;
        
        if ( type == "sell" ) {
            sl_price = opening_price + (instrument_.spread + instrument_.slm);
        } else if ( type == "buy" ) {
            sl_price = opening_price - (instrument_.spread + instrument_.slm);
        }

        sl_price = NormalizeDouble( sl_price, 4 );

        return sl_price;
    }

    void check_virtual_positions() {
        // Reset Closed Positions Counter
        this.closed_positions = 0;

        // Check Virtual Positions
        if ( ArraySize( vp_ ) > 0 ) {
            int vp_size = ArraySize( vp_ );

            for ( int count_position = 0; count_position < vp_size; count_position++ ) {  
                vp_[ count_position ].update_profit();

                if ( vp_[ count_position ].should_close() ) {
                    this.close_virtual_position( count_position, vp_[ count_position ].is_profit ? false : true );
                }           
            }

            // Check if there are new closed positions, revise the Virtual Positions to keep the memory clean
            if ( this.closed_positions > 0 ) {
                this.revise_virtual_positions();
            }
        }
    }

    void close_virtual_position( int key, bool is_sl ) {
        vp_[ key ].is_opened = false;
        vp_[ key ].success = is_sl ? false : true;

        // Update the closed positions counter
        this.closed_positions += 1;

        // Add the position to the Trade Library
        if ( vp_[ key ].success ) {
            vl_.add_new_vp( vp_[ key ] );
        }
    }

    void revise_virtual_positions() {
        VIRTUAL_POSITION vp_cpy[];
        int vp_size = ArraySize( vp_ );

        // Collect Opened Virtual Positions
        for ( int count_position = 0; count_position < vp_size; count_position++ ) {
            if ( vp_[ count_position ].is_opened ) {
                int key = ArraySize( vp_cpy );
                int new_size = ArraySize( vp_cpy ) + 1;

                ArrayResize( vp_cpy, new_size );

                vp_cpy[ key ].type = vp_[ count_position].type;
                vp_cpy[ key ].opening_price = vp_[ count_position ].opening_price;
                vp_cpy[ key ].profit_price = vp_[ count_position ].profit_price;
                vp_cpy[ key ].tp_price = vp_[ count_position ].tp_price;
                vp_cpy[ key ].sl_price = vp_[ count_position ].sl_price;
                vp_cpy[ key ].is_opened = vp_[ count_position ].is_opened;
                vp_cpy[ key ].success = vp_[ count_position ].success;

                // Copy Data Info
                vp_cpy[ key ].data_1m.copy_data_info( vp_[ count_position ].data_1m );
                vp_cpy[ key ].data_5m.copy_data_info( vp_[ count_position ].data_5m );
                vp_cpy[ key ].data_15m.copy_data_info( vp_[ count_position ].data_15m );
                vp_cpy[ key ].data_30m.copy_data_info( vp_[ count_position ].data_30m );
                vp_cpy[ key ].data_1h.copy_data_info( vp_[ count_position ].data_1h );
            }
        }

        // Clear the old Virtual Positions
        ArrayFree( vp_ );
        ZeroMemory( vp_ );

        // Put the Virtual Positions Copy in the actual Virtual Positions
        int vp_cpy_size = ArraySize( vp_cpy );
        for ( int count_position = 0; count_position < vp_cpy_size; count_position++ ) {
            int key = ArraySize( vp_ );
            int new_size = ArraySize( vp_ ) + 1;

            ArrayResize( vp_, new_size );

            vp_[ key ].type = vp_cpy[ count_position].type;
            vp_[ key ].opening_price = vp_cpy[ count_position ].opening_price;
            vp_[ key ].profit_price = vp_cpy[ count_position ].profit_price;
            vp_[ key ].tp_price = vp_cpy[ count_position ].tp_price;
            vp_[ key ].sl_price = vp_cpy[ count_position ].sl_price;
            vp_[ key ].is_opened = vp_cpy[ count_position ].is_opened;
            vp_[ key ].success = vp_cpy[ count_position ].success;

            // Copy Data Info    
            vp_[ key ].data_1m.copy_data_info( vp_cpy[ count_position ].data_1m );
            vp_[ key ].data_5m.copy_data_info( vp_cpy[ count_position ].data_5m );
            vp_[ key ].data_15m.copy_data_info( vp_cpy[ count_position ].data_15m );
            vp_[ key ].data_30m.copy_data_info( vp_cpy[ count_position ].data_30m );
            vp_[ key ].data_1h.copy_data_info( vp_cpy[ count_position ].data_1h );
        }

        // Clear the Virtual Positions Copy
        ArrayFree( vp_cpy );
        ZeroMemory( vp_cpy );
    }
};