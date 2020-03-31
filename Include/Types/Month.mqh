class MONTH {
    public:
    double opening_price;
    double lowest_price;
    double highest_price;
    double actual_price;
    int key;
    int previous_type; // -2 = Crisis; -1 = Red; 0 = None; 1 = Green; 2 = Stable;
    int type; // -2 = Crisis; -1 = Red; 0 = None; 1 = Green; 2 = Stable;
    bool is_set;

    MONTH() {
        this.reset();
    }

    void reset() {
        this.opening_price = 0;
        this.lowest_price = 0;
        this.highest_price = 0;
        this.actual_price = 0;
        this.key = 0;
        this.is_set = false;
        this.previous_type = 0;
        this.type = 0;

        // Recalculate Type of the Month
        this.recalculate_type();
    }

    void recalculate_type() {
        this.previous_type = this.type;

        if ( this.opening_price > this.actual_price ) { // Month is Red
            this.type = -1;

            if ( this.actual_price - this.lowest_price < this.opening_price - this.actual_price ) { // Month is Red Crisis, indicated High Volatility - Considerable SELL Position
                this.type = -2;
            }
        } else if ( this.opening_price < this.actual_price ) { // Month is Green
            this.type = 1;

            if ( this.highest_price - this.actual_price < this.actual_price - this.opening_price ) { // Month is Green Stable, normal trading can continue
                this.type = 2;
            }
        }
    }
}