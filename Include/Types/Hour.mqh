class HOUR {
   public:
   bool is_set;
   int key;
   double opening_price;
   double sell_price;
   double buy_price;
   double actual_price;
   double lowest_price;
   double highest_price;
   
   HOUR() {
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
   
   bool is_in_direction( string direction ) {
      bool flag = false;
      if ( direction == "sell" ) {
         flag = this.opening_price > this.actual_price ? true : false;
      } else if ( direction == "buy" ) {
         flag = this.opening_price < this.actual_price ? true : false;
      }
      return flag;
   }

   bool is_stable( string direction ) {
      bool flag = false;

      if (
         (
            direction == "sell" &&
            this.actual_price - this.lowest_price < this.highest_price - this.actual_price
         ) ||
         (
            direction == "buy" &&
            this.highest_price - this.actual_price < this.actual_price - this.lowest_price
         )
      ) {
         flag = true;
      }

      return flag;
   }
};