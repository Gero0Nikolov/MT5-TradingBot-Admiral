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
#include "../Include/Actions/IsRiskyDeal.mqh";
#include "../Include/Actions/UpdateTradeLibrary.mqh";

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
   
   HOUR() {
      this.reset();
   }

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
   
   MINUTE() {
      this.reset();
   }

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

class DAY {
   public:      
   int key;
   datetime yesterday_date;
   double yesterday_opening;
   double yesterday_closing;
   double yesterday_highest;
   double yesterday_lowest;
   string yesterday_direction;

   DAY() {
      this.reset();
   }

   void reset() {
      MqlDateTime time_structure;
      datetime time = TimeTradeServer();
      TimeToStruct( time, time_structure );
      
      this.key = time_structure.year + time_structure.mon + time_structure.day;
      this.set_yesterday_market_info();

      // Get News for Today
      //calendar_.get_calendar_values( time, 1, "day" );
   }

   void set_yesterday_market_info() {
      // Get Yesterday Market Info
      int day_shift = 1;
      MqlRates rate[];
      CopyRates( Symbol(), PERIOD_D1, day_shift, 1, rate );
      
      // Set Yesterday Market Info
      this.yesterday_date = rate[ 0 ].time;
      this.yesterday_opening = rate[ 0 ].open;
      this.yesterday_closing = rate[ 0 ].close;
      this.yesterday_highest = rate[ 0 ].high;
      this.yesterday_lowest = rate[ 0 ].low;
      this.yesterday_direction = yesterday_opening > yesterday_closing ? "sell" : ( yesterday_opening < yesterday_closing ? "buy" : "" );
   }
};

class CALENDAR {
   public:
   string country_code;
   MqlCalendarValue values[];
   bool got_values;
   MqlCalendarValue risk_values[];

   CALENDAR( string alpha_2_code ) {
      this.country_code = alpha_2_code;
      this.got_values = false;
   }

   /*
   *  Function Arguments: 
   *  1) From [DATETIME]
   *  2) Extender [INT]: With what amount the current time should be extended
   *  3) Extender_type [STRING]: Type of the extender: Minute, Hour, Day
   */
   void get_calendar_values( datetime from, int extender, string extender_type ) {
      // Convert extender to the proper amount of seconds
      if ( extender_type == "minute" ) {
         extender *= 60; // 60 seconds in 1 minute
      } else if ( extender_type == "hour" ) {
         extender *= 60 * 60; // 60 minutes * 60 seconds (in each minute) * extender to find the hours extender
      } else if ( extender_type == "day" ) {
         extender *= 24 * 60 * 60; // 24 hours * 60 minutes * 60 seconds * extender
      }

      // Find the new DateTime
      datetime to = from + extender;

      // Get News
      this.got_values = CalendarValueHistory( this.values, from, to, this.country_code, NULL );

      // Clear Risk Values
      ZeroMemory( this.risk_values );
      int count_risk_values = 0;

      // Find risk values
      for ( int count_values = 0; count_values < ArraySize( this.values ); count_values++ ) {         
         if ( this.values[ count_values ].impact_type >= 2 ) {
            ArrayResize( this.risk_values, count_risk_values + 1 );
            this.risk_values[ count_risk_values ] = this.values[ count_values ];
            count_risk_values += 1;
         }
      }
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
      this.risk_high_price = 8000;
      this.risk_low_price = 6200;
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
   double rsi;
   double bulls_power;

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
   }
};

class ACCOUNT {
   public:
   string currency;
   string broker;
   double currency_exchange_rate;
   double trading_percent;
   double initial_deposit;
   double withdraw_percentage;
   int ping_counter;

   ACCOUNT() {
      // Get Account Currency
      this.currency = AccountInfoString( ACCOUNT_CURRENCY );

      // Set Broker Name
      this.broker = "AdmiralMarkets";

      // Set Currency Exchange Rate to USD (Because NQ100 is USD :O)      
      this.set_currency_exchange_rate();

      // Set Trading Percent (How much of your account are you willing to play with)
      this.trading_percent = 50.0 / 100.0;

      // Set the Initial Deposit on BOT start
      this.initial_deposit = AccountInfoDouble( ACCOUNT_FREEMARGIN );

      // Set withdraw percentage
      this.withdraw_percentage = 10;

      // Set Ping Counter to 0
      this.ping_counter = 0;
   }

   void set_currency_exchange_rate() {
      if ( this.currency == "EUR" ) {
         this.currency_exchange_rate = NormalizeDouble( SymbolInfoDouble( "EURUSD", SYMBOL_BID ), 2 );
      } else if ( this.currency == "BGN" ) {
         this.currency_exchange_rate = NormalizeDouble( 1.000 / SymbolInfoDouble( "USDBGN", SYMBOL_BID ), 2 );
      } else if ( this.currency == "USD" ) {
         this.currency_exchange_rate = 1.000;
      }
   }

   void suggest_withdraw() {
      double free_margin = AccountInfoDouble( ACCOUNT_FREEMARGIN );
      double difference_between_id_fm = free_margin - this.initial_deposit;

      // Check if the account is profitable
      if ( difference_between_id_fm > 0 ) {
         double difference_between_id_fm_percentage = ( difference_between_id_fm / this.initial_deposit ) * 100;
         
         // Check if the BOT managed to make 50% profit and if so send an email
         if ( difference_between_id_fm_percentage > this.withdraw_percentage ) {
            string cookie = NULL, headers;
            char post[], result[];
            string api_key = IntegerToString( AccountInfoInteger( ACCOUNT_LOGIN ) );
            string data = "action=mt5_suggest_withdraw&api_key="+ api_key +"&withdraw_percentage="+ this.withdraw_percentage +"&profit="+ difference_between_id_fm;
            StringToCharArray( data, post );
            string url = "https://geronikolov.com/wp-admin/admin-ajax.php";

            ResetLastError();

            int res = WebRequest( "POST", url, cookie, NULL, 500, post, ArraySize( post ), result, headers );

            if ( res == -1 ) { Print( "Error in WebRequest. Error code: ", GetLastError() ); }
         }
      }
   }

   void ping() {      
      string cookie = NULL, headers;
      char post[], result[];
      string api_key = IntegerToString( AccountInfoInteger( ACCOUNT_LOGIN ) );
      string data = "action=mt5_ping&api_key="+ api_key +"&broker="+ this.broker;
      StringToCharArray( data, post );
      string url = "https://geronikolov.com/wp-admin/admin-ajax.php";

      ResetLastError();

      int res = WebRequest( "POST", url, cookie, NULL, 500, post, ArraySize( post ), result, headers );

      if ( res == -1 ) { Print( "Error in WebRequest. Error code: ", GetLastError() ); }
      else if ( res == 200 ) { /* SERVER WAS PINGED */ }
   }
};

class TRADE_LIBRARY {
   public:
   bool success;
   double rsi;
   double bulls_power;
   int type; // -1 = SELL; 1 = BUY;

   TRADE_LIBRARY() {
      this.success = false;
      this.rsi = 0;
      this.bulls_power = 0;
      this.type = 0;
   }
};

// Trading Objects
CALENDAR calendar_( "US" );
HOUR hour_;
MINUTE minute_;
DAY day_;
INSTRUMENT_SETUP instrument_;
TREND trend_;
POSITION position_;
ACCOUNT account_;
TRADE_LIBRARY library_[];

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
   Print( "Initial Deposit: "+ account_.initial_deposit );
   Print( "Account Currency: "+ account_.currency );
   Print( "Currency Exchange Rate: "+ account_.currency_exchange_rate );
   Print( "Trading Percent: "+ account_.trading_percent );
   Print( "Free Margin: "+ ( account_.initial_deposit * account_.currency_exchange_rate ) );
   Print( "Leverage: "+ AccountInfoInteger( ACCOUNT_LEVERAGE ) );

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
      
      if ( current_time_structure.year + current_time_structure.mon + current_time_structure.day != day_.key ) {
         day_.reset();   
      }
      
      // Reset the Hour
      if ( hour_.is_set && current_time_structure.hour != hour_.key ) {
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

         // Send Ping
         account_.ping();
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
               trend_.rsi > 30 &&
               trend_.bulls_power < 0 &&
               //!is_risky_deal( -1 ) &&
               minute_.actual_price > trend_.risk_low_price &&
               minute_.actual_price < trend_.risk_high_price &&
               minute_.opening_price - minute_.actual_price >= instrument_.opm      
            ) {                  
               open_position( "sell", current_tick.bid );
            } 
         } else if ( minute_.opening_price < minute_.actual_price  ) { // Buy
            if (
               hour_.is_in_direction( "buy" ) &&
               !hour_.is_big() &&
               trend_.rsi < 70 &&
               trend_.bulls_power > 0 &&
               //!is_risky_deal( 1 ) &&
               minute_.actual_price > trend_.risk_low_price &&
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
               
               if ( position_.difference_in_percentage >= instrument_.slm ) { close_position( "sell", true ); }
            } else if ( position_.type == "buy" ) {
               position_.price_difference = position_.opening_price - hour_.actual_price ;
               position_.difference_in_percentage = ( position_.price_difference / position_.opening_price ) * 100;
               
               if ( position_.difference_in_percentage >= instrument_.slm ) { close_position( "buy", true ); }
            }
         }
      }   
   }
}
