/*
 * --- SEAT GUESTs
 */

seat_guest(GuestId, TP, seat(GuestId, TableId, SeatId)):- respect_specific_table(GuestId, TableId),
                                                          respect_next_to(GuestId, TableId, SeatId, TP),
                                                          respect_same_table(GuestId, TableId, TP),
                                                          respect_exclusive_table(GuestId, TableId, TP),
                                                          free_seat(TableId, SeatId, TP),
                                                          % Can only check for enable_some_rule once we're sure TableId and SeatId are defined.
                                                          respect_not_next_to(GuestId, TableId, SeatId, TP),
                                                          respect_different_table(GuestId, TableId, TP),
                                                          enable_other_next_to(GuestId, TableId, SeatId, TP). 

seat_guests([], TPSoFar, TPSoFar).
seat_guests([GH | GT], TPSoFar, TP):- seat_guest(GH, TPSoFar, Seat), 
                                      %print_seat(Seat),
                                      print_short_table_plan([Seat | TPSoFar]),
                                      seat_guests(GT, [Seat | TPSoFar], TP).

seat_guests(Guests, TP):- tell('logs.txt'), 
                          sort_guests(Guests, SortedGuests), 
                          seat_guests(SortedGuests, [], TP), 
                          told.
