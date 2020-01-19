//+------------------------------------------------------------------+
//|                                        Advanced-BOT-v1.0.0.mq5 |
//|                                                     Gero Nikolov |
//|                                          https://geronikolov.com |
//+------------------------------------------------------------------+
#property copyright "Gero Nikolov"
#property link      "https://geronikolov.com"
#property version   "1.00"

// EXAMPLE: #include "../Include/test.mqh"

// Include Types
#include "../Include/Types/VirtualPosition.mqh";
#include "../Include/Types/Hour.mqh";
#include "../Include/Types/Minute.mqh";
#include "../Include/Types/Day.mqh";
#include "../Include/Types/Calendar.mqh";
#include "../Include/Types/QType.mqh";
#include "../Include/Types/InstrumentSetup.mqh";
#include "../Include/Types/Trend.mqh";
#include "../Include/Types/TPL.mqh";
#include "../Include/Types/Position.mqh";
#include "../Include/Types/Account.mqh";
#include "../Include/Types/TradeLibrary.mqh";

// Include Functions, the so called Actions
#include "../Include/Actions/VirtualTrader.mqh";
#include "../Include/Actions/OpenPosition.mqh";
#include "../Include/Actions/ClosePosition.mqh";
#include "../Include/Actions/IsRiskyDeal.mqh";
#include "../Include/Actions/UpdateTradeLibrary.mqh";
#include "../Include/Actions/PositionCheckup.mqh";
#include "../Include/Actions/IsFridayEnding.mqh";

// Initialize Classes - Trading Objects
VIRTUAL_TRADER vt_;
VIRTUAL_POSITION vp_[];
Q_TYPE qs_[ 4 ];
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
   // Set the EA Timer with period of 1 second
   EventSetTimer( 1 );

   // Read the Library
   read_library();

   // Print Account Info
   Print( "Initial Deposit: "+ account_.initial_deposit );
   Print( "Account Currency: "+ account_.currency );
   Print( "Currency Exchange Rate: "+ account_.currency_exchange_rate );
   Print( "Trading Percent: "+ account_.trading_percent );
   Print( "Free Margin: "+ ( account_.initial_deposit * account_.currency_exchange_rate ) );
   Print( "Leverage: "+ account_.leverage );
   Print( "Library size: "+ ArraySize( library_ ) );

   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit( const int reason ) {
   // Destroy the EA Timer in order to clear RAM
   EventKillTimer();

   // Store to the Library
   //store_to_library();
}

// Expert timer function
void OnTimer() {
   MqlDateTime current_time_structure;
   datetime current_time = TimeTradeServer();
   TimeToStruct( current_time, current_time_structure );

   // Check the year and reset the Qs if needed
   if ( current_time_structure.year > calendar_.year ) {
      calendar_.set_qs();
   }

   // Reset the day if needed
   if ( current_time_structure.year + current_time_structure.mon + current_time_structure.day != day_.key ) {
      day_.reset();      
   }
}

// Expert tick function                                             |
void OnTick() {
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
      MqlDateTime current_time_structure;
      datetime current_time = TimeTradeServer();
      TimeToStruct( current_time, current_time_structure );      
      
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

         // Store to the Library
         //store_to_library(); 
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
         if ( minute_.opening_price > minute_.actual_price ) { // Sell
            if ( should_open( -1 ) ) {                  
               open_position( "sell", current_tick.bid );
            }
         } else if ( minute_.opening_price < minute_.actual_price  ) { // Buy
            if ( should_open( 1 ) ) {                  
               open_position( "buy", current_tick.ask );
            }
         }
      } else if ( position_.is_opened ) {
         position_.select = PositionSelect( Symbol() );
         position_.profit = PositionGetDouble( POSITION_PROFIT );

         // Update Position Lowest & Highest Price
         position_.lowest_price = hour_.actual_price < position_.lowest_price ? hour_.actual_price : position_.lowest_price;
         position_.highest_price = hour_.actual_price > position_.highest_price ? hour_.actual_price : position_.highest_price;

         // Set Listeners
         if ( position_.profit > instrument_.tp_listener ) { // Take Profit Listener
            if ( position_.type == "sell" ) {
               position_.price_difference = hour_.actual_price - position_.lowest_price;

               if ( position_.price_difference > 0 ) {
                  position_.difference_in_percentage = ( position_.price_difference / ( ( hour_.actual_price + position_.lowest_price ) / 2 ) ) * 100;
                  if ( position_.difference_in_percentage >= instrument_.tpm ) { close_position( "sell" ); }
               }
            } else if ( position_.type == "buy" ) {
               position_.price_difference = position_.highest_price - hour_.actual_price;

               if ( position_.price_difference > 0 ) {
                  position_.difference_in_percentage = ( position_.price_difference / ( ( position_.highest_price + hour_.actual_price ) / 2 ) ) * 100;
                  if ( position_.difference_in_percentage >= instrument_.tpm ) { close_position( "buy" ); }
               }
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

      // Virtual Mode
      if ( !position_.picked ) { // Create new Virtual Positions only if there are already OPENED positions
         if ( minute_.opening_price > minute_.actual_price ) { // Sell
            if ( should_open_virtual_positions( -1 ) ) {
               vt_.open_virtual_position( "sell", current_tick.bid );
            }
         } else if ( minute_.opening_price < minute_.actual_price  ) { // Buy
            if ( should_open_virtual_positions( 1 ) ) {               
               vt_.open_virtual_position( "buy", current_tick.ask );
            }
         }
      }

      if ( position_.picked ) { position_.picked = false; }

      // Make inspection of the current price and the Virtual Positions
      vt_.check_virtual_positions();
   }
}
