#!/usr/bin/env escript

main([]) -> io:format("Usage: group-cells.erl <filename.csv>\n");
main([Filename]) ->
    [Headers|Rows] = [
            string:tokens(Line, ", ")
            || Line <- string:tokens(binary_to_list(element(2,
                                     file:read_file(Filename))), "\r\n") ],

    case [ CandidateArrangement
            || CandidateArrangement <- perms(Rows),
            satisfies_adjacency(CandidateArrangement) ] of
        [] -> io:format("FAIL: There is no satisfying arrangement.~n");
        [SatisfyingRows|_Rest] ->
            io:format("~s~n~s~n", [
                string:join(Headers, ","),
                string:join(
                    [string:join(Row, ",")
                     || Row <- SatisfyingRows]
                    , "\n")
                ]
            )
    end.

% Checks whether given arrangement of rows is satisfying the requirement
% on column cells adjacency.
satisfies_adjacency(RandomizedRows) ->
    lists:all(fun(Column) -> grouped(Column) end,
              tl(transpose(RandomizedRows))).

% Checks whether the same items in the given list are adjacent to each other.
grouped([_]) -> true;
grouped([A,A|Rest]) -> grouped([A|Rest]);
grouped([A|Rest]) ->
    case lists:member(A, Rest) of
        false -> grouped(Rest);
        true -> false
    end.

% Swaps rows and columns: the first column becomes the first row, etc.
transpose([]) -> [];
transpose([[]|XSS]) -> transpose(XSS);
transpose([[X|XS]|XSS]) ->
    [[X|[H||[H|_]<-XSS]] | transpose([XS|[T||[_|T]<-XSS]])].

% Generate all permutations of a given list.
perms([]) -> [[]];
perms(L)  -> [[H|T] || H <- L, T <- perms(L--[H])].
