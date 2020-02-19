class POSITION_DATA {
    public:
    int direction;
    bool is_volatile;
    int strength;
    int previous_strength;

    POSITION_DATA() {
        this.reset();
    }

    void reset() {
        this.direction = 0;
        this.is_volatile = false;
        this.strength = 0;
        this.previous_strength = 0;
    }

    void copy_trend( TREND &trend_ ) {
        this.direction = trend_.direction;
        this.is_volatile = trend_.is_volatile;
        this.strength = trend_.strength;
        this.previous_strength = trend_.previous_strength;
    }

    void copy_data_info( POSITION_DATA &data ) {
        this.direction = data.direction;
        this.is_volatile = data.is_volatile;
        this.strength = data.strength;
        this.previous_strength = data.previous_strength;
    }

    string serialize() {
        string serial = 
            this.direction +","+
            this.is_volatile +","+
            this.strength +","+
            this.previous_strength
        ;

        return serial;
    }

    void deserialize( string serial ) {
        string item_[];
        bool split_result = StringSplit( serial, StringGetCharacter( ",", 0 ), item_ );

        if ( split_result ) {
            this.direction = item_[ 0 ];
            this.is_volatile = item_[ 1 ] == "true" ? true : false;
            this.strength = item_[ 2 ];
            this.previous_strength = item_[ 3 ];
        }
    }
}