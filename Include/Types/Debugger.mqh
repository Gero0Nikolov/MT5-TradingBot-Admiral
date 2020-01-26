class DEBUGGER {
    public:
    bool debug_trend;
    bool debug_virtual_trader;
    bool debug_virtual_library;
    bool debug_virtual_position;
    bool debug_position;

    DEBUGGER() {
        this.debug_trend = false;
        this.debug_virtual_trader = false;
        this.debug_virtual_library = false;
        this.debug_virtual_position = false;
        this.debug_position = true;
    }
}