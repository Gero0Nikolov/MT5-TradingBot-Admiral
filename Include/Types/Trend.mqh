class TREND {
   public:
   int direction;
   bool is_volatile;
   int strength;
   int previous_strength;
   int bars;
   int rsi_result;
   double current_rsi;

   TREND() {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;
      this.previous_strength = 0;
      this.bars = 2;
      this.rsi_result = 0;
      this.current_rsi = 50;
   }

   void get_direction( ENUM_TIMEFRAMES trade_period ) {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;

      // Calculate Direction Based on the 5 Indicators
      this.rsi_result = rsi_.calculate( trade_period, 14, PRICE_CLOSE );
      
      if ( this.rsi_result != 0 ) {
         this.direction += this.rsi_result;   
         this.direction += bp_.calculate( trade_period, 13 );
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
         Print( "Stoch: "+ stoch_.calculate( trade_period, 14, PRICE_CLOSE ) );
         Print( "STOCHRSI: "+ stoch_rsi.calculate( trade_period, 14, PRICE_CLOSE ) );
         Print( "MACD: "+ macd_.calculate( trade_period, 12, 26, PRICE_CLOSE ) ); 
         Print( "WPR: "+ wpr_.calculate( trade_period, 14 ) );
         Print( "CCI: "+ cci_.calculate( trade_period, 14, PRICE_CLOSE ) );
         Print( "BP: "+ bp_.calculate( trade_period, 13 ) );
         Print( "RVI: "+ rvi_.calculate( trade_period, 14 ) );
      }
   }
};