class INSTRUMENT_SETUP {
   public:
   string name;
   double opm; // Opening Position Movement
   double tpm; // Take Profit Movement
   double slm; // Stop Loss Movement   
   double tp_listener;
   double spread;
   
   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.opm = 10;
      this.tpm = 0.23;
      this.slm = 1;
      this.tp_listener = 0;
      this.spread = 0;
   }
};