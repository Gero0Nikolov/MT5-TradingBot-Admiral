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
}