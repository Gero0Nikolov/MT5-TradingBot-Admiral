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
#include "../Include/Actions/ClosePosition.mqh";
#include "../Include/Actions/Logger.mqh";
// #include "../Include/Actions/IsRiskyDeal.mqh";

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
      this.tpm = 0.66;
      this.slm = 1;      
   }
};

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
      this.risk_high_price = 7900;
      this.risk_low_price = 6300;  
      this.rsi = 50;
      this.bulls_power = 0;
      this.is_init = false;
   }
};

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
   }
};

class ACCOUNT {
   public:
   string currency;
   double currency_exchange_rate;
   double trading_percent;

   ACCOUNT() {
      // Get Account Currency
      this.currency = AccountInfoString( ACCOUNT_CURRENCY );

      // Set Currency Exchange Rate to USD (Because NQ100 is USD :O)
      if ( this.currency == "EUR" ) {
         this.currency_exchange_rate = 1.11;
      } else if ( this.currency == "BGN" ) {
         this.currency_exchange_rate = 0.57;
      } else if ( this.currency == "USD" ) {
         this.currency_exchange_rate = 1;
      }

      // Set Trading Percent (How much of your account are you willing to play with)
      this.trading_percent = 50.0 / 100.0;
   }
};

// Trading Objects
HOUR hour_;
MINUTE minute_;
INSTRUMENT_SETUP instrument_;
TREND trend_;
POSITION position_;
ACCOUNT account_;

// MQL Defaults
MqlTradeRequest order_request = {0};
MqlTradeResult order_result;

// RSI
double rsi_buffer[];
double rsi_handler;

// BULLS POWER
double bulls_power_buffer[];
double bulls_power_handler;

// Expert initialization function                                   |
int OnInit(){   
   logger( "Account Currency", -69, account_.currency );
   logger( "Currency Exchange Rate", account_.currency_exchange_rate );
   logger( "Trading Percent", account_.trading_percent );
   logger( "Free Margin", AccountInfoDouble( ACCOUNT_FREEMARGIN ) * account_.currency_exchange_rate );
   logger( "Leverage", AccountInfoInteger( ACCOUNT_LEVERAGE ) );   
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
      
      // Reset the Hour
      if ( hour_.is_set && current_time_structure.hour != hour_.key ) { hour_.reset(); }
      
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
      } else if ( hour_.is_set ) {         
         hour_.sell_price = current_tick.bid;
         hour_.actual_price = current_tick.bid;
         hour_.buy_price = current_tick.ask;
         hour_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
         hour_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
      }

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

         // Recalculate Bulls Power
         bulls_power_handler = iBullsPower( Symbol(), PERIOD_M1, 10 );
         CopyBuffer( bulls_power_handler, 0, 0, 1, bulls_power_buffer );
         trend_.bulls_power = bulls_power_buffer[ 0 ];
      } else if ( minute_.is_set == true ) {         
         minute_.sell_price = current_tick.bid;
         minute_.actual_price = current_tick.bid;
         minute_.buy_price = current_tick.ask;
         minute_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
         minute_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
      }

      // Slicing Time if there is no opened position
      if ( !position_.is_opened ) {
         if ( minute_.opening_price > minute_.actual_price ) { // Sell
            if (
               hour_.is_in_direction( "sell" ) &&
               !hour_.is_big() &&
               //!is_risky_deal( "sell" ) &&
               trend_.rsi > 30 &&
               trend_.bulls_power < 0 &&
               minute_.actual_price > trend_.risk_low_price &&
               minute_.opening_price - minute_.actual_price >= instrument_.opm      
            ) {                  
               open_position( "sell", current_tick.bid );
            } 
         } else if ( minute_.opening_price < minute_.actual_price  ) { // Buy
            if (
               hour_.is_in_direction( "buy" ) &&
               !hour_.is_big() &&
               //!is_risky_deal( "buy" ) &&
               trend_.rsi < 70 &&
               trend_.bulls_power > 0 &&
               minute_.actual_price < trend_.risk_high_price &&
               minute_.actual_price - minute_.opening_price >= instrument_.opm
            ) {                  
               open_position( "buy", current_tick.ask );
            }
         }
      } else if ( position_.is_opened ) {
         position_.select = PositionSelectByTicket( position_.ticket_id );
         position_.profit = PositionGetDouble( POSITION_PROFIT );

         if ( position_.profit > 10 ) { // Take Profit Listener
            if ( position_.type == "sell" ) {
               position_.price_difference = position_.opening_price - hour_.actual_price;
               position_.difference_in_percentage = ( position_.price_difference / position_.opening_price ) * 100;
               
               if ( position_.difference_in_percentage >= instrument_.tpm ) { close_position( "sell" ); }
            } else if ( position_.type == "buy" ) {
               position_.price_difference = hour_.actual_price - position_.opening_price;
               position_.difference_in_percentage = ( position_.price_difference / position_.opening_price ) * 100;
               
               if ( position_.difference_in_percentage >= instrument_.tpm ) { close_position( "buy" ); }
            }
         } else if ( position_.profit <= 0 ) { // Stop Loss Listener
            if ( position_.type == "sell" ) {
               position_.price_difference = hour_.actual_price - position_.opening_price;
               position_.difference_in_percentage = ( position_.price_difference / position_.opening_price ) * 100;
               
               if ( position_.difference_in_percentage >= instrument_.slm ) { close_position( "sell" ); }
            } else if ( position_.type == "buy" ) {
               position_.price_difference = position_.opening_price - hour_.actual_price ;
               position_.difference_in_percentage = ( position_.price_difference / position_.opening_price ) * 100;
               
               if ( position_.difference_in_percentage >= instrument_.slm ) { close_position( "buy" ); }
            }
         }
      }   
   }
}
