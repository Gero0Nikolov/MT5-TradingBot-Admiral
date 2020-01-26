class POSITION_DATA {
    public:
    int direction;
    bool is_volatile;
    int strength;

    POSITION_DATA() {
        this.reset();
    }

    void reset() {
        this.direction = 0;
        this.is_volatile = false;
        this.strength = 0;
    }

    void copy_trend( TREND &trend_ ) {
        this.direction = trend_.direction;
        this.is_volatile = trend_.is_volatile;
        this.strength = trend_.strength;
    }

    void copy_data_info( POSITION_DATA &data ) {
        this.direction = data.direction;
        this.is_volatile = data.is_volatile;
        this.strength = data.strength;
    }
}