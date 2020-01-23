class POSITION {
   public:
   int id;
   string type;
   double opening_price;
   double volume;
   bool is_opened;
   double profit;
   bool select;
   double price_difference;
   double difference_in_percentage;
   bool picked;
   double spread;

   POSITION_DATA data_1m;
   POSITION_DATA data_5m;
   POSITION_DATA data_15m;
   POSITION_DATA data_30m;
   POSITION_DATA data_1h;

   POSITION() {
      this.id = 0;
      this.opening_price = 0;
      this.volume = 0;
      this.is_opened = false;
      this.profit = 0;
      this.select = false;
      this.price_difference = 0;
      this.difference_in_percentage = 0;
      this.picked = false;
      this.spread = 0;
   }

   void reset() {
      this.id += 1;
      this.opening_price = 0;
      this.volume = 0;
      this.is_opened = false;
      this.profit = 0;
      this.select = false;
      this.price_difference = 0;
      this.difference_in_percentage = 0;
      this.picked = false;
      this.spread = 0;
      
      // Reset Position Data
      this.data_1m.reset();
      this.data_15m.reset();
      this.data_30m.reset();
      this.data_1h.reset();
   }

   bool should_open( int type ) {
      bool flag = false;

      // Recalculate Trend
      trend_1m.get_direction( PERIOD_M1 );
      trend_5m.get_direction( PERIOD_M5 );
      trend_15m.get_direction( PERIOD_M15 );
      trend_30m.get_direction( PERIOD_M30 );
      trend_1h.get_direction( PERIOD_H1 );

      if ( type == -1 ) { // Sell
         if (
            (
               trend_1m.direction <= -3 &&
               trend_1m.is_volatile &&
               trend_1m.strength == 1
            ) &&
            (
               trend_5m.direction <= -3 &&
               trend_5m.is_volatile &&
               trend_5m.strength == 1
            ) &&
            (
               trend_15m.direction <= -3 &&
               trend_15m.is_volatile &&
               trend_15m.strength == 1
            ) &&
            (
               trend_30m.direction <= -3 &&
               trend_30m.is_volatile &&
               trend_30m.strength == 1
            ) &&
            (
               trend_1h.direction <= -3 &&
               trend_1h.strength == 1
            )
         ) { 
            flag = true;
         }
      } else if ( type == 1 ) { // Buy
         if (
            (
               trend_1m.direction >= 3 &&
               trend_1m.is_volatile &&
               trend_1m.strength == 1
            ) &&
            (
               trend_5m.direction >= 3 &&
               trend_5m.is_volatile &&
               trend_5m.strength == 1
            ) &&
            (
               trend_15m.direction >= 3 &&
               trend_15m.is_volatile &&
               trend_15m.strength == 1
            ) &&
            (
               trend_30m.direction >= 3 &&
               trend_30m.is_volatile &&
               trend_30m.strength == 1
            ) &&
            (
               trend_1h.direction >= 3 &&
               trend_1h.strength == 1
            )
         ) { 
            flag = true;
         }
      }

      return flag;
   }

   bool should_close() {
      //TODO: Make proper closing
      bool flag = this.data_15m.strength > trend_15m.strength ? true : false;
      return flag;
   }
};