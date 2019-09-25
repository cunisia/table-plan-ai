/*
 * --- SEAT AT SPECIFIC TABLE 
 */

get_specific_table_condictions_by_guest(GuestId, AllSpecificTable):- findall(TableId, (specific_table(Guests, TableId), member(GuestId, Guests)), AllSpecificTable).

respect_specific_table(_, _, []):- !.
respect_specific_table(GuestId, TableId, [SpecificTableId | AllSpecificTable_H]):- TableId = SpecificTableId,
                                                                                   respect_specific_table(GuestId, TableId, AllSpecificTable_H).

respect_specific_table(GuestId, TableId):- get_specific_table_condictions_by_guest(GuestId, AllSpecificTable),
                                           respect_specific_table(GuestId, TableId, AllSpecificTable).