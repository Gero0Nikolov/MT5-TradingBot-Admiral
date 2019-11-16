class Q_TYPE {
   public:
   datetime start;
   datetime end;
   double highest_price;
   double lowest_price;

   Q_TYPE() {
      this.start = TimeCurrent();
      this.end = TimeCurrent();      
      this.highest_price = 0;
      this.lowest_price = 0;
   }
};