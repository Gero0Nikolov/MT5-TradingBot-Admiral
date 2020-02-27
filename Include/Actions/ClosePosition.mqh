void close_position( string type_, bool is_sl = false ) {
    ulong  position_ticket = PositionGetTicket( 0 );                                      // ticket of the position
    string position_symbol = PositionGetString( POSITION_SYMBOL) ;                        // symbol 
    int digits = (int)SymbolInfoInteger( position_symbol, SYMBOL_DIGITS );              // number of decimal places
    ulong  magic = position_.id;
    double volume = PositionGetDouble( POSITION_VOLUME );                                 // volume of the position
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger( POSITION_TYPE );    // type of the position        
    double price = SymbolInfoDouble( position_symbol, type_ == "sell" ? SYMBOL_BID : SYMBOL_ASK );

    //--- setting the operation parameters
    order_request.action = TRADE_ACTION_DEAL;        // type of trade operation
    order_request.position = position_ticket;       // ticket of the position
    order_request.symbol = position_symbol;        // symbol 
    order_request.volume = volume;                // volume of the position     
    order_request.price = price;
    order_request.type = type_ == "buy" ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;

    bool is_closed_order = OrderSend( order_request, order_result );

    if ( order_result.retcode == instrument_.success_code ) {
        // Set Position Closing Data
        position_.closing_price = price;
        position_.success = is_sl ? false : true;

        // Perform an update to the Virtual Library (VL) from Normal Position
        vl_.update_from_position( position_ );

        // Notify the Admin the position was closed
        account_.closed_position_notification( is_sl );

        // Reset Position
        position_.reset();
    } else {
        Print( "Error in position closing! Code: "+ order_result.retcode );

        // Retry closing the position
        close_position( type_, is_sl );
    }

    // Purge the Memory from the Order Data
    ZeroMemory( order_request );
    ZeroMemory( order_result );
}