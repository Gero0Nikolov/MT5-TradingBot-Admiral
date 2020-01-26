//+------------------------------------------------------------------+
//|                                        Advanced-BOT-v1.0.0.mq5 |
//|                                                     Gero Nikolov |
//|                                          https://geronikolov.com |
//+------------------------------------------------------------------+
#property copyright "Gero Nikolov"
#property link      "https://geronikolov.com"
#property version   "1.00"

// Include Indicators
#include "../Include/Indicators/RSI.mqh";
#include "../Include/Indicators/STOCH.mqh";
#include "../Include/Indicators/STOCHRSI.mqh";
#include "../Include/Indicators/MACD.mqh";
#include "../Include/Indicators/ATR.mqh";
#include "../Include/Indicators/ADX.mqh";
#include "../Include/Indicators/WPR.mqh";
#include "../Include/Indicators/CCI.mqh";
#include "../Include/Indicators/BP.mqh";
#include "../Include/Indicators/RVI.mqh";

// Include Types
#include "../Include/Types/Account.mqh";
#include "../Include/Types/InstrumentSetup.mqh";
#include "../Include/Types/Hour.mqh";
#include "../Include/Types/Minute.mqh";
#include "../Include/Types/Trend.mqh";
#include "../Include/Types/PositionData.mqh";
#include "../Include/Types/Position.mqh";

// Include Functions, the so called Actions
#include "../Include/Actions/OpenPosition.mqh";
#include "../Include/Actions/ClosePosition.mqh";

// Initialize Indicators
RSI rsi_;
STOCH stoch_;
STOCHRSI stoch_rsi;
MACD macd_;
ATR atr_;
ADX adx_;
WPR wpr_;
CCI cci_;
BP bp_;
RVI rvi_;

// Initialize Classes - Trading Objects
HOUR hour_;
MINUTE minute_;
INSTRUMENT_SETUP instrument_;
POSITION position_;
ACCOUNT account_;

// Initialize Trends
TREND trend_1m;
TREND trend_5m;
TREND trend_15m;
TREND trend_30m;
TREND trend_1h;

// MQL Defaults
MqlTradeRequest order_request = {0};
MqlTradeResult order_result;

// RSI
double rsi_buffer[];
double rsi_handler;

// BULLS POWER
double bulls_power_buffer[];
double bulls_power_handler;

// Inspection Variables
int position_type = 0; // -1 = Sell; 0 = Not set; 1 = Buy;

// DEBUG MODE CONTROLLER
bool debug = false;

// Expert initialization function                                   |
int OnInit(){
   // Set the EA Timer with period of 1 second
   EventSetTimer( 1 );

   // Print Account Info
   Print( "Initial Deposit: "+ account_.initial_deposit );
   Print( "Account Currency: "+ account_.currency );
   Print( "Currency Exchange Rate: "+ account_.currency_exchange_rate );
   Print( "Trading Percent: "+ account_.trading_percent );
   Print( "Free Margin: "+ ( account_.initial_deposit * account_.currency_exchange_rate ) );
   Print( "Leverage: "+ account_.leverage );

   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit( const int reason ) {
   // Destroy the EA Timer in order to clear RAM
   EventKillTimer();
}

// Expert timer function
void OnTimer() {
   MqlDateTime current_time_structure;
   datetime current_time = TimeTradeServer();
   TimeToStruct( current_time, current_time_structure );
}

// Expert tick function                                             |
void OnTick() {
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
      MqlDateTime current_time_structure;
      datetime current_time = TimeTradeServer();
      TimeToStruct( current_time, current_time_structure );      

      // Update Spread
      instrument_.spread = NormalizeDouble( current_tick.ask - current_tick.bid, 2 );
      
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

         // Send Ping
         //account_.ping();
      } else if ( minute_.is_set == true ) {         
         minute_.sell_price = current_tick.bid;
         minute_.actual_price = current_tick.bid;
         minute_.buy_price = current_tick.ask;
         minute_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
         minute_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
      }

      // Slicing Time if there is no opened position
      if ( !position_.is_opened ) {
         position_type = minute_.opening_price > minute_.actual_price ? -1 : ( minute_.opening_price < minute_.actual_price ? 1 : 0 );
         
         if ( position_type != 0 ) { // Position Type should be different than 0, to have desired direction
            if ( position_.should_open( position_type ) ) {
               open_position( position_type == -1 ? "sell" : "buy", current_tick.bid );
            }
         }
      } else if ( position_.is_opened ) {         
         position_.select = PositionSelect( Symbol() );
         position_.profit = PositionGetDouble( POSITION_PROFIT );

         // Set Listener
         if ( position_.should_close() ) {
            close_position( position_.type, position_.profit > 0 ? true : false );
         }
      }
   }
}
