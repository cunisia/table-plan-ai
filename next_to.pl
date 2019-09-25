/*
 * --- SEAT NEXT TO 
 */

get_next_to_conditions_by_guest(GuestId, AllNextTo):- findall(NextTo, (next_to(NextTo), member(GuestId, NextTo)), AllNextTo).

% This function considers that Seats are already following each others
respect_next_to_seats(_, []):- !.
respect_next_to_seats(Seat, Seats):- beg_biggest_seat(Seats, [BiggestSeat | _]),
                                     follow_each_other(Seat, BiggestSeat), !.
respect_next_to_seats(Seat, Seats):- beg_smallest_seat(Seats, [SmallestSeat | _]),
                                     follow_each_other(Seat, SmallestSeat), !.

respect_next_to(_, _, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP, [AllNextTo_H | AllNextTo_T]):- find_guests_seat(AllNextTo_H, TP, Seats),
                                                                             respect_next_to_seats(seat(GuestId, TableId, SeatId), Seats),
                                                                             respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo_T).
respect_next_to(_, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP):- get_next_to_conditions_by_guest(GuestId, AllNextTo), 
                                                respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo).