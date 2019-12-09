bool is_friday_ending() {
    bool flag = false;
    datetime time;
    MqlDateTime time_struct;
    
    time = TimeGMT();
    if ( TimeToStruct( time, time_struct ) ) { flag = time_struct.hour >= 22 && time_struct.day_of_week == 5 ? true : false; }

    return flag;
}