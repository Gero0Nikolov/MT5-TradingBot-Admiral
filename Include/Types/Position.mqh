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
};