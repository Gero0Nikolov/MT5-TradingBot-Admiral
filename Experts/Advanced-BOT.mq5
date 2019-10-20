//+------------------------------------------------------------------+
//|                                        Advanced-BOT-v1.0.0.mq5 |
//|                                                     Gero Nikolov |
//|                                          https://geronikolov.com |
//+------------------------------------------------------------------+
#property copyright "Gero Nikolov"
#property link      "https://geronikolov.com"
#property version   "1.00"

// Include Functions
// EXAMPLE: #include "../Include/test.mqh"
#include "../Include/Actions/OpenPosition.mqh";
#include "../Include/Actions/IsRiskyDeal.mqh";

// Initialize Classes
class HOUR {   
   public:
   bool is_set;
   int key;
   double opening_price;
   double sell_price;
   double buy_price;
   double actual_price;
   double lowest_price;
   double highest_price;
   
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
   
   bool is_in_direction( string direction ) {
      bool flag = false;
      if ( direction == "sell" ) {
         flag = this.opening_price > this.actual_price ? true : false;
      } else if ( direction == "buy" ) {
         flag = this.opening_price < this.actual_price ? true : false;
      }
      return flag;
   }

   bool is_big() {
      return this.highest_price - this.lowest_price >= 25;
   }

   bool is_stable( string direction ) {
      bool flag = false;

      if (
         (
            direction == "sell" &&
            this.actual_price - this.lowest_price < this.highest_price - this.actual_price
         ) ||
         (
            direction == "buy" &&
            this.highest_price - this.actual_price < this.actual_price - this.lowest_price
         )
      ) {
         flag = true;
      }

      return flag;
   }
};

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
};

class INSTRUMENT_SETUP {
   public:
   string name;
   double opm; // Opening Position Movement
   double tpm; // Take Profit Movement
   double slm; // Stop Loss Movement   
   
   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.opm = 10;
      this.tpm = 0.2 / 100;
      this.slm = 0.66 / 100;      
   }
};

class TREND {
   public:
   int direction; // -1 = Negative; 0 = Neutral; 1 = Positive;
   int last_direction; // -1 = Negative; 0 = Neutral; 1 = Positive;
   int analyzed_hours;
   double last_hour_actual_price;   
   double risk_high_price;
   double risk_low_price;
   double risk_high_price_24;
   double risk_low_price_24;
   double risk_hours_counter;
   double rsi;
   bool is_init;

   TREND() {
      this.direction = 0;
      this.last_direction = this.direction;
      this.analyzed_hours = 0;
      this.last_hour_actual_price = 0;      
      this.risk_high_price = 7900;
      this.risk_low_price = 6300;
      this.risk_high_price_24 = 0;
      this.risk_low_price_24 = 0;
      this.risk_hours_counter = 0;   
      this.rsi = 50;
      this.is_init = false;
   }

   bool is_stable( string direction ) {
      bool flag = false;

      if ( direction == "sell" ) {
         flag = this.direction <= this.last_direction ? true : false;
      } else if ( direction == "buy" ) {
         flag = this.direction >= this.last_direction ? true : false;
      }

      return flag;
   }

   void reset_risk_24( HOUR &hour_ ) {
      this.risk_high_price_24 = hour_.highest_price;
      this.risk_low_price_24 = hour_.lowest_price;
      this.risk_hours_counter = 0;
   }
};

class POSITION {
   public:
   int id;
   string type;
   double opening_price;
   int volume;

   POSITION() {
      this.id = 0;
      this.opening_price = 0;
      this.volume = 0;
   }

   void reset() {
      this.id += 1;
      this.opening_price = 0;
      this.volume = 0;      
   }
};

// Trading Objects
HOUR hour_;
MINUTE minute_;
INSTRUMENT_SETUP instrument_;
TREND trend_;
POSITION position_;

// MQL Defaults
MqlTradeRequest order_request = {0};
MqlTradeResult order_result;

// RSI
double rsi_buffer[];
double rsi_handler;

// Expert initialization function                                   |
int OnInit(){   
   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit(const int reason) {
}

// Expert tick function                                             |
void OnTick() {
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
      MqlDateTime current_time_structure;
   
      datetime current_time = TimeTradeServer();
      TimeToStruct( current_time, current_time_structure );         
      
      // Prepare the HOUR object
      if ( hour_.is_set && current_time_structure.hour != hour_.key ) {
         // Trend Analysis
         trend_.analyzed_hours += 1;         
         trend_.last_direction = trend_.direction;

         if ( hour_.is_big() ) {
            trend_.direction = hour_.actual_price > trend_.last_hour_actual_price ? trend_.direction + 1 : ( hour_.actual_price < trend_.last_hour_actual_price ? trend_.direction - 1 : trend_.direction );

            if ( 
               hour_.is_stable( "sell" ) &&
               trend_.risk_low_price_24 > hour_.lowest_price
            ) {
               trend_.risk_low_price_24 = hour_.lowest_price;
            } else if (
               hour_.is_stable( "buy" ) && 
               trend_.risk_high_price_24 < hour_.highest_price
            ) {
               trend_.risk_high_price_24 = hour_.highest_price;
            }
         }

         trend_.last_hour_actual_price = hour_.actual_price;

         // Update Trend Risk Counter   
         trend_.risk_hours_counter += 1;

         // Reset the Trend Risk for 24 hours if needed
         if ( trend_.risk_hours_counter >= 24 ) { trend_.reset_risk_24( hour_ ); }         

         // Reset the hour
         hour_.reset(); 
      }
      
      // Init the Hour or just Update it
      if ( !hour_.is_set ) {
         hour_.is_set = true;
         hour_.key = current_time_structure.hour;
         hour_.opening_price = current_tick.bid;
         hour_.sell_price = current_tick.bid;
         hour_.actual_price = current_tick.bid;
         hour_.buy_price = current_tick.ask;
         hour_.lowest_price = hour_.opening_price;
         hour_.highest_price = hour_.opening_price;

         // Set Trend Risk Prices they are = 0
         if ( !trend_.is_init ) {
            trend_.risk_high_price_24 = hour_.highest_price;
            trend_.risk_low_price_24 = hour_.lowest_price;
         }
      } else if ( hour_.is_set ) {         
         hour_.sell_price = current_tick.bid;
         hour_.actual_price = current_tick.bid;
         hour_.buy_price = current_tick.ask;
         hour_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
         hour_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
      }

      // If analyzed hours are more than 24 then start trading
      if ( 
         trend_.analyzed_hours >= 24 &&
         trend_.direction != 0
      ) {
         // Prepare the MINUTE object
         if ( minute_.is_set && current_time_structure.min != minute_.key ) { minute_.reset(); }
         
         if ( minute_.is_set == false ) {
            minute_.is_set = true;
            minute_.key = current_time_structure.min;
            minute_.opening_price = current_tick.bid;
            minute_.sell_price = current_tick.bid;
            minute_.actual_price = current_tick.bid;
            minute_.buy_price = current_tick.ask;
            minute_.lowest_price = hour_.opening_price;
            minute_.highest_price = hour_.opening_price;

            // Recalculate RSI
            rsi_handler = iRSI( Symbol(), PERIOD_M1, 10, PRICE_CLOSE );
            CopyBuffer( rsi_handler, 0, 0, 1, rsi_buffer );
            trend_.rsi = rsi_buffer[ 0 ];            
         } else if ( minute_.is_set == true ) {         
            minute_.sell_price = current_tick.bid;
            minute_.actual_price = current_tick.bid;
            minute_.buy_price = current_tick.ask;
            minute_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
            minute_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
         }

         // Slicing Time if there is no opened position
         if ( PositionsTotal() == 0 ) {
            // if ( minute_.opening_price > minute_.actual_price ) { // Sell
            //    if (
            //       hour_.is_in_direction( "sell" ) &&
            //       !hour_.is_big() &&
            //       trend_.direction < 0 &&
            //       trend_.is_stable( "sell" ) &&
            //       minute_.opening_price - minute_.actual_price >= instrument_.opm
            //    ) {                  
            //       open_position( "sell", current_tick.bid );
            //    }
            // } else if ( minute_.opening_price < minute_.actual_price ) { // Buy
            //    if (
            //       hour_.is_in_direction( "buy" ) &&
            //       !hour_.is_big() &&
            //       trend_.direction > 0 &&
            //       trend_.is_stable( "buy" ) &&
            //       minute_.actual_price - minute_.opening_price >= instrument_.opm
            //    ) {                  
            //       open_position( "buy", current_tick.ask );
            //    }
            // }   

            if ( minute_.opening_price > minute_.actual_price ) { // Sell
               if (
                  hour_.is_in_direction( "sell" ) &&
                  !hour_.is_big() &&
                  !is_risky_deal( "sell" ) &&
                  trend_.rsi > 30 &&
                  minute_.actual_price > trend_.risk_low_price &&
                  minute_.opening_price - minute_.actual_price >= instrument_.opm      
               ) {                  
                  open_position( "sell", current_tick.bid );
               } 
            } else if ( minute_.opening_price < minute_.actual_price  ) { // Buy
               if (
                  hour_.is_in_direction( "buy" ) &&
                  !hour_.is_big() &&
                  !is_risky_deal( "buy" ) &&
                  trend_.rsi < 70 &&
                  minute_.actual_price < trend_.risk_high_price &&
                  minute_.actual_price - minute_.opening_price >= instrument_.opm
               ) {                  
                  open_position( "buy", current_tick.ask );
               }
            }
         }
      }
   }
}
