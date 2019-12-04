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
   TPL tpl_[]; // Take Profit Levels
   double tpp; // Take Profit Price
   int tpl; // Take Profit Level
   double lowest_price;
   double highest_price;

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
      this.tpp = 0;
      this.tpl = 100;
      this.lowest_price = 0;
      this.highest_price = 0;
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
      this.tpp = 0;
      this.tpl = 100;
      this.lowest_price = 0;
      this.highest_price = 0;

      ArrayFree( this.tpl_ );
      ZeroMemory( this.tpl_ );
   }

   void set_tpl( int percentage_steps = 10 ) {
      double total_tpm = (instrument_.tpm / 100) * this.opening_price;

      for ( int count_step = 0; count_step <= 100; count_step += percentage_steps ) {
         int key = ArraySize( this.tpl_ );
         int new_size = ArraySize( this.tpl_ ) + 1;

         ArrayResize( this.tpl_, new_size );

         double step_tpm = (count_step / 100.0) * total_tpm;         

         this.tpl_[ key ].level = count_step;
         this.tpl_[ key ].price = this.type == "buy" ? this.opening_price + step_tpm : this.opening_price - step_tpm;
         this.tpl_[ key ].difference = step_tpm;
         this.tpl_[ key ].is_passed = false;
         
         // Set position initial TP
         if ( count_step == 100 ) { this.tpp = this.tpl_[ key ].price; }
      }
   }

   void check_tpl() {
      int count_tpl = ArraySize( this.tpl_ );
      
      // Count should start from 1 because level 0 is without a Profit lol
      for ( int count_step = 1; count_step < count_tpl; count_step++ ) {
         if (            
            ( 
               this.type == "buy" && 
               !this.tpl_[ count_step ].is_passed &&
               minute_.actual_price >= this.tpl_[ count_step ].price
            ) ||
            (
               this.type == "sell" &&
               !this.tpl_[ count_step ].is_passed &&
               minute_.actual_price <= this.tpl_[ count_step ].price
            )
         ) {
            this.tpp = this.tpl_[ count_step ].price;
            this.tpl_[ count_step ].is_passed = true;
            this.tpl = this.tpl_[ count_step ].level;
            break;
         }
      }      
   }
};