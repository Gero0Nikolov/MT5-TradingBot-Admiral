class POSITION {
   public:
   int id;
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

   POSITION_DATA data_1m;
   POSITION_DATA data_5m;
   POSITION_DATA data_15m;
   POSITION_DATA data_30m;
   POSITION_DATA data_1h;

   POSITION() {
      this.id = 0;
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
   }

   void reset() {
      this.id += 1;
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
      
      // Reset Position Data
      this.data_1m.reset();
      this.data_15m.reset();
      this.data_30m.reset();
      this.data_1h.reset();
   }

   bool should_open( int type ) {
      bool flag = false;

      if ( 
         aggregator_.should_open( type ) &&
         this.is_known_as_good( type )
      ) {
         flag = true;
      }

      return flag;
   }

   bool should_close() {
      return aggregator_.should_close( this.type == "sell" ? -1 : 1 ) || this.margin_level <= account_.margin_call;
   }

   void calculate_margin_level() {
      this.margin_level = AccountInfoDouble( ACCOUNT_MARGIN_LEVEL );
   }

   bool is_known_as_good( int type ) {
      bool flag = false;
      POSITION position_;

      // Copy Current Trend Data
      position_.data_1m.copy_trend( trend_1m );
      position_.data_5m.copy_trend( trend_5m );
      position_.data_15m.copy_trend( trend_15m );
      position_.data_30m.copy_trend( trend_30m );
      position_.data_1h.copy_trend( trend_1h );

      // Check if the desired New Position is exists in the Virtual Library (VL)
      int vp_key = vl_.find_from_position( position_ );

      if ( vp_key > -1 ) {
         flag = vl_.vp_[ vp_key ].success;
      }

      return flag;
   }

   string serialize() {
      string serial = 
         this.id +","+
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
         this.type = item_[ 1 ];
         this.is_opened = item_[ 2 ] == "true" ? true : false;
         this.select = item_[ 3 ] == "true" ? true : false;
         this.picked = item_[ 4 ] == "true" ? true : false;
         this.success = item_[ 5 ] == "true" ? true : false;
         this.opening_price = item_[ 6 ];
         this.closing_price = item_[ 7 ];
         this.volume = item_[ 8 ];
         this.profit = item_[ 9 ];
         this.spread = item_[ 10 ];
         this.margin_level = item_[ 11 ];
         this.data_1m.deserialize( item_[ 12 ] +","+ item_[ 13 ] +","+ item_[ 14 ] +","+ item_[ 15 ] );
         this.data_5m.deserialize( item_[ 16 ] +","+ item_[ 17 ] +","+ item_[ 18 ] +","+ item_[ 19 ] );
         this.data_15m.deserialize( item_[ 20 ] +","+ item_[ 21 ] +","+ item_[ 22 ] +","+ item_[ 23 ] );
         this.data_30m.deserialize( item_[ 24 ] +","+ item_[ 25 ] +","+ item_[ 26 ] +","+ item_[ 27 ] );
         this.data_1h.deserialize( item_[ 28 ] +","+ item_[ 29 ] +","+ item_[ 30 ] +","+ item_[ 31 ] );
      }
   }
};