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
   double margin_level;

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
      this.margin_level = 0;
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
      this.margin_level = 0;
      
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
      return aggregator_.should_close( this.type == "sell" ? -1 : 1 ) || this.margin_level <= account_.margin_call;
   }

   void calculate_margin_level() {
      this.margin_level = AccountInfoDouble( ACCOUNT_MARGIN_LEVEL );
   }
};