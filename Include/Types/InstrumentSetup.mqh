class INSTRUMENT_SETUP {
   public:
   string name;
   double spread;
   int opm;
   int tpm;
   int slm;
   int tpi;

   INSTRUMENT_SETUP() {
      this.name = "NQ100";
      this.spread = 0;
      this.opm = 10;
      this.tpm = 3;
      this.slm = 10;
      this.tpi = 5;
   }
};