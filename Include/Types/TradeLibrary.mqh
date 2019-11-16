class TRADE_LIBRARY {
   public:
   bool success;
   double rsi;
   double bulls_power;
   int type; // -1 = SELL; 1 = BUY;
   double price;

   TRADE_LIBRARY() {
      this.success = false;
      this.rsi = 0;
      this.bulls_power = 0;
      this.type = 0;
      this.price = 0;
   }
};