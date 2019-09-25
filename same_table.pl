/*
 * --- SAME TABLE
 */

get_same_table_condition_by_guest(GuestId, L):- findall(LL, (same_table(LL), member(GuestId, LL)), L).

belong_to_same_table([_|[]]):- !.
belong_to_same_table([seat(_, TableId, _) | [seat(_, TableId, _) | T]]):- belong_to_same_table([seat(_, TableId, _) | T]).

respect_same_table(_, _, _, []):- !.
respect_same_table(GuestId, TableId, TP, [SameTableHead | SameTableTail]):- find_guests_seat(SameTableHead, TP, Seats),
                                                                            belong_to_same_table([seat(GuestId, TableId, nil) | Seats]),
                                                                            respect_same_table(GuestId, TableId, TP, SameTableTail).

respect_same_table(_, _, []):- !.
respect_same_table(GuestId, TableId, TP):- get_same_table_condition_by_guest(GuestId, SameTable), 
                                           respect_same_table(GuestId, TableId, TP, SameTable).