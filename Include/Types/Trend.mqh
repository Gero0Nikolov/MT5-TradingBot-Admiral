class TREND {
   public:
   int direction;
   bool is_volatile;
   int strength;
   int previous_strength;

   TREND() {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;
      this.previous_strength = 0;
   }

   void get_direction( ENUM_TIMEFRAMES trade_period ) {
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;

      // Calculate Direction Based on the 8 Indicators
      this.direction += rsi_.calculate( trade_period, 14, PRICE_CLOSE );
      this.direction += stoch_.calculate( trade_period, 9, 6 );      
      this.direction += stoch_rsi.calculate( trade_period, 14, PRICE_CLOSE );      
      this.direction += macd_.calculate( trade_period, 12, 26, PRICE_CLOSE );      
      this.direction += wpr_.calculate( trade_period, 14 );      
      this.direction += cci_.calculate( trade_period, 14, PRICE_CLOSE );      
      this.direction += bp_.calculate( trade_period, 13 );      
      this.direction += rvi_.calculate( trade_period, 14 );      

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