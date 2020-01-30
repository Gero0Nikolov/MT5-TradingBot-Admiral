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
        
        // Register the new Virtual Position
        vp_[ key ].type = type == "sell" ? -1 : 1;
        vp_[ key ].opening_price = type == "sell" ? opening_price : opening_price + instrument_.spread;
        vp_[ key ].is_opened = true;

        // Copy Trend Info
        vp_[ key ].data_1m.copy_trend( trend_1m );
        vp_[ key ].data_5m.copy_trend( trend_5m );
        vp_[ key ].data_15m.copy_trend( trend_15m );
        vp_[ key ].data_30m.copy_trend( trend_30m );
        vp_[ key ].data_1h.copy_trend( trend_1h );
    }

    void check_virtual_positions() {
        // Reset Closed Positions Counter
        this.closed_positions = 0;

        // Check Virtual Positions
        if ( ArraySize( vp_ ) > 0 ) {
            int vp_size = ArraySize( vp_ );

            for ( int count_position = 0; count_position < vp_size; count_position++ ) {  
                if ( vp_[ count_position ].should_close() ) {
                    // Update VP Closing Price
                    vp_[ count_position ].closing_price = hour_.actual_price;

                    // Close the VP
                    this.close_virtual_position( count_position, !vp_[ count_position ].was_profit() );
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

        // Add or Update the position to the Trade Library
        if ( vp_[ key ].success ) {
            vl_.update_from_vp( vp_[ key ] );
        }
    }

    void revise_virtual_positions() {
        VIRTUAL_POSITION vp_cpy[];
        int vp_size = ArraySize( vp_ );

        // Collect Opened Virtual Positions
        for ( int count_position = 0; count_position < vp_size; count_position++ ) {
            if ( vp_[ count_position ].is_opened ) {
                // Find the current Key in the VP Copies
                int key = ArraySize( vp_cpy );
                int new_size = ArraySize( vp_cpy ) + 1;

                // Resize the VP Copies container
                ArrayResize( vp_cpy, new_size );

                // Copy the Still Opened VP
                vp_cpy[ key ].copy_vp( vp_[ count_position ] );
            }
        }

        // Clear the old Virtual Positions
        ArrayFree( vp_ );
        ZeroMemory( vp_ );

        // Put the Virtual Positions Copy in the actual Virtual Positions
        int vp_cpy_size = ArraySize( vp_cpy );
        for ( int count_position = 0; count_position < vp_cpy_size; count_position++ ) {
            // Find the current Key in the VP Container
            int key = ArraySize( vp_ );
            int new_size = ArraySize( vp_ ) + 1;

            // Resize the VP Container
            ArrayResize( vp_, new_size );

            // Copy the Opened VP from the VP Copies
            vp_[ key ].copy_vp( vp_cpy[ count_position ] );
        }

        // Clear the Virtual Positions Copy
        ArrayFree( vp_cpy );
        ZeroMemory( vp_cpy );
    }
};