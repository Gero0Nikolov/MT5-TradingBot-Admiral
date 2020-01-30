class VIRTUAL_LIBRARY {
    public:
    VIRTUAL_POSITION vp_[];

    VIRTUAL_LIBRARY() {
        ArrayFree( this.vp_ );
    }

    void print_library_size() {
        Print( "VL Size: "+ ArraySize( this.vp_ ) );
    }

    void print_library() {
        int count_vl = ArraySize( this.vp_ );

        for ( int count_vp = 0; count_vp < count_vl; count_vp++ ) {
            Print( "Position #"+ count_vp +" Success: "+ this.vp_[ count_vp ].success );
        }
    }
};