/*
 *  --- HAVE EXCLUSIVE TABLE: Make sure a guest have an exclusive table (if he needs to) and does not seat at the same table as guests from different exclusive table sets.
 */

get_exclusive_table_condition_by_guest(GuestId, AllExclusiveTable):- findall(ExclusiveTable, (exclusive_table(ExclusiveTable), member(GuestId, ExclusiveTable)), AllExclusiveTable).
get_all_other_exclusive_table_condition(GuestId, OtherExclusiveTable):- findall(ExclusiveTable, (exclusive_table(ExclusiveTable), not(member(GuestId, ExclusiveTable))), OtherExclusiveTable).

seats_not_at_table([], _):- !.
seats_not_at_table([seat(_, TableId1, _) | T], TableId2):- TableId1 \= TableId2, seats_not_at_table(T, TableId2).

respect_other_exclusive_table(_, _, _, []):- !.
respect_other_exclusive_table(GuestId, TableId, TP, [ExclusiveTableHead | ExclusiveTableTail]):- table(TableId, _),
                                                                                                 find_guests_seat(ExclusiveTableHead, TP, Seats),
                                                                                                 seats_not_at_table(Seats, TableId), 
                                                                                                 respect_other_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail). 

nb_guests_at_table(_, [], 0):- !.
nb_guests_at_table(TableId, [seat(_, TableId2, _) | T], NB):- TableId2 = TableId, !, nb_guests_at_table(TableId, T, NB2), NB is NB2 + 1.
nb_guests_at_table(TableId, [_ | T], NB):- nb_guests_at_table(TableId, T, NB).

respect_exclusive_table(_, _, _, []):- !.
respect_exclusive_table(GuestId, TableId, TP, [ExclusiveTableHead | ExclusiveTableTail]):- find_guests_seat(ExclusiveTableHead, TP, [H|T]), !,
                                                                                            belong_to_same_table([seat(GuestId, TableId, nil) | [H|T]]),
                                                                                            respect_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail).
respect_exclusive_table(GuestId, TableId, TP, [_ | ExclusiveTableTail]):- table(TableId, _), 
                                                                          nb_guests_at_table(TableId, TP, 0),
                                                                          respect_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail).

respect_exclusive_table(_, _, []):- !.
respect_exclusive_table(GuestId, TableId, TP):- get_exclusive_table_condition_by_guest(GuestId, ExclusiveTable), 
                                                respect_exclusive_table(GuestId, TableId, TP, ExclusiveTable),
                                                get_all_other_exclusive_table_condition(GuestId, OtherExclusiveTable), 
                                                respect_other_exclusive_table(GuestId, TableId, TP, OtherExclusiveTable).