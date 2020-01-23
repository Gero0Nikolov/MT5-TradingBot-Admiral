// bool should_open_virtual_positions( int type ) {
//     bool flag = false;

//     if ( type == -1 ) { // Sell
//         if (
//             hour_.is_in_direction( "sell" ) &&
//             !hour_.is_big() &&
//             trend_.rsi > 30 &&
//             trend_.bulls_power < 0 &&            
//             minute_.opening_price - minute_.actual_price >= instrument_.opm
//         ) { 
//             if ( !in_library( -1 ) ) {
//                 flag = true;
//             }
//         }
//     } else if ( type == 1 ) {
//         if (
//             hour_.is_in_direction( "buy" ) &&
//             !hour_.is_big() &&
//             trend_.rsi < 70 &&
//             trend_.bulls_power > 0 &&
//             minute_.actual_price - minute_.opening_price >= instrument_.opm
//         ) { 
//             if ( !in_library( 1 ) ) {
//                 flag = true;
//             }
//         }
//     }

//     return flag;
// }