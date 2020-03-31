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
#include "../Include/Indicators/ATR.mqh";
#include "../Include/Indicators/ADX.mqh";
#include "../Include/Indicators/BP.mqh";

// Include Types
#include "../Include/Types/Account.mqh";
#include "../Include/Types/AverageData.mqh";
#include "../Include/Types/InstrumentSetup.mqh";
#include "../Include/Types/Month.mqh";
#include "../Include/Types/Hour.mqh";
#include "../Include/Types/Minute.mqh";
#include "../Include/Types/Trend.mqh";
#include "../Include/Types/PositionData.mqh";
#include "../Include/Types/Position.mqh";
#include "../Include/Types/Aggregator.mqh";
#include "../Include/Types/VirtualPosition.mqh";
#include "../Include/Types/VirtualLibrary.mqh";
#include "../Include/Types/Debugger.mqh";

// Include Functions, the so called Actions
#include "../Include/Actions/OpenPosition.mqh";
#include "../Include/Actions/ClosePosition.mqh";
#include "../Include/Actions/VirtualTrader.mqh";

// Initialize Indicators
RSI rsi_;
ATR atr_;
ADX adx_;
BP bp_;

// Initialize Classes - Trading Objects
MONTH month_;
HOUR hour_;
MINUTE minute_;
INSTRUMENT_SETUP instrument_;
POSITION position_;
ACCOUNT account_;
AGGREGATOR aggregator_;

// Initialize Trends
TREND trend_1m;
TREND trend_5m;
TREND trend_15m;
TREND trend_30m;
TREND trend_1h;

// Initialize Virtual Trader
VIRTUAL_TRADER vt_;
VIRTUAL_POSITION vp_[];
VIRTUAL_LIBRARY vl_;

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

// Timer Variables
int seconds = 0;

// DEBUG MODE CONTROLLER
DEBUGGER debugger_;

// Expert initialization function                                   |
int OnInit(){
   // Set the EA Timer with period of 1 second
   EventSetTimer( 1 );

   // Read the Virtual Library from VL.txt
   vl_.read();

   // Recalculate Average Big Hour Size
   //instrument_.recalculate_bhs();

   // Recover previously opened position if there is one
   //account_.recover();

   // Get Account Status
   //account_.get_account_status();

   // Print Account Info
   Print( "Initial Deposit: "+ account_.initial_deposit );
   Print( "Account Currency: "+ account_.currency );
   Print( "Currency Exchange Rate: "+ account_.currency_exchange_rate );
   Print( "Trading Percent: "+ account_.trading_percent );
   Print( "Free Margin: "+ ( account_.initial_deposit * account_.currency_exchange_rate ) );
   Print( "Leverage: "+ account_.leverage );
   Print( "Virtual Library (VL) Size: "+ ( ArraySize( vl_.vp_red ) + ArraySize( vl_.vp_green ) ) );
   Print( "VL Red: "+ ArraySize( vl_.vp_red ) );
   Print( "VL Green: "+ ArraySize( vl_.vp_green ) );

   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit( const int reason ) {
   // Destroy the EA Timer in order to clear RAM
   EventKillTimer();

   // Store to Virtual Libary
   vl_.save();
}

// Expert timer function
void OnTimer() {
   // MQL Time Structure
   MqlDateTime current_time_structure;
   datetime current_time = TimeTradeServer();
   TimeToStruct( current_time, current_time_structure );

   // Count Settings
   seconds += 1;

   // Send ping to the server to check Position Actions
   if ( seconds == account_.ping_interval ) {
      //account_.get_command_actions();

      // Reset Seconds Counter
      seconds = 0;
   }
}

// Expert tick function                                             |
void OnTick() {
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
      MqlDateTime current_time_structure;
      datetime current_time = TimeTradeServer();
      TimeToStruct( current_time, current_time_structure );
      
      // Set Hyper Volatility Measures
      instrument_.hyper_volatility_measures();

      // Update Spread
      instrument_.spread = NormalizeDouble( current_tick.ask - current_tick.bid, 2 );
      
      // Reset the Month
      if ( month_.is_set && current_time_structure.mon != month_.key ) {
         month_.reset();
      }

      // Init the Month or just Update it
      if ( !month_.is_set ) {
         month_.is_set = true;
         month_.key = current_time_structure.mon;
         month_.opening_price = iOpen( Symbol(), PERIOD_MN1, 0 );
         month_.lowest_price = iLow( Symbol(), PERIOD_MN1, 0 );
         month_.highest_price = iHigh( Symbol(), PERIOD_MN1, 0 );
         month_.actual_price = current_tick.bid;
      } else {
         month_.actual_price = current_tick.bid;
         month_.lowest_price = month_.lowest_price > month_.actual_price ? month_.actual_price : month_.lowest_price;
         month_.highest_price = month_.highest_price < month_.actual_price ? month_.actual_price : month_.highest_price;

         // Recalculate Month Type on Update
         month_.recalculate_type();
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

         // Recalculate Average Big Hour Size
         //instrument_.recalculate_bhs();

         // Store to Virtual Libary
         //vl_.save();
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

         // Calculate Margin Level
         position_.calculate_margin_level();

         // Set Listener
         if ( position_.should_close() ) {
            close_position( position_.type, position_.profit > 0 ? false : true );
         }
      }

      // Virtual Trader
      if ( !position_.picked ) {
         position_type = minute_.opening_price > minute_.actual_price ? -1 : ( minute_.opening_price < minute_.actual_price ? 1 : 0 );
         
         if ( position_type != 0 ) { // Position Type should be different than 0, to have desired direction
            if ( aggregator_.should_open( position_type ) ) {
               vt_.open_virtual_position( position_type == -1 ? "sell" : "buy", position_type == -1 ? current_tick.bid : current_tick.ask );
            }
         }
      }

      if ( position_.picked ) { position_.picked = false; }

      // Check Virtual Positions
      vt_.check_virtual_positions();
   }
}
