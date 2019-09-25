/*
 * --- ENABLE OTHER NEXT TO: Make sure this seat won't prevent other next tos.
 */

get_other_next_to_conditions(GuestId, OtherNextTo):- findall(NextTo, (next_to(NextTo), not(member(GuestId, NextTo))), OtherNextTo).

nb_appended_free_seats_right(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- next_seat_id(TableId, SeatId, NextSeatId), 
                                                                                     free_seat(TableId, NextSeatId, TP), !,
                                                                                     NewSoFar is SoFar + 1,
                                                                                     nb_appended_free_seats_right(TP, seat("", TableId, NextSeatId), NewSoFar, NbAppendedFreeSeats).

nb_appended_free_seats_right(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- next_seat_id(TableId, SeatId, NextSeatId), 
                                                                                     not(free_seat(TableId, NextSeatId, TP)), 
                                                                                     NbAppendedFreeSeats is SoFar, !.

nb_appended_free_seats_right(TP, Seat, NbAppendedFreeSeats):- nb_appended_free_seats_right(TP, Seat, 0, NbAppendedFreeSeats).


nb_appended_free_seats_left(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- previous_seat_id(TableId, SeatId, PreviousSeatId), 
                                                                                     free_seat(TableId, PreviousSeatId, TP), !,
                                                                                     NewSoFar is SoFar + 1,
                                                                                     nb_appended_free_seats_left(TP, seat("", TableId, PreviousSeatId), NewSoFar, NbAppendedFreeSeats).

nb_appended_free_seats_left(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- previous_seat_id(TableId, SeatId, PreviousSeatId), 
                                                                                     not(free_seat(TableId, PreviousSeatId, TP)), 
                                                                                     NbAppendedFreeSeats is SoFar, !.

nb_appended_free_seats_left(TP, Seat, NbAppendedFreeSeats):- nb_appended_free_seats_left(TP, Seat, 0, NbAppendedFreeSeats). 

enough_appended_free_seats(TP, Seats, NbNonSeated):- beg_biggest_seat(Seats, [Seat | _]), nb_appended_free_seats_right(TP, Seat, Nb), Nb >= NbNonSeated, !.
enough_appended_free_seats(TP, Seats, NbNonSeated):- beg_smallest_seat(Seats, [Seat | _]), nb_appended_free_seats_left(TP, Seat, Nb), Nb >= NbNonSeated.

enable_next_to_condition(_, _, _, _, _, []):- !.
enable_next_to_condition(_, TableId, _, _, _, [seat(_, TableId2, _)]):- TableId \= TableId2, !.
enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition, Seats):- length(Seats, NbSeated),
                                                                                 length(NextToCondition, L), 
                                                                                 NbNonSeated is L - NbSeated,
                                                                                 enough_appended_free_seats([seat(GuestId, TableId, SeatId) | TP], Seats, NbNonSeated).

enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition):- find_guests_seat(NextToCondition, TP, Seats),
                                                                          enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition, Seats).

enable_other_next_to(_, _, _, _, []).
enable_other_next_to(GuestId, TableId, SeatId, TP, [NextToCondition | OtherNextTo]):- enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition),
                                                                                      enable_other_next_to(GuestId, TableId, SeatId, TP, OtherNextTo).

enable_other_next_to(GuestId, TableId, SeatId, TP):- get_other_next_to_conditions(GuestId, OtherNextTo),
                                                     enable_other_next_to(GuestId, TableId, SeatId, TP, OtherNextTo).