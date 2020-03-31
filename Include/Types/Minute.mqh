class MINUTE { 
   public:
   bool is_set;   
   int key;
   double opening_price;
   double sell_price;
   double buy_price;
   double actual_price;
   double lowest_price;
   double highest_price;
   
   MINUTE() {
      this.reset();
   }

   void reset() {
      this.is_set = false;      
      this.key = 0;
      this.opening_price = 0;
      this.sell_price = 0;
      this.buy_price = 0;
      this.actual_price = 0;
      this.lowest_price = 0;
      this.highest_price = 0;
   }

   bool is_spike( string type ) {
      double difference = 0;

      if ( type == "sell" ) {
         difference = this.opening_price - this.actual_price;
      } else if ( type == "buy" ) {
         difference = this.actual_price - this.opening_price;
      }

      return difference >= instrument_.opm;
   }

   bool is_closing_spike( string type ) {
      double difference = 0;

      if ( type == "sell" ) {
         difference = this.opening_price - this.actual_price;
      } else if ( type == "buy" ) {
         difference = this.actual_price - this.opening_price;
      }

      return difference >= instrument_.cpm;
   }
};