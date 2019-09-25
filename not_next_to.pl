/*
 * --- SEAT NOT NEXT TO 
 */

get_not_next_to_conditions_by_guest(GuestId, AllNotNextTo):- findall(NotNextTo, (not_next_to(NotNextTo), member(GuestId, NotNextTo)), AllNotNextTo).

not_next_to_seats(_, []):- !.
not_next_to_seats(Seat, [Seat_H | Seats_T]):- not(follow_each_other(Seat_H, Seat)), not_next_to_seats(Seat, Seats_T).

respect_not_next_to(_, _, _, _, []):- !.
respect_not_next_to(GuestId, TableId, SeatId, TP, [AllNotNextTo_H | AllNotNextTo_T]):- find_guests_seat(AllNotNextTo_H, TP, Seats),
                                                                                       not_next_to_seats(seat(GuestId, TableId, SeatId), Seats), 
                                                                                       respect_not_next_to(GuestId, TableId, SeatId, TP, AllNotNextTo_T).

respect_not_next_to(_, _, _, []):- !.
respect_not_next_to(GuestId, TableId, SeatId, TP):- get_not_next_to_conditions_by_guest(GuestId, AllNotNextTo), 
                                                    respect_not_next_to(GuestId, TableId, SeatId, TP, AllNotNextTo).