-module(html).

-export([render/1, render/2]).

-compile({inline, [{start_tag, 2}, {end_tag, 1}, {space, 0}]}).

-include_lib("eunit/include/eunit.hrl").

render_test_() -> [
    ?_assertEqual(<<"<br>">>, iolist_to_binary(render({br})))
  , ?_assertEqual(<<"<input disabled>">>, iolist_to_binary(render({input, [disabled]})))
  , ?_assertEqual(<<"<input type=\"text\">">>, iolist_to_binary(render({input, [{type, text}]})))
  , ?_assertEqual(<<"<input title=\"&quot;&amp;&lt;&gt;\">">>, iolist_to_binary(render({input, [{title, <<"\"&<>">>}]})))
  , ?_assertEqual(<<"<input size=\"30\">">>, iolist_to_binary(render({input, [{size, 30}]})))
  , ?_assertEqual(<<"<h1></h1>">>, iolist_to_binary(render({h1, [], []})))
  , ?_assertEqual(<<"<h1>hello world</h1>">>, iolist_to_binary(render({h1, [], <<"hello world">>})))
  , ?_assertEqual(<<"<h1>hello&nbsp;world</h1>">>, iolist_to_binary(render({h1, [], [<<"hello">>, '&nbsp;', <<"world">>]})))
  , ?_assertEqual(<<"<h1>a &amp;&amp; b, x &gt; y</h1>">>, iolist_to_binary(render({h1, [], <<"a && b, x > y">>})))
  , ?_assertEqual(<<"<h1>1234567890</h1>">>, iolist_to_binary(render({h1, [], 1234567890})))
  , ?_assertEqual(<<"<ul><li>1</li><li>2</li></ul>">>, iolist_to_binary(render({ul, [], [{li, [], 1}, {li, [], 2}]})))
  , ?_assertEqual(<<"<h1><span>hello world</span></h1>">>, iolist_to_binary(render({h1, {span, <<"hello world">>}})))
  , ?_assertEqual(<<"<span>42</span>">>, iolist_to_binary(render({span, [], 'X'}, [{'X', 42}])))
  ].

render(Term) ->
  render(Term, []).

render({Name}, _Context) when is_atom(Name) ->
  start_tag(Name, []);
render({Name, AttrList, Content}, Context) ->
  [start_tag(Name, AttrList), render(Content, Context), end_tag(Name)];
render({Name, Content}, Context) when is_atom(Name), is_binary(Content) ->
  [start_tag(Name, []), render(Content, Context), end_tag(Name)];
render({Name, Content}, Context) when is_atom(Name), is_tuple(Content) ->
  [start_tag(Name, []), render(Content, Context), end_tag(Name)];
render({Name, AttrList}, _Context) when is_atom(Name) ->
  start_tag(Name, AttrList);
render(Input, Context) when is_list(Input) ->
  [render(Term, Context) || Term <- Input];
render(Input, _Context) when is_integer(Input) ->
  integer_to_list(Input);
render(Input, _Context) when is_binary(Input) ->
  escape(Input);
render(Input, Context) when is_atom(Input) ->
  case proplists:lookup(Input, Context) of
    {_, Term} ->
      render(Term, Context);
    none ->
      atom_to_list(Input)
  end.

attr_render({Name, Value}) when is_atom(Name) ->
  [space(), atom_to_list(Name), $=, $", attr_value_render(Value), $"];
attr_render(Name) when is_atom(Name) ->
  [space(), atom_to_list(Name)].

attr_value_render(Value) when is_binary(Value) ->
  binary:replace(escape(Value), <<"\"">>, <<"&quot;">>, [global]);
attr_value_render(Value) when is_integer(Value) ->
  integer_to_list(Value);
attr_value_render(Value) when is_atom(Value) ->
  atom_to_list(Value).

escape(Input) ->
  lists:foldl(fun ({P, R}, B) -> binary:replace(B, P, R, [global]) end, Input, escapes:spec()).

start_tag(Name, AttrList) ->
  [$<, atom_to_list(Name), [attr_render(Attr) || Attr <- AttrList], $>].

end_tag(Name) ->
  [$<, $/, atom_to_list(Name), $>].

space() ->
  32.
