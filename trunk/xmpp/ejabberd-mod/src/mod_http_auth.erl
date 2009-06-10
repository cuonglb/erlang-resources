%%%-------------------------------------------------------------------
%%% File    : mod_http_auth.erl
%%% Author  : Cuong Le <cuonglb@facemain.com>
%%% Description : HTTP Authentication module for Ejabberd
%%% Created : 20 Feb 2009 by Cuong.Le <cuonglb@facemain.com>
%%%-------------------------------------------------------------------
-module(mod_http_auth).
-author('cuonglb@facemain.com').

-define(MOD_HTTP_AUTH_VERSION,"1.0").

-define(ejabberd_debug, true).

-vsn('1.0').

-behavior(gen_mod).

-include("ejabberd.hrl").
-include("jlib.hrl").
-include("ejabberd_http.hrl").

-define(BAD_REQUEST,"400 Bad Request").
-define(HTTP_AUTH_TRUE,"true").
-define(HTTP_AUTH_FALSE,"false").
-define(AUTH_STR,"authenticated").

-define(USERNAME,"username").
-define(PASSWORD,"password").
-define(DOMAIN,"domain").

%% API
-export([start/2,stop/1,process/2]).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start -> ok
%% Description:
%%--------------------------------------------------------------------
start(_Host, _Opt) ->
    ok.

%%--------------------------------------------------------------------
%% Function: stop -> ok
%% Description:
%%--------------------------------------------------------------------
stop(_Host) ->
    ok.

%%--------------------------------------------------------------------
%% Function: process -> 404_badrequest | json_object
%% Description:
%%--------------------------------------------------------------------
process([],#request{method = 'POST',data = []}) ->
	{400,[],{xmlelement,"h1",[],[{xmlcdata,?BAD_REQUEST}]}};
process([],#request{method = 'POST',data = Data}) ->
	 case is_list(Data) of
		true	->
			case json:decode_string(Data) of
				{ok,Upd} ->
						Username = case catch json:obj_fetch(?USERNAME,Upd) of {'EXIT',_} -> []; A -> A end,
						Password = case catch json:obj_fetch(?PASSWORD,Upd) of {'EXIT',_} -> []; B -> B end,
						Domain = case catch json:obj_fetch(?DOMAIN,Upd) of {'EXIT',_} -> []; C -> C end,
						authenticate(Username,Password,Domain);
				_ -> 
					{400,[],{xmlelement,"h1",[],[{xmlcdata,?BAD_REQUEST}]}}
			end;
		_ ->
			{400,[],{xmlelement,"h1",[],[{xmlcdata,?BAD_REQUEST}]}}
		end;
process([],#request{method = 'GET', data=[]}) ->
    Heading = "Ejabberd " ++ atom_to_list(?MODULE) ++ " v" ++ ?MOD_HTTP_AUTH_VERSION,
    {xmlelement, "html", [{"xmlns", "http://www.w3.org/1999/xhtml"}],
     [{xmlelement, "head", [],
       [{xmlelement, "title", [], [{xmlcdata, Heading}]}]},
      {xmlelement, "body", [],
       [{xmlelement, "h1", [], [{xmlcdata, Heading}]}
       ]}]};
process(_Path, _Request) ->
	{400,[],{xmlelement,"h1",[],[{xmlcdata,?BAD_REQUEST}]}}.

%%====================================================================
%% Internal functions
%%====================================================================
%% @spec authenticate(Username,Password,Domain) -> {json_object,{"authenticated":"true"|"false"}}
%% @doc Using ejabberd_auth to authorize one jabber account.

authenticate(Username,Password,Domain) ->
    Result = case (catch(ejabberd_auth:check_password(Username, Domain, Password))) of
				{'EXIT',_} ->
					?HTTP_AUTH_FALSE;
				Val -> 
					case Val of 
					    true -> ?HTTP_AUTH_TRUE;
					    false -> ?HTTP_AUTH_FALSE
					end
            end,
    ["{\""++?AUTH_STR++"\":"++Result++"}"].
