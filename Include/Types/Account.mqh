class ACCOUNT {
   public:
   string currency;
   string broker;
   double currency_exchange_rate;
   double trading_percent;
   double initial_deposit;
   double withdraw_percentage;
   int ping_counter;
   int leverage;

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

      // Set account levarage
      this.leverage = AccountInfoInteger( ACCOUNT_LEVERAGE ) > 20 ? 20 : AccountInfoInteger( ACCOUNT_LEVERAGE );
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

   void open_position_notification( string type, double price, double volume ) {
      // Info Data
      double balance = AccountInfoDouble( ACCOUNT_BALANCE );
      string position_info = position_.is_opened ? "&account_balance="+ balance : "";

      string cookie = NULL, headers;
      char post[], result[];
      string api_key = IntegerToString( AccountInfoInteger( ACCOUNT_LOGIN ) );
      string data = "action=mt5_opn&api_key="+ api_key +"&type="+ type +"&price="+ price +"&volume="+ volume + position_info;
      StringToCharArray( data, post );
      string url = "https://geronikolov.com/wp-admin/admin-ajax.php";

      ResetLastError();

      int res = WebRequest( "POST", url, cookie, NULL, 500, post, ArraySize( post ), result, headers );

      if ( res == -1 ) { Print( "Error in WebRequest. Error code: ", GetLastError() ); }
      else if ( res == 200 ) { /* NOTIFICATION WAS SENT! */ }
   }

   void closed_position_notification( bool is_sl ) {
      // Info Data
      double balance = AccountInfoDouble( ACCOUNT_BALANCE );
      string position_info = position_.is_opened ? "&position_profit="+ position_.profit +"&account_balance="+ balance : "";

      // Request Structure
      string cookie = NULL, headers;
      char post[], result[];
      string api_key = IntegerToString( AccountInfoInteger( ACCOUNT_LOGIN ) );
      string data = "action=mt5_cpn&api_key="+ api_key +"&is_sl="+ is_sl + position_info;
      StringToCharArray( data, post );
      string url = "https://geronikolov.com/wp-admin/admin-ajax.php";

      ResetLastError();

      int res = WebRequest( "POST", url, cookie, NULL, 500, post, ArraySize( post ), result, headers );

      if ( res == -1 ) { Print( "Error in WebRequest. Error code: ", GetLastError() ); }
      else if ( res == 200 ) { /* NOTIFICATION WAS SENT! */ }
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
      // Info Data
      double balance = AccountInfoDouble( ACCOUNT_BALANCE );
      string position_info = position_.is_opened ? "&position_profit="+ position_.profit : "";
      string api_key = IntegerToString( AccountInfoInteger( ACCOUNT_LOGIN ) );

      // Request Structure
      string cookie = NULL, headers;
      char post[], result[];      
      string data = "action=mt5_ping&api_key="+ api_key +"&broker="+ this.broker +"&balance="+ balance + position_info;
      StringToCharArray( data, post );
      string url = "https://geronikolov.com/wp-admin/admin-ajax.php";

      ResetLastError();

      int res = WebRequest( "POST", url, cookie, NULL, 500, post, ArraySize( post ), result, headers );

      if ( res == -1 ) { Print( "Error in WebRequest. Error code: ", GetLastError() ); }
      else if ( res == 200 ) { /* SERVER WAS PINGED */ }
   }
};