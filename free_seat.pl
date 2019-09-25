/*
 * --- FREE SEAT 
 */

% free_seat(seat(GuestId, TableId, SeatId), TablePlan): check if a seat is not already taken
free_seat(TableId, SeatId, []):- seat(TableId, SeatId), !.
free_seat(TableId, SeatId, [seat(_, TableId2, SeatId2) | T]):-  seat(TableId, SeatId),
                                                                not((TableId = TableId2, SeatId = SeatId2)), 
                                                                free_seat(TableId, SeatId, T). 