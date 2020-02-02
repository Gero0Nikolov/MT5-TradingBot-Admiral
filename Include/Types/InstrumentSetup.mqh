class INSTRUMENT_SETUP {
   public:
   string name;
   double spread;
   double opm; // Opening Price Movememnt
   double bhs; // Big Hour Size
   double tpm; // Take Profit Movement # Not used
   double slm; // Stop Loss Movement # Not used

   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.spread = 0;
      this.opm = 7.0;
      this.bhs = 25;
      this.tpm = 0.66 / 100;
      this.slm = 1 / 100;
   }
};