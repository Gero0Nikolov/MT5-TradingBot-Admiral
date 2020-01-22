class TREND {
   public:
   double last_hour_actual_price;   
   double risk_high_price;
   double risk_low_price;
   double rsi;
   double bulls_power;
   bool is_init;
   int previous_strength;
   bool debug_mode;

   TREND() {
      this.last_hour_actual_price = 0;      
      this.risk_high_price = 8000;
      this.risk_low_price = 6200;
      this.rsi = 50;
      this.bulls_power = 0;
      this.is_init = false;
      this.previous_strength = 0;
      this.debug_mode = true;
   }

   void get_direction( ENUM_TIMEFRAMES trade_period ) {
      int direction;
      bool is_volatile;
      int strength;

      // Calculate Direction Based on the 7 Indicators
      direction += rsi_.calculate( trade_period, 14, PRICE_CLOSE );
      direction += stoch_.calculate( trade_period, 9, 6 );      
      direction += stoch_rsi.calculate( trade_period, 14, PRICE_CLOSE );      
      direction += macd_.calculate( trade_period, 12, 26, PRICE_CLOSE );      
      direction += wpr_.calculate( trade_period, 14 );      
      direction += cci_.calculate( trade_period, 14, PRICE_CLOSE );      
      direction += bp_.calculate( trade_period, 13 );      
      direction += rvi_.calculate( trade_period, 14 );      

      // Calculate Volatility
      is_volatile = atr_.calculate( trade_period, 14 );

      // Calculate Strength
      this.previous_strength = strength;
      strength = adx_.calculate( trade_period, 14 );

      // Debug Mode
      if ( this.debug_mode ) {      
         Print( "Direction: "+ direction );
         Print( "Is Volatile: "+ is_volatile );
         Print( "Strength: "+ strength );
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