class INSTRUMENT_SETUP {
   public:
   string name;
   double opm; // Opening Position Movement
   double tpm; // Take Profit Movement
   double slm; // Stop Loss Movement   
   
   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.opm = 10;
      this.tpm = 0.66;
      this.slm = 1;      
   }
};