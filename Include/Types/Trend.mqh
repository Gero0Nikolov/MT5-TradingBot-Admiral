class TREND {
   public:
   double last_hour_actual_price;   
   double risk_high_price;
   double risk_low_price;
   double rsi;
   double bulls_power;
   bool is_init;

   TREND() {
      this.last_hour_actual_price = 0;      
      this.risk_high_price = 8000;
      this.risk_low_price = 6200;
      this.rsi = 50;
      this.bulls_power = 0;
      this.is_init = false;
   }
};