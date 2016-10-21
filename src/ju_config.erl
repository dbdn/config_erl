-module(ju_config).
-author("dbdn").

-define(CONFIG_FILE, "../etc/server.config").
-define(SERVER_CONFIG_ETS, ets_server_config).

%% API
-export([init/0, fresh/0]).
-export([get/2, get2/3]).

init() ->
    ets:new(?SERVER_CONFIG_ETS, [named_table,public ,set]),
    fresh().

read_from_file(File,Ets)->
    case file:consult(File) of
        {ok, [Terms]} ->
            lists:foreach(fun(Term)->
                ets:insert(Ets, Term)
            end, Terms);
        {error, Reason} ->
            io:format("load option file [~p] Error ~p",[File,Reason]) ,
            erlang:throw({error, read_config_file})
    end.

get(Key,Default)->
    try
        case ets:lookup(?SERVER_CONFIG_ETS, Key) of
            []-> Default;
            [{_,Value}]->Value
        end
    catch
        E:R->
            io:format("ju_config:get/2 err: Key ~p R ~p  ~p ~n",[Key,R,erlang:get_stacktrace()]),
            Default
    end.

get2(Key,Key2,Default)->
    case get(Key,[]) of
        []->Default;
        Value-> case lists:keyfind(Key2, 1, Value) of
                    false-> Default;
                    {_Key2,Value2}-> Value2
                end
    end.

fresh() ->
    read_from_file(?CONFIG_FILE, ?SERVER_CONFIG_ETS).

%%%*_ TESTS ====================================================================

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

init_test() ->
    ?assertEqual(ok , init()).

get_test() ->
    ?assertEqual("notfound", get(oracle, "notfound")),
    ?assertEqual("abc123", get2(http, http_secret, "found")),
    ?assertNotEqual("abc1234", get2(http, http_secret, "found")),
    ok.

-endif.