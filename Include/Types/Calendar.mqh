class CALENDAR {
   public:
   string country_code;
   MqlCalendarValue values[];
   bool got_values;
   MqlCalendarValue risk_values[];
   int year;

   CALENDAR( string alpha_2_code ) {
      this.country_code = alpha_2_code;
      this.got_values = false;
      
      // Set Ques
      this.set_qs();
   }

   void set_qs() {
      MqlDateTime time_structure;
      datetime server_time = TimeTradeServer();
      TimeToStruct( server_time, time_structure );

      // Set the current year
      this.year = time_structure.year;

      // Set Qs for the year
      for ( int count_qs = 0; count_qs < ArraySize( qs_ ); count_qs++ ) {
         if ( count_qs == 0 ) { // Q1
            // Set Start            
            time_structure.mon = 1;
            time_structure.day = 1;
            time_structure.hour = 0;
            time_structure.min = 0;
            time_structure.sec = 0;
            qs_[ count_qs ].start = StructToTime( time_structure );

            // Set End
            time_structure.mon = 3;
            time_structure.day = 31;
            time_structure.hour = 23;
            time_structure.min = 59;
            time_structure.sec = 59;
            qs_[ count_qs ].end = StructToTime( time_structure );
         } else if ( count_qs == 1 ) { // Q2
            // Set Start            
            time_structure.mon = 4;
            time_structure.day = 1;
            time_structure.hour = 0;
            time_structure.min = 0;
            time_structure.sec = 0;
            qs_[ count_qs ].start = StructToTime( time_structure );

            // Set End
            time_structure.mon = 6;
            time_structure.day = 30;
            time_structure.hour = 23;
            time_structure.min = 59;
            time_structure.sec = 59;
            qs_[ count_qs ].end = StructToTime( time_structure );
         } else if ( count_qs == 2 ) { // Q3
            // Set Start            
            time_structure.mon = 7;
            time_structure.day = 1;
            time_structure.hour = 0;
            time_structure.min = 0;
            time_structure.sec = 0;
            qs_[ count_qs ].start = StructToTime( time_structure );

            // Set End
            time_structure.mon = 9;
            time_structure.day = 30;
            time_structure.hour = 23;
            time_structure.min = 59;
            time_structure.sec = 59;
            qs_[ count_qs ].end = StructToTime( time_structure );
         } else if ( count_qs == 3 ) { // Q4
            // Set Start
            time_structure.mon = 10;
            time_structure.day = 1;
            time_structure.hour = 0;
            time_structure.min = 0;
            time_structure.sec = 0;
            qs_[ count_qs ].start = StructToTime( time_structure );

            // Set End
            time_structure.mon = 12;
            time_structure.day = 31;
            time_structure.hour = 23;
            time_structure.min = 59;
            time_structure.sec = 59;
            qs_[ count_qs ].end = StructToTime( time_structure );
         }
      }
   }

   int determine_q() {
      datetime current_time = TimeTradeServer();
      int q_key = 0;
      
      for ( int count_qs = 0; count_qs < ArraySize( qs_ ); count_qs++ ) {
         if ( 
            current_time >= qs_[ count_qs ].start &&
            current_time <= qs_[ count_qs ].end
         ) {
            q_key = count_qs;
            break;
         }
      }

      return q_key;
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