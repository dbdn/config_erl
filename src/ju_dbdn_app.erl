-module(ju_dbdn_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ju_config:init(),
    ju_dbdn_sup:start_link().

stop(_State) ->
    ok.
