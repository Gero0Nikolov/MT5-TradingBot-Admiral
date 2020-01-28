class TREND {
   public:
   int direction;
   bool is_volatile;
   int strength;
   int previous_strength;
   int bars;
   int rsi_result;
   int bp_result;

   TREND() {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;
      this.previous_strength = 0;
      this.bars = 2;
      this.rsi_result = 0;
      this.bp_result = 0;
   }

   void get_direction( ENUM_TIMEFRAMES trade_period ) {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;

      // Calculate Direction Based on the 5 Indicators
      this.rsi_result = rsi_.calculate( trade_period, 14, PRICE_CLOSE );
      this.bp_result = bp_.calculate( trade_period, 13 );
      
      if ( this.rsi_result != 0 ) {
         this.direction += this.rsi_result;   
         this.direction += this.bp_result;
      }

      // Calculate Volatility
      is_volatile = atr_.calculate( trade_period, 14 );

      // Calculate Strength
      this.previous_strength = this.strength;
      this.strength = adx_.calculate( trade_period, 14 );

      // Debug Mode
      if ( debugger_.debug_trend ) {      
         Print( "Direction: "+ this.direction );
         Print( "Is Volatile: "+ this.is_volatile );
         Print( "Strength: "+ this.strength );
         Print( "Previous Srength: "+ this.previous_strength );
         Print( "===Indicators:" );
         Print( "RSI: "+ rsi_.calculate( trade_period, 14, PRICE_CLOSE ) );
         Print( "BP: "+ bp_.calculate( trade_period, 13 ) );
      }
   }
};