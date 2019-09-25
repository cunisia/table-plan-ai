/*
 * --- DIFFERENT TABLE
 */

get_different_table_condition_by_guest(GuestId, DifferentTable):- findall(Guests, (different_table(Guests), member(GuestId, Guests)), DifferentTable).

belong_to_different_table(_, []):-!.
belong_to_different_table(seat(GuestId1, TableId1, _), [seat(_, TableId2, _) | Seats]):- TableId1 \= TableId2, !, 
                                                                                         belong_to_different_table(seat(GuestId1, TableId1, _), Seats).
belong_to_different_table(seat(GuestId1, TableId1, _), [seat(GuestId2, _, _) | Seats]):- GuestId1 = GuestId2, !, 
                                                                                         belong_to_different_table(seat(GuestId1, TableId1, _), Seats).

respect_different_table(_, _, _, []):-!. 
respect_different_table(GuestId, TableId, TP, [DifferentTable_H |DifferentTable_T]):- find_guests_seat(DifferentTable_H, TP, Seats),
                                                                                       belong_to_different_table(seat(GuestId, TableId, nil), Seats),
                                                                                       respect_different_table(GuestId, TableId, TP, DifferentTable_T). 

respect_different_table(_, _, []):-!.
respect_different_table(GuestId, TableId, TP):- get_different_table_condition_by_guest(GuestId, DifferentTable),
                                               respect_different_table(GuestId, TableId, TP, DifferentTable).