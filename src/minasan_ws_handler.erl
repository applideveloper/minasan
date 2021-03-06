-module(minasan_ws_handler).

-export([init/3
        ,websocket_init/3
        ,websocket_handle/3
        ,websocket_info/3
        ,websocket_terminate/3]).

-include("minasan.hrl").

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    S = #userinfo{login=false},
    {ok, Req, S}.

websocket_handle({text, Msg}, Req, State) when State#userinfo.login==false ->
    Login = erlang:list_to_binary(string:substr(erlang:binary_to_list(Msg), 7)),
    State1 = State#userinfo{login=Login},
    gproc:send({p, l, ?WSKey}, {self(), ?WSKey, <<Login/binary, " entered chat.">>}),
    gproc:reg({p, l, ?WSKey}),
    {reply, {text, << "Hello, ", Login/binary, "!" >>}, Req, State1};
websocket_handle({text, Msg}, Req, State) ->
    Login = State#userinfo.login,
    Msg1 = << Login/binary, ": ", Msg/binary >>,
    gproc:send({p, l, ?WSKey}, {self(), ?WSKey, Msg1}),
    {ok, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info(Info, Req, State) ->
    case Info of
        {_PID, ?WSKey, Msg} ->
            {reply, {text, Msg}, Req, State};
        _ ->
            {ok, Req, State, hibernate}
    end.

websocket_terminate(_Reason, _Req, State) ->
    Login = State#userinfo.login,
    gproc:send({p, l, ?WSKey}, {self(), ?WSKey, <<Login/binary, " left chat.">>}),
    gproc:unreg({p, l, ?WSKey}),
    ok.
