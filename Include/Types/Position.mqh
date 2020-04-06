class POSITION {
   public:
   int id;
   int curve;
   string type;
   bool is_opened;
   bool select;
   bool picked;
   bool success;
   double opening_price;
   double closing_price;
   double volume;
   double profit;
   double spread;
   double margin_level;
   double tp_price;
   double sl_price;

   POSITION_DATA data_1m;
   POSITION_DATA data_5m;
   POSITION_DATA data_15m;
   POSITION_DATA data_30m;
   POSITION_DATA data_1h;

   POSITION() {
      this.id = 0;
      this.curve = 0;
      this.is_opened = false;
      this.select = false;
      this.picked = false;
      this.success = false;
      this.opening_price = 0;
      this.closing_price = 0;
      this.volume = 0;
      this.profit = 0;
      this.spread = 0;
      this.margin_level = 0;
      this.tp_price = 0;
      this.sl_price = 0;
   }

   void reset() {
      this.id += 1;
      this.curve = 0;
      this.select = false;
      this.picked = false;
      this.success = false;
      this.is_opened = false;
      this.opening_price = 0;
      this.closing_price = 0;
      this.volume = 0;
      this.profit = 0;
      this.spread = 0;      
      this.margin_level = 0;
      this.tp_price = 0;
      this.sl_price = 0;
      
      // Reset Position Data
      this.data_1m.reset();
      this.data_5m.reset();
      this.data_15m.reset();
      this.data_30m.reset();
      this.data_1h.reset();
   }

   bool should_open( int type ) {
      bool flag = false;

      if ( aggregator_.should_open( type ) ) {
         flag = true;
      }

      return flag;
   }

   bool should_close() {
      return aggregator_.should_close( this.type == "sell" ? -1 : 1, this.opening_price, this.tp_price, this.sl_price ) || this.margin_level <= account_.margin_call;
   }

   void calculate_margin_level() {
      this.margin_level = AccountInfoDouble( ACCOUNT_MARGIN_LEVEL );
   }

   string serialize() {
      string serial = 
         this.id +","+
         this.curve +","+
         this.type +","+
         this.is_opened +","+
         this.select +","+
         this.picked +","+
         this.success +","+
         this.opening_price +","+
         this.closing_price +","+
         this.volume +","+
         this.profit +","+
         this.spread +","+
         this.margin_level +","+
         this.data_1m.serialize() +","+
         this.data_5m.serialize() +","+
         this.data_15m.serialize() +","+
         this.data_30m.serialize() +","+
         this.data_1h.serialize()
      ;

      return serial;
   }

   void deserialize( string serial ) {
      string item_[];
      bool split_result = StringSplit( serial, StringGetCharacter( ",", 0 ), item_ );

      if ( split_result ) {
         this.id = item_[ 0 ];
         this.curve = item_[ 1 ];
         this.type = item_[ 2 ];
         this.is_opened = item_[ 3 ] == "true" ? true : false;
         this.select = item_[ 4 ] == "true" ? true : false;
         this.picked = item_[ 5 ] == "true" ? true : false;
         this.success = item_[ 6 ] == "true" ? true : false;
         this.opening_price = item_[ 7 ];
         this.closing_price = item_[ 8 ];
         this.volume = item_[ 9 ];
         this.profit = item_[ 10 ];
         this.spread = item_[ 11 ];
         this.margin_level = item_[ 12 ];
         this.data_1m.deserialize( item_[ 13 ] +","+ item_[ 14 ] +","+ item_[ 15 ] +","+ item_[ 16 ] );
         this.data_5m.deserialize( item_[ 17 ] +","+ item_[ 18 ] +","+ item_[ 19 ] +","+ item_[ 20 ] );
         this.data_15m.deserialize( item_[ 21 ] +","+ item_[ 22 ] +","+ item_[ 23 ] +","+ item_[ 24 ] );
         this.data_30m.deserialize( item_[ 25 ] +","+ item_[ 26 ] +","+ item_[ 27 ] +","+ item_[ 28 ] );
         this.data_1h.deserialize( item_[ 29 ] +","+ item_[ 30 ] +","+ item_[ 31 ] +","+ item_[ 32 ] );
      }
   }
};