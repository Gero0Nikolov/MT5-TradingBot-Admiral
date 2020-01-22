class CURRENT_TREND {
    public:
    int direction;
    bool is_volatile;
    int strength;

    CURRENT_TREND() {
        this.direction = 0;
        this.is_volatile = false;
        this.strength = 0;
    }

    ~CURRENT_TREND() {
        ZeroMemory( this.direction );
        ZeroMemory( this.is_volatile );
        ZeroMemory( this.strength );
    }
};