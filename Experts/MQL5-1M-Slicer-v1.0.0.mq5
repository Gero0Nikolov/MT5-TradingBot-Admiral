//+------------------------------------------------------------------+
//|                                        MQL5-1M-Slicer-v1.0.0.mq5 |
//|                                                     Gero Nikolov |
//|                                          https://geronikolov.com |
//+------------------------------------------------------------------+
#property copyright "Gero Nikolov"
#property link      "https://geronikolov.com"
#property version   "1.00"

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
};

class MINUTE {   
   public:
   bool is_set;
   bool is_warned;
   int key;
   double opening_price;
   double sell_price;
   double buy_price;
   double actual_price;
   double lowest_price;
   double highest_price;
   
   void reset() {
      this.is_set = false;
      this.is_warned = false;
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
   double trade_volume;
   
   INSTRUMENT_SETUP() {
      this.name = "NDAQ100";
      this.opm = 10;
      this.tpm = 3;
      this.slm = 50;
      this.trade_volume = 10;
   }
};

HOUR hour_;
MINUTE minute_;
INSTRUMENT_SETUP instrument_;
bool is_position_opened = false;
string position_type;
double position_opening_price = 0;
MqlTradeRequest order_request = {0};
MqlTradeResult order_result;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---      
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
      MqlDateTime current_time_structure;
   
      datetime current_time = TimeTradeServer();
      TimeToStruct( current_time, current_time_structure );
      
      // Prepare the HOUR object
      if ( hour_.is_set && current_time_structure.hour != hour_.key ) { hour_.reset(); }
      
      if ( hour_.is_set == false ) {
         hour_.is_set = true;
         hour_.key = current_time_structure.hour;
         hour_.opening_price = current_tick.bid;
         hour_.sell_price = current_tick.bid;
         hour_.actual_price = current_tick.bid;
         hour_.buy_price = current_tick.ask;
         hour_.lowest_price = hour_.opening_price;
         hour_.highest_price = hour_.opening_price;
      } else if ( hour_.is_set == true ) {         
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
      } else if ( minute_.is_set == true ) {         
         minute_.sell_price = current_tick.bid;
         minute_.actual_price = current_tick.bid;
         minute_.buy_price = current_tick.ask;
         minute_.lowest_price = hour_.lowest_price > hour_.actual_price ? hour_.actual_price : hour_.lowest_price;
         minute_.highest_price = hour_.highest_price < hour_.actual_price ? hour_.actual_price : hour_.highest_price;
      }                
      
      // Slice action || TP / SL
      if ( !is_position_opened ) {
         if ( 
            !minute_.is_warned && 
            (
               current_time_structure.day_of_week != 5 ||
               ( current_time_structure.day_of_week == 5 && current_time_structure.hour < 20 )
            )
         ) {
            if ( minute_.opening_price > minute_.actual_price ) { // Sell
               if ( 
                  hour_.is_in_direction( "sell" ) &&
                  minute_.opening_price - minute_.actual_price >= instrument_.opm
               ) {                  
                  order_request.action = TRADE_ACTION_DEAL; 
                  order_request.magic = 1;
                  order_request.order = NULL;
                  order_request.type = ORDER_TYPE_SELL;
                  order_request.symbol = Symbol();
                  order_request.volume = 10;
                  order_request.price = minute_.actual_price;
                  order_request.stoplimit = NULL;
                  order_request.sl = NULL;
                  order_request.tp = NULL;
                  order_request.deviation = NULL;                                                                                                                 
                  
                  // Open Position: SELL     
                  bool is_opened_order = OrderSend( order_request, order_result );                  
                  is_position_opened = is_opened_order ? true : false;             
                  position_type = is_position_opened ? "sell" : "";     
                  position_opening_price = is_position_opened ? minute_.actual_price : 0;              
               }  
            } else if ( minute_.opening_price < minute_.actual_price ) { // Buy
               if ( 
                  hour_.is_in_direction( "buy" ) &&
                  minute_.actual_price - minute_.opening_price >= instrument_.opm
               ) {                                    
                  order_request.action = TRADE_ACTION_DEAL; 
                  order_request.magic = 1;
                  order_request.order = NULL;
                  order_request.type = ORDER_TYPE_BUY;
                  order_request.symbol = Symbol();
                  order_request.volume = 10;
                  order_request.price = minute_.actual_price;
                  order_request.stoplimit = NULL;
                  order_request.sl = NULL;
                  order_request.tp = NULL;
                  order_request.deviation = NULL;                                                                                                                  
                  
                  // Open Position: BUY 
                  bool is_opened_order = OrderSend( order_request, order_result );        
                  is_position_opened = is_opened_order ? true : false;             
                  position_type = is_position_opened ? "buy" : "";          
                  position_opening_price = is_position_opened ? minute_.actual_price : 0;                                      
               }  
            }
         }
      } else { // Position was opened already
         
         // Check if position is positive or not
         double position_ = PositionGetDouble( POSITION_PRICE_CURRENT );
         if ( position_ > 0 ) { // Position is winning - TP
            if ( position_type == "sell" ) {
               if ( minute_.actual_price - minute_.lowest_price >= instrument_.tpm ) {
                  ulong  position_ticket = PositionGetTicket( 0 );                                      // ticket of the position
                  string position_symbol = PositionGetString( POSITION_SYMBOL) ;                        // symbol 
                  int    digits = (int)SymbolInfoInteger( position_symbol, SYMBOL_DIGITS );              // number of decimal places
                  ulong  magic = NULL;
                  double volume = PositionGetDouble( POSITION_VOLUME );                                 // volume of the position
                  ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger( POSITION_TYPE );    // type of the position
                  //--- zeroing the request and result values
                  ZeroMemory( order_request );
                  ZeroMemory( order_result );
                     //--- setting the operation parameters
                  order_request.action   =TRADE_ACTION_DEAL;        // type of trade operation
                  order_request.position =position_ticket;          // ticket of the position
                  order_request.symbol   = position_symbol;          // symbol 
                  order_request.volume   =volume;                   // volume of the position     
                  order_request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
                        order_request.type =ORDER_TYPE_BUY;                                                       
                     bool is_closed_order = OrderSend(order_request,order_result);
             
               }
            } else if ( position_type == "buy" ) {
               if ( minute_.highest_price - minute_.actual_price >= instrument_.tpm ) {
                  ulong  position_ticket = PositionGetTicket( 0 );                                      // ticket of the position
                  string position_symbol = PositionGetString( POSITION_SYMBOL) ;                        // symbol 
                  int    digits = (int)SymbolInfoInteger( position_symbol, SYMBOL_DIGITS );              // number of decimal places
                  ulong  magic = NULL;
                  double volume = PositionGetDouble( POSITION_VOLUME );                                 // volume of the position
                  ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger( POSITION_TYPE );    // type of the position
                  //--- zeroing the request and result values
                  ZeroMemory( order_request );
                  ZeroMemory( order_result );
                     //--- setting the operation parameters
                  order_request.action   =TRADE_ACTION_DEAL;        // type of trade operation
                  order_request.position =position_ticket;          // ticket of the position
                  order_request.symbol   = position_symbol;          // symbol 
                  order_request.volume   =volume;                   // volume of the position     
                  order_request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
                        order_request.type =ORDER_TYPE_SELL;                                                       
                     bool is_closed_order = OrderSend(order_request,order_result);
               }
            }
         } else { // Position is losing - SL
         
         }
         
      } 
   }
}
//+------------------------------------------------------------------+
