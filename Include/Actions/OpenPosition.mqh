void open_position( string type, double price ) {
    // Reset the Currency Exchange Rate
    account_.set_currency_exchange_rate();

    // Calculate Position Setup
    double free_margin = AccountInfoDouble( ACCOUNT_FREEMARGIN ) * account_.currency_exchange_rate;
    double volume = NormalizeDouble( ( free_margin * account_.trading_percent ) * account_.leverage / price, 1 );

    // Check if volume is above 500 and set the maximum for the Admiral Markets broker = 500
    if ( volume > 500 ) { volume = 500; }

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

    if ( order_result.retcode == instrument_.success_code ) {
        // Set the Position Data
        position_.type = type;
        position_.opening_price = price;
        position_.volume = order_result.volume; 
        position_.spread = instrument_.spread;
        position_.is_opened = true;
        position_.picked = true;
        
        // Calculate Margin Level
        position_.calculate_margin_level();

        // Copy Trend Info
        position_.data_1m.copy_trend( trend_1m );
        position_.data_5m.copy_trend( trend_5m );
        position_.data_15m.copy_trend( trend_15m );
        position_.data_30m.copy_trend( trend_30m );
        position_.data_1h.copy_trend( trend_1h );

        // Send Open Position Notification
        account_.open_position_notification( position_.type, position_.opening_price, position_.volume );
    } else {
        // Retry position opening
        open_position( type, price );
    }

    // Purge the Memory from the Order Data
    ZeroMemory( order_request );
    ZeroMemory( order_result );
}