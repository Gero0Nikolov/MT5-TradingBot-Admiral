class POSITION {
   public:
   int id;
   string type;
   double opening_price;
   int volume;
   bool is_opened;
   double profit;
   bool select;
   double price_difference;
   double difference_in_percentage;
   int ticket_id;
   double rsi;
   double bulls_power;
   TPL tpl_[];

   POSITION() {
      this.id = 0;
      this.opening_price = 0;
      this.volume = 0;
      this.is_opened = false;
      this.profit = 0;
      this.select = false;
      this.price_difference = 0;
      this.difference_in_percentage = 0;
      this.ticket_id = 0;
      this.rsi = 0;
      this.bulls_power = 0;
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
      this.ticket_id = 0;
      this.rsi = 0;
      this.bulls_power = 0;

      ArrayFree( this.tpl_ );
      ZeroMemory( this.tpl_ );
   }

   void set_tpl() {
      // TODO: Calculate TPLs
   }
};