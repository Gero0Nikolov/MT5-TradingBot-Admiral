void open_position( string type, double price ) {
    double free_margin = AccountInfoDouble( ACCOUNT_FREEMARGIN );
    int account_leverage = AccountInfoInteger( ACCOUNT_LEVERAGE );
    double volume = NormalizeDouble( ( ( free_margin / 2 ) * account_leverage ) / price, 1 );    

    // Check if volume is above 100 and set the maximum for the Admiral Markets broker = 100
    if ( volume > 100 ) { volume = 100; }

    // Calculate Stop Loss price
    double stop_loss = 0;
    double stop_loss_difference = instrument_.slm * price;
    if ( type == "sell" ) { stop_loss = price + stop_loss_difference; }
    else if ( type == "buy" ) { stop_loss = price - stop_loss_difference; }

    // Calculate Take Profit price
    double take_profit = 0;
    double take_profit_difference = instrument_.tpm * price;
    if ( type == "sell" ) { take_profit = price - take_profit_difference; }
    else if ( type == "buy" ) { take_profit = price + take_profit_difference; }

    // Order Setup
    order_request.action = TRADE_ACTION_DEAL; 
    order_request.magic = position_.id;
    order_request.order = NULL;
    order_request.type = type == "buy" ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    order_request.symbol = Symbol();
    order_request.volume = volume;
    order_request.price = price;
    order_request.stoplimit = NULL;
    order_request.sl = NULL;
    order_request.tp = NULL;
    order_request.deviation = NULL;

    // Execute the Order
    bool is_opened_order = OrderSend( order_request, order_result );

    // If everything went smoothly proceed with Position Data setup
    if ( is_opened_order ) {
        ZeroMemory( order_request );
        ZeroMemory( order_result );

        position_.type = type;
        position_.opening_price = price;
        position_.volume = volume; 
        position_.is_opened = true;
        position_.ticket_id = PositionGetTicket( 0 );
    }
}