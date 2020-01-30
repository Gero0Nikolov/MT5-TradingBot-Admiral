class INSTRUMENT_SETUP {
   public:
   string name;
   double spread;
   int opm;
   double tpm;
   double slm;

   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.spread = 0;
      this.opm = 7;
      this.tpm = 0.66 / 100;
      this.slm = 1 / 100;
   }
};