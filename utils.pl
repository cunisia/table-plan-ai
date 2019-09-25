/*
 * --- UTILs
 */

smaller_seat(seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)):- not(var(TableId1)), 
                                                                      not(var(SeatId1)), 
                                                                      ((var(TableId2), !) ; var(SeatId2)).
smaller_seat(seat(_, TableId1, _), seat(_, TableId2, _)):- not(var(TableId1)), 
                                                           not(var(TableId2)), 
                                                           TableId1 @< TableId2, !. %@< is to compare strings
smaller_seat(seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)):- not(var(TableId1)), 
                                                                      not(var(TableId2)), 
                                                                      not(var(SeatId1)), 
                                                                      not(var(SeatId2)),
                                                                      TableId1 = TableId2, 
                                                                      SeatId1 < SeatId2. %@< is to compare strings

beg_smallest_seat([H|[]], [H]):- !.
beg_smallest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_smallest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
                                                          (
                                                               (
                                                                   smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !,
                                                                   L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
                                                               );
                                                               (
                                                                   smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
                                                                 L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
                                                            );
                                                               (
                                                                   L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]] % if non is smaller respect procided order
                                                                )
                                                           ).

beg_biggest_seat([H|[]], [H]):- !.
beg_biggest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_biggest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
                                                          (
                                                               (
                                                                   smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !,
                                                                 L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
                                                               );
                                                               (
                                                                   smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
                                                                   L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
                                                             );
                                                               (
                                                                   L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]] % if non is smaller respect procided order
                                                                )
                                                           ).

sort_guests_seat([H|[]], [H|[]]):- !.
sort_guests_seat(Seats, [SmallestSeat | Ordered_Seats]):- beg_smallest_seat(Seats, [SmallestSeat| T]), sort_guests_seat(T,  Ordered_Seats).

find_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)).
find_guest_seat(GuestId, [seat(GuestId2, _, _) | T], Seat):- not(GuestId = GuestId2), 
                                                            find_guest_seat(GuestId, T, Seat).

find_guests_seat([GuestId | Guests], TP, Seats):- find_guest_seat(GuestId, TP, Seat), !, find_guests_seat(Guests, TP, Seats2), Seats = [Seat | Seats2].
find_guests_seat([_ | Guests], TP, Seats):- find_guests_seat(Guests, TP, Seats), !.
find_guests_seat([], _, []).

get_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)):- !.
get_guest_seat(GuestId, [_|T], Seat):- get_guest_seat(GuestId, T, Seat).

next_seat_id(TableId, SeatId, NextSeatId):- table(TableId, Size), NextSeatId is SeatId + 1, NextSeatId =< Size, !.
next_seat_id(_, _, NextSeatId):- NextSeatId is 0.

previous_seat_id(_, SeatId, PreviousSeatId):- PreviousSeatId is SeatId - 1, PreviousSeatId > 0, !.
previous_seat_id(TableId, _, PreviousSeatId):- table(TableId, Size), PreviousSeatId is Size.

follow_each_other(S1, S2):- beg_smallest_seat([S1, S2], [seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)]),
                            TableId1 = TableId2, 
                            next_seat_id(TableId1, SeatId1, NextSeatId),
                            NextSeatId = SeatId2.