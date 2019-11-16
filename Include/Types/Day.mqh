class DAY {
   public:      
   int key;
   datetime yesterday_date;
   double yesterday_opening;
   double yesterday_closing;
   double yesterday_highest;
   double yesterday_lowest;
   string yesterday_direction;
   int q_key;
   int hour_key;

   DAY() {      
      // Reset Day
      this.reset();
   }

   void reset() {
      MqlDateTime time_structure;
      datetime time = TimeTradeServer();
      TimeToStruct( time, time_structure );
      
      this.key = time_structure.year + time_structure.mon + time_structure.day;
      this.set_yesterday_market_info();
      this.q_key = calendar_.determine_q();
      this.key = time_structure.hour;

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