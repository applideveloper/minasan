%%
%% minasan_sup.erl
%% minasan supervisor
%%
-module(minasan_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ~~~~~~~~~~~~~
%% API functions
%% ~~~~~~~~~~~~~

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ~~~~~~~~~~~~~~~~~~~~
%% Supervisor callbacks
%% ~~~~~~~~~~~~~~~~~~~~

init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    ChildSpecs = [],

    {ok, {SupFlags, ChildSpecs}}.
