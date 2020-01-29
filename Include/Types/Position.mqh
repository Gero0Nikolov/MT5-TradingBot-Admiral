class POSITION {
   public:
   int id;
   string type;
   double opening_price;
   double profit_price;
   double volume;
   bool is_opened;
   double profit;
   bool select;
   double price_difference;
   double difference_in_percentage;
   bool picked;
   double spread;
   double tp_price;
   double sl_price;

   POSITION_DATA data_1m;
   POSITION_DATA data_5m;
   POSITION_DATA data_15m;
   POSITION_DATA data_30m;
   POSITION_DATA data_1h;

   POSITION() {
      this.id = 0;
      this.opening_price = 0;
      this.profit_price = 0;
      this.volume = 0;
      this.is_opened = false;
      this.profit = 0;
      this.select = false;
      this.price_difference = 0;
      this.difference_in_percentage = 0;
      this.picked = false;
      this.spread = 0;
      this.tp_price = 0;
      this.sl_price = 0;
      this.picked = false;
   }

   void reset() {
      this.id += 1;
      this.opening_price = 0;
      this.profit_price = 0;
      this.volume = 0;
      this.is_opened = false;
      this.profit = 0;
      this.select = false;
      this.price_difference = 0;
      this.difference_in_percentage = 0;
      this.picked = false;
      this.spread = 0;
      this.tp_price = 0;
      this.sl_price = 0;
      this.picked = false;
      
      // Reset Position Data
      this.data_1m.reset();
      this.data_15m.reset();
      this.data_30m.reset();
      this.data_1h.reset();
   }

   bool should_open( int type ) {
      bool flag = false;

      if ( aggregator_.should_open( type ) ) {
         flag = true;
      }

      return flag;
   }

   bool should_close() {
      bool flag = false;

      // if ( this.profit > 0 ) { // Take Profit Listener
      //    if ( this.type == "sell" ) {
      //       if ( hour_.actual_price <= this.tp_price ) { flag = true; }
      //    } else if ( this.type == "buy" ) {
      //       if ( hour_.actual_price >= this.tp_price ) { flag = true; }
      //    }
      // } else if ( this.profit < 0 ) { // Stop Loss Listener
      //    if ( this.type == "sell" ) {
      //       if ( hour_.actual_price >= this.sl_price ) { flag = true; }
      //    } else if ( this.type == "buy" ) {
      //       if ( hour_.actual_price <= this.sl_price ) { flag = true; }
      //    }
      // }

      flag = aggregator_.should_close( this.type == "sell" ? -1 : 1 );

      return flag;
   }

   void calculate_tp() {
      double percentage_difference = this.profit_price * instrument_.tpm;

      if ( this.type == "sell" ) {
         this.tp_price = this.profit_price - percentage_difference;
      } else if ( this.type == "buy" ) {
         this.tp_price = this.profit_price + percentage_difference;
      }

      this.tp_price = NormalizeDouble( this.tp_price, 4 );
   }

   void calculate_sl() {
      double percentage_difference = this.opening_price * instrument_.tpm;

      if ( this.type == "sell" ) {
         this.sl_price = this.opening_price + percentage_difference;
      } else if ( this.type == "buy" ) {
         this.sl_price = this.opening_price - percentage_difference;
      }

      this.sl_price = NormalizeDouble( this.sl_price, 4 );
   }
};