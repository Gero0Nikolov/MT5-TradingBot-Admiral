class INSTRUMENT_SETUP {
   public:
   string name;
   double spread;
   int success_code;

   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.spread = 0;
      this.success_code = 10009;
   }
};