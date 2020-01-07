//+------------------------------------------------------------------+
//|                                       DAX-BOT-v1.0.0.mq5 |
//|                                                     Gero Nikolov |
//|                                          https://geronikolov.com |
//+------------------------------------------------------------------+
#property copyright "Gero Nikolov"
#property link      "https://geronikolov.com"
#property version   "1.00"

int OnInit(){
   // Set the EA Timer with period of 1 second
   EventSetTimer( 1 );

   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit( const int reason ) {
   // Destroy the EA Timer in order to clear RAM
   EventKillTimer();
}

// Expert timer function
void OnTimer() {}

// Expert tick function                                             |
void OnTick() {
   MqlTick current_tick;
   
   if ( SymbolInfoTick( Symbol(), current_tick ) ) {
       // Actual Code Here      
   }
}