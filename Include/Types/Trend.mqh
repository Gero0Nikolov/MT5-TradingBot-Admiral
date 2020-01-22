class TREND {
   public:
   double last_hour_actual_price;   
   double risk_high_price;
   double risk_low_price;
   double rsi;
   double bulls_power;
   bool is_init;
   int direction;
   bool is_volatile;
   int strength;
   int previous_strength;
   bool debug_mode;

   TREND() {
      this.last_hour_actual_price = 0;      
      this.risk_high_price = 8000;
      this.risk_low_price = 6200;
      this.rsi = 50;
      this.bulls_power = 0;
      this.is_init = false;
      this.direction = 0;
      this.is_volatile = false;
      this.strength = 0;
      this.previous_strength = 0;
      this.debug_mode = true;
   }

   void get_direction( ENUM_TIMEFRAMES trade_period ) {
      // Calculate Direction Based on the 7 Indicators
      this.direction += rsi_.calculate( trade_period, 14, PRICE_CLOSE );
      this.direction += stoch_.calculate( trade_period, 9, 6 );      
      this.direction += stoch_rsi.calculate( trade_period, 14, PRICE_CLOSE );      
      this.direction += macd_.calculate( trade_period, 12, 26, PRICE_CLOSE );      
      this.direction += wpr_.calculate( trade_period, 14 );      
      this.direction += cci_.calculate( trade_period, 14, PRICE_CLOSE );      
      this.direction += bp_.calculate( trade_period, 13 );      
      this.direction += rvi_.calculate( trade_period, 14 );      

      // Calculate Volatility
      this.is_volatile = atr_.calculate( trade_period, 14 );

      // Calculate Strength
      this.previous_strength = this.strength;
      this.strength = adx_.calculate( trade_period, 14 );

      // Debug Mode
      if ( this.debug_mode ) {      
         Print( "Direction: "+ this.direction );
         Print( "Is Volatile: "+ this.is_volatile );
         Print( "Strength: "+ this.strength );
         Print( "Previous Srength: "+ this.strength );
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