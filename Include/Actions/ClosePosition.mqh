void close_position( string type_, bool is_sl = false ) {
    ulong  position_ticket = PositionGetTicket( 0 );                                      // ticket of the position
    string position_symbol = PositionGetString( POSITION_SYMBOL) ;                        // symbol 
    int digits = (int)SymbolInfoInteger( position_symbol, SYMBOL_DIGITS );              // number of decimal places
    ulong  magic = position_.id;
    double volume = PositionGetDouble( POSITION_VOLUME );                                 // volume of the position
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger( POSITION_TYPE );    // type of the position        

    //--- setting the operation parameters
    order_request.action = TRADE_ACTION_DEAL;        // type of trade operation
    order_request.position = position_ticket;       // ticket of the position
    order_request.symbol = position_symbol;        // symbol 
    order_request.volume = volume;                // volume of the position     
    order_request.price = SymbolInfoDouble( position_symbol, SYMBOL_ASK );
    order_request.type = type_ == "buy" ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;

    bool is_closed_order = OrderSend( order_request,order_result );    

    if ( is_closed_order ) {
        ZeroMemory( order_request );
        ZeroMemory( order_result );

        // Check if RSI & BullsPower of the Position were successful or not and add it to the library
        update_trade_library( position_.rsi, position_.bulls_power, position_.type, position_.opening_price, is_sl );

        // Notify the Admin the position was closed
        account_.closed_position_notification( is_sl );

        // Reset Position
        position_.reset();        

        // Suggest Withdraw
        //account_.suggest_withdraw();
    }
}