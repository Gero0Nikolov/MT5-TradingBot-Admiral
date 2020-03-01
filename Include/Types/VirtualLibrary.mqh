class VIRTUAL_LIBRARY {
    public:
    VIRTUAL_POSITION vp_[];
    string file;

    VIRTUAL_LIBRARY() {
        ArrayFree( this.vp_ );
        file = "VL.txt";
    }

    void print_library_size() {
        Print( "VL Size: "+ ArraySize( this.vp_ ) );
    }

    void print_library() {
        int count_vl = ArraySize( this.vp_ );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            Print( "Position #"+ count_vp +" Success: "+ this.vp_[ count_vp ].success );
        }
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
                    vp_.opening_price = item_[ 1 ];
                    vp_.closing_price = item_[ 2 ];
                    vp_.is_opened = false; // Since it's reading from the VL.txt the position cannot be opened
                    vp_.success = item_[ 3 ] == "true" ? true : false;
                    vp_.data_1m.direction = item_[ 4 ];
                    vp_.data_1m.is_volatile = item_[ 5 ] == "true" ? true : false;
                    vp_.data_1m.strength = item_[ 6 ];
                    vp_.data_1m.previous_strength = item_[ 7 ];
                    vp_.data_5m.direction = item_[ 8 ];
                    vp_.data_5m.is_volatile = item_[ 9 ] == "true" ? true : false;
                    vp_.data_5m.strength = item_[ 10 ];
                    vp_.data_5m.previous_strength = item_[ 11 ];
                    vp_.data_15m.direction = item_[ 12 ];
                    vp_.data_15m.is_volatile = item_[ 13 ] == "true" ? true : false;
                    vp_.data_15m.strength = item_[ 14 ];
                    vp_.data_15m.previous_strength = item_[ 15 ];
                    vp_.data_30m.direction = item_[ 16 ];
                    vp_.data_30m.is_volatile = item_[ 17 ] == "true" ? true : false;
                    vp_.data_30m.strength = item_[ 18 ];
                    vp_.data_30m.previous_strength = item_[ 19 ];
                    vp_.data_1h.direction = item_[ 20 ];
                    vp_.data_1h.is_volatile = item_[ 21 ] == "true" ? true : false;
                    vp_.data_1h.strength = item_[ 22 ];
                    vp_.data_1h.previous_strength = item_[ 23 ];

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
        int file_handler = FileOpen( this.file, FILE_WRITE|FILE_ANSI|FILE_TXT|FILE_COMMON );
        if ( file_handler != INVALID_HANDLE ) {
            int count_vl = ArraySize( this.vp_ );

            for ( int count_item = 0; count_item < count_vl; count_item++ ) {
                string line_ = 
                    this.vp_[ count_item ].type +","+
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
        int count_vl = ArraySize( this.vp_ );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            if (
                this.vp_[ count_vp ].data_1m.is_volatile == vp_.data_1m.is_volatile &&
                this.vp_[ count_vp ].data_1m.previous_strength == vp_.data_1m.previous_strength &&
                this.vp_[ count_vp ].data_1m.strength == vp_.data_1m.strength &&
                this.vp_[ count_vp ].data_1m.direction == vp_.data_1m.direction &&
                this.vp_[ count_vp ].data_1h.is_volatile == vp_.data_1h.is_volatile &&
                this.vp_[ count_vp ].data_1h.previous_strength == vp_.data_1h.previous_strength &&
                this.vp_[ count_vp ].data_1h.strength == vp_.data_1h.strength &&
                this.vp_[ count_vp ].data_1h.direction == vp_.data_1h.direction
            ) {
                key = count_vp;
                break;
            }
        }

        return key;
    }

    void add_to_library_from_vp( VIRTUAL_POSITION &vp_ ) {
        // Find the current Key and calculate the new Size of the VL
        int key = ArraySize( this.vp_ );
        int new_size = ArraySize( this.vp_ ) + 1;

        // Resize the VL
        ArrayResize( this.vp_, new_size );

        // Add the new VP to the VL
        this.vp_[ key ].copy_vp( vp_ );
    }

    void update_library_from_vp( VIRTUAL_POSITION &vp_, int key ) {
        this.vp_[ key ].copy_vp( vp_ );
    }

    int position_exists( string navigator ) {
        int key = -1;

        if ( navigator == "vp" ) { // Search the Virtual Library by a new Virtual Position
            VIRTUAL_POSITION vp_;

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
        return key;
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
        int count_vl = ArraySize( this.vp_ );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            if (
                this.vp_[ count_vp ].data_1m.is_volatile == position_.data_1m.is_volatile &&
                this.vp_[ count_vp ].data_1m.previous_strength == position_.data_1m.previous_strength &&
                this.vp_[ count_vp ].data_1m.strength == position_.data_1m.strength &&
                this.vp_[ count_vp ].data_1m.direction == position_.data_1m.direction &&
                this.vp_[ count_vp ].data_1h.is_volatile == position_.data_1h.is_volatile &&
                this.vp_[ count_vp ].data_1h.previous_strength == position_.data_1h.previous_strength &&
                this.vp_[ count_vp ].data_1h.strength == position_.data_1h.strength &&
                this.vp_[ count_vp ].data_1h.direction == position_.data_1h.direction
            ) {
                key = count_vp;
                break;
            }
        }

        return key;
    }

    void add_to_library_from_position( POSITION &position_ ) {
        // Find the current Key and calculate the new Size of the VL
        int key = ArraySize( this.vp_ );
        int new_size = ArraySize( this.vp_ ) + 1;

        // Resize the VL
        ArrayResize( this.vp_, new_size );

        // Add the new VP to the VL
        this.vp_[ key ].copy_position( position_ );
    }

    void update_library_from_position( POSITION &position_, int key ) {
        this.vp_[ key ].copy_position( position_ );
    }
};