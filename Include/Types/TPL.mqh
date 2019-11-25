/*
*   Name: TPL
*   Description: TPL is abriviation for Take Profit Levels
*   Usage: Used to determine if the price is going to hit the 100% profit = INSTRUMENT_SETUP.TPM or the TPM should be transformed to the last passed TPL.
*/
class TPL {
    public:
    int level; // The price difference in % from the INSTRUMENT_SETUP.TPM;
    double price; // The actual price calculated with the % from the INSTRUMENT_SETUP.TPM;
    double difference; // The price difference in money;
    bool is_passed;

    TPL() {
        this.level = 0;
        this.price = 0;
        this.difference = 0;
        this.is_passed = false;
    }
};