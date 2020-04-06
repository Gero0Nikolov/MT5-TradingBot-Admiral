class VIRTUAL_LIBRARY {
    public:
    VIRTUAL_POSITION vp_[];
    VIRTUAL_POSITION vp_green[];
    VIRTUAL_POSITION vp_red[];
    string file;

    VIRTUAL_LIBRARY() {
        ArrayFree( this.vp_ );
        this.file = "VL.txt";
    }

    void read() {
        int file_handler = FileOpen( this.file, FILE_ANSI|FILE_TXT|FILE_READ|FILE_COMMON );
        if ( file_handler != INVALID_HANDLE ) {        
            string line_;
            int line_counter = 0;
            VIRTUAL_POSITION vp_;

            while ( !FileIsEnding( file_handler ) ) {
                line_ = FileReadString( file_handler, -1 );
                line_counter += 1;
                
                string item_[];
                bool split_result = StringSplit( line_, StringGetCharacter( ",", 0 ), item_ );

                if ( split_result ) {
                    // Construct the VP
                    vp_.type = item_[ 0 ];
                    vp_.curve = item_[ 1 ];
                    vp_.opening_price = item_[ 2 ];
                    vp_.closing_price = item_[ 3 ];
                    vp_.is_opened = false; // Since it's reading from the VL.txt the position cannot be opened
                    vp_.success = item_[ 4 ] == "true" ? true : false;
                    vp_.data_1m.direction = item_[ 5 ];
                    vp_.data_1m.is_volatile = item_[ 6 ] == "true" ? true : false;
                    vp_.data_1m.strength = item_[ 7 ];
                    vp_.data_1m.previous_strength = item_[ 8 ];
                    vp_.data_5m.direction = item_[ 9 ];
                    vp_.data_5m.is_volatile = item_[ 10 ] == "true" ? true : false;
                    vp_.data_5m.strength = item_[ 11 ];
                    vp_.data_5m.previous_strength = item_[ 12 ];
                    vp_.data_15m.direction = item_[ 13 ];
                    vp_.data_15m.is_volatile = item_[ 14 ] == "true" ? true : false;
                    vp_.data_15m.strength = item_[ 15 ];
                    vp_.data_15m.previous_strength = item_[ 16 ];
                    vp_.data_30m.direction = item_[ 17 ];
                    vp_.data_30m.is_volatile = item_[ 18 ] == "true" ? true : false;
                    vp_.data_30m.strength = item_[ 19 ];
                    vp_.data_30m.previous_strength = item_[ 20 ];
                    vp_.data_1h.direction = item_[ 21 ];
                    vp_.data_1h.is_volatile = item_[ 22] == "true" ? true : false;
                    vp_.data_1h.strength = item_[ 23 ];
                    vp_.data_1h.previous_strength = item_[ 24 ];

                    // Add it to the VL which is stored in the RAM
                    this.add_to_library_from_vp( vp_ );
                } else {
                    Print( "#"+ line_counter +" - Failed to split the Virtual Position data from VL.txt" );
                }
            }                     
        } else {
            Print( "Failed to read from Library.txt" );
        }
        FileClose( file_handler );
    }

    void save() {
        // Merge Green and Red Curves
        this.merge_into_vp();

        // Save VL
        int file_handler = FileOpen( this.file, FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON );
        if ( file_handler != INVALID_HANDLE ) {
            int count_vl = ArraySize( this.vp_ );

            for ( int count_item = 0; count_item < count_vl; count_item++ ) {
                string line_ = 
                    this.vp_[ count_item ].type +","+
                    this.vp_[ count_item ].curve +","+
                    this.vp_[ count_item ].opening_price +","+
                    this.vp_[ count_item ].closing_price +","+
                    this.vp_[ count_item ].success +","+
                    this.vp_[ count_item ].data_1m.direction +","+
                    this.vp_[ count_item ].data_1m.is_volatile +","+
                    this.vp_[ count_item ].data_1m.strength +","+
                    this.vp_[ count_item ].data_1m.previous_strength +","+
                    this.vp_[ count_item ].data_5m.direction +","+
                    this.vp_[ count_item ].data_5m.is_volatile +","+
                    this.vp_[ count_item ].data_5m.strength +","+
                    this.vp_[ count_item ].data_5m.previous_strength +","+
                    this.vp_[ count_item ].data_15m.direction +","+
                    this.vp_[ count_item ].data_15m.is_volatile +","+
                    this.vp_[ count_item ].data_15m.strength +","+
                    this.vp_[ count_item ].data_15m.previous_strength +","+
                    this.vp_[ count_item ].data_30m.direction +","+
                    this.vp_[ count_item ].data_30m.is_volatile +","+
                    this.vp_[ count_item ].data_30m.strength +","+
                    this.vp_[ count_item ].data_30m.previous_strength +","+
                    this.vp_[ count_item ].data_1h.direction +","+
                    this.vp_[ count_item ].data_1h.is_volatile +","+
                    this.vp_[ count_item ].data_1h.strength +","+
                    this.vp_[ count_item ].data_1h.previous_strength
                ;
                FileWrite( file_handler, line_ );    
            }
        } else {
            Print( "Failed to write in Library.txt" );
        }
        FileClose( file_handler );
    }

    void merge_into_vp() {
        ArrayFree( this.vp_ );
        int key = 0;
        int new_size;

        // Copy Green Curve
        int count_green = ArraySize( vp_green );
        for ( int count_green_vp = 0; count_green_vp < count_green; count_green_vp++ ) {
            key = ArraySize( this.vp_ );
            new_size = ArraySize( this.vp_ ) + 1;

            // Resize the VL
            ArrayResize( this.vp_, new_size );

            // Add the new VP to the VL
            this.vp_[ key ].copy_vp( vp_green[ count_green_vp ] );    
        }

        // Copy Red Curve
        int count_red = ArraySize( vp_red );
        for ( int count_red_vp = 0; count_red_vp < count_red; count_red_vp++ ) {
            key = ArraySize( this.vp_ );
            new_size = ArraySize( this.vp_ ) + 1;

            // Resize the VL
            ArrayResize( this.vp_, new_size );

            // Add the new VP to the VL
            this.vp_[ key ].copy_vp( vp_red[ count_red_vp ] );    
        }
    }

    /*
    *   Virtual Library (VL) Actions from Virtual Position (VP) Request
    */
    void update_from_vp( VIRTUAL_POSITION &vp_ ) {
        int key_in_library = this.find_from_vp( vp_ );

        if ( key_in_library == -1 ) { // New VP to the Library
            this.add_to_library_from_vp( vp_ );
        } else { // Update existing VP in the Library
            this.update_library_from_vp( vp_, key_in_library );
        }
    }

    int find_from_vp( VIRTUAL_POSITION &vp_ ) {
        int key = -1;

        if ( vp_.curve < 0 ) { // Red Curve
            int count_vl = ArraySize( this.vp_red );

            for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
                if ( this.vp_red[ count_vp ].is_equal_to_vp( vp_ ) ) {
                    key = count_vp;
                    break;
                }
            }
        } else if ( vp_.curve > 0 ) { // Green Curve
            int count_vl = ArraySize( this.vp_green );

            for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
                if ( this.vp_green[ count_vp ].is_equal_to_vp( vp_ ) ) {
                    key = count_vp;
                    break;
                }
            }
        }

        return key;
    }

    void add_to_library_from_vp( VIRTUAL_POSITION &vp_ ) {
        // Determine the Curve
        if ( vp_.curve < 0 ) { // Red Curve
            // Find the current Key and calculate the new Size of the VL
            int key = ArraySize( this.vp_red );
            int new_size = ArraySize( this.vp_red ) + 1;

            // Resize the VL
            ArrayResize( this.vp_red, new_size );

            // Add the new VP to the VL
            this.vp_red[ key ].copy_vp( vp_ );
        } else if ( vp_.curve > 0 ) { // Green Curve
            // Find the current Key and calculate the new Size of the VL
            int key = ArraySize( this.vp_green );
            int new_size = ArraySize( this.vp_green ) + 1;

            // Resize the VL
            ArrayResize( this.vp_green, new_size );

            // Add the new VP to the VL
            this.vp_green[ key ].copy_vp( vp_ );
        }
    }

    void update_library_from_vp( VIRTUAL_POSITION &vp_, int key ) {
        if ( vp_.curve < 0 ) { // Red Curve
            this.vp_red[ key ].copy_vp( vp_ );
        } else if ( vp_.curve > 0 ) { // Green Curve
            this.vp_green[ key ].copy_vp( vp_ );
        }
    }

    bool position_exists( string navigator, int type ) {
        int key = -1;

        if ( navigator == "vp" ) { // Search the Virtual Library by a new Virtual Position
            VIRTUAL_POSITION vp_;

            // Set VP Type
            vp_.type = type;
            
            // Set VP Curve
            vp_.curve = type;

            // Copy Current Trend Data
            vp_.data_1m.copy_trend( trend_1m );
            vp_.data_5m.copy_trend( trend_5m );
            vp_.data_15m.copy_trend( trend_15m );
            vp_.data_30m.copy_trend( trend_30m );
            vp_.data_1h.copy_trend( trend_1h );

            // Check if the desired New Position is exists in the Virtual Library (VL)
            key = this.find_from_vp( vp_ );
        } else if ( navigator == "np" ) { // Search the Virtual Library by a new Normal Position
            POSITION position_;

            // Set Position Type
            position_.type = type == -1 ? "sell" : "buy";

            // Set Position Curve
            position_.curve = type;

            // Copy Current Trend Data
            position_.data_1m.copy_trend( trend_1m );
            position_.data_5m.copy_trend( trend_5m );
            position_.data_15m.copy_trend( trend_15m );
            position_.data_30m.copy_trend( trend_30m );
            position_.data_1h.copy_trend( trend_1h );

            // Check if the desired New Position is exists in the Virtual Library (VL)
            key = this.find_from_position( position_ );
        }

        // Return the key of the Position
        return key > -1;
    }

    /*
    *   Virtual Library (VL) Actions from Normal Position Request
    */
    void update_from_position( POSITION &position_ ) {
        int key_in_library = this.find_from_position( position_ );

        if ( key_in_library == -1 ) { // New VP to the Library
            this.add_to_library_from_position( position_ );
        } else { // Update existing VP in the Library
            this.update_library_from_position( position_, key_in_library );
        }
    }

    int find_from_position( POSITION &position_ ) {
        int key = -1;
        int type = position_.type == "sell" ? -1 : 1;
        if ( position_.curve < 0 ) { // Red Curve
            int count_vl = ArraySize( this.vp_red );

            for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
                if ( this.vp_red[ count_vp ].is_equal_to_position( position_ ) ) {
                    key = count_vp;
                    break;
                }
            }
        } else if ( position_.curve > 0 ) { // Green Curve
            int count_vl = ArraySize( this.vp_green );

            for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
                if ( this.vp_green[ count_vp ].is_equal_to_position( position_ ) ) {
                    key = count_vp;
                    break;
                }
            }
        }

        return key;
    }

    void add_to_library_from_position( POSITION &position_ ) {
        // Determine the Curve
        if ( position_.curve < 0 ) { // Red Curve
            // Find the current Key and calculate the new Size of the VL
            int key = ArraySize( this.vp_red );
            int new_size = ArraySize( this.vp_red ) + 1;

            // Resize the VL
            ArrayResize( this.vp_red, new_size );

            // Add the new VP to the VL
            this.vp_red[ key ].copy_position( position_ );
        } else if ( position_.curve > 0 ) { // Green Curve
            // Find the current Key and calculate the new Size of the VL
            int key = ArraySize( this.vp_green );
            int new_size = ArraySize( this.vp_green ) + 1;

            // Resize the VL
            ArrayResize( this.vp_green, new_size );

            // Add the new VP to the VL
            this.vp_green[ key ].copy_position( position_ );
        }
    }

    void update_library_from_position( POSITION &position_, int key ) {
        if ( position_.curve < 0 ) { // Red Curve
            this.vp_red[ key ].copy_position( position_ );
        } else if ( position_.curve > 0 ) { // Green Curve
            this.vp_green[ key ].copy_position( position_ );
        }
    }
};