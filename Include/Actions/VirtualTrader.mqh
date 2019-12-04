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
        
        vp_[ key ].type = type;
        vp_[ key ].opening_price = opening_price;
        vp_[ key ].rsi = trend_.rsi;
        vp_[ key ].bulls_power = trend_.bulls_power;
        vp_[ key ].tp_price = this.calculate_tp_price( type, opening_price );
        vp_[ key ].sl_price = this.calculate_sl_price( type, opening_price );
        vp_[ key ].is_opened = true;
        vp_[ key ].lowest_price = vp_[ key ].opening_price;
        vp_[ key ].highest_price = vp_[ key ].opening_price;
    }

    double calculate_tp_price( string type, double opening_price ) {
        double tp_price = 0;

        if ( type == "sell" ) {
            tp_price = opening_price - ( instrument_.tpm / 100 * opening_price );
        } else if ( type == "buy" ) {
            tp_price = opening_price + ( instrument_.tpm / 100 * opening_price );
        }

        return tp_price;
    }

    double calculate_sl_price( string type, double opening_price ) {
        double sl_price = 0;

        if ( type == "sell" ) {
            sl_price = opening_price + ( instrument_.slm / 100 * opening_price );
        } else if ( type == "buy" ) {
            sl_price = opening_price + ( instrument_.slm / 100 * opening_price );
        }

        return sl_price;
    }

    void check_virtual_positions() {
        // Reset Closed Positions Counter
        this.closed_positions = 0;

        // Check Virtual Positions
        if ( ArraySize( vp_ ) > 0 ) {
            int vp_size = ArraySize( vp_ );
            for ( int count_position = 0; count_position < vp_size; count_position++ ) {
                // Update Position Lowest & Highest Prices
                vp_[ count_position ].lowest_price = hour_.actual_price < vp_[ count_position ].lowest_price ? hour_.actual_price : vp_[ count_position ].lowest_price;
                vp_[ count_position ].highest_price = hour_.actual_price > vp_[ count_position ].highest_price ? hour_.actual_price : vp_[ count_position ].highest_price;

                // Set Listeners
                if ( vp_[ count_position ].type == "sell" ) {                    
                    if ( 
                        vp_[ count_position ].opening_price > hour_.actual_price &&
                        vp_[ count_position ].opening_price - hour_.actual_price > instrument_.tp_listener
                    ) { // TP Listener
                        double price_difference = hour_.actual_price - vp_[ count_position ].lowest_price;

                        if ( price_difference > 0 ) {
                            double difference_in_percentage = ( price_difference / ( ( hour_.actual_price + vp_[ count_position ].lowest_price ) / 2 ) ) * 100;
                            if ( difference_in_percentage >= instrument_.tpm ) { this.close_virtual_position( count_position, false ); }
                        }
                    } else if ( 
                        vp_[ count_position ].opening_price < hour_.actual_price &&
                        hour_.actual_price >= vp_[ count_position ].sl_price
                    ) { // SL Listener
                        this.close_virtual_position( count_position, true );
                    }
                } else if ( vp_[ count_position ].type == "buy" ) {
                    if (
                        vp_[ count_position ].opening_price < hour_.actual_price &&
                        hour_.actual_price - vp_[ count_position ].opening_price > instrument_.tp_listener
                    ) { // TP Listener
                        double price_difference = vp_[ count_position ].highest_price - hour_.actual_price;

                        if ( price_difference > 0 ) {
                            double difference_in_percentage = ( price_difference / ( ( vp_[ count_position ].highest_price + hour_.actual_price ) / 2 ) ) * 100;
                            if ( difference_in_percentage >= instrument_.tpm ) { this.close_virtual_position( count_position, false ); }
                        }
                    } else if (
                        vp_[ count_position ].opening_price > hour_.actual_price &&
                        hour_.actual_price <= vp_[ count_position ].sl_price
                    ) { // SL Listener
                        this.close_virtual_position( count_position, true );
                    }
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
        update_trade_library( vp_[ key ].rsi, vp_[ key ].bulls_power, vp_[ key ].type, vp_[ key ].opening_price, is_sl );
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
                vp_cpy[ key ].rsi = vp_[ count_position ].rsi;
                vp_cpy[ key ].bulls_power = vp_[ count_position ].bulls_power;
                vp_cpy[ key ].tp_price = vp_[ count_position ].tp_price;
                vp_cpy[ key ].sl_price = vp_[ count_position ].sl_price;
                vp_cpy[ key ].is_opened = vp_[ count_position ].is_opened;
                vp_cpy[ key ].success = vp_[ count_position ].success;
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
            vp_[ key ].rsi = vp_cpy[ count_position ].rsi;
            vp_[ key ].bulls_power = vp_cpy[ count_position ].bulls_power;
            vp_[ key ].tp_price = vp_cpy[ count_position ].tp_price;
            vp_[ key ].sl_price = vp_cpy[ count_position ].sl_price;
            vp_[ key ].is_opened = vp_cpy[ count_position ].is_opened;
            vp_[ key ].success = vp_cpy[ count_position ].success;
        }

        // Clear the Virtual Positions Copy
        ArrayFree( vp_cpy );
        ZeroMemory( vp_cpy );
    }
};