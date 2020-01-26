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

   bool is_spike() {
      double difference = this.opening_price - this.actual_price;
      difference = difference < 0 ? difference * (-1) : difference;

      return difference >= instrument_.opm;
   }
};