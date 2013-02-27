An Erlang module for rendering HTML.

Quick start:

  $ make
  ...
  $ erl -pa ebin
  ...
  1> iolist_to_binary(html:render({br})).
  <<"<br>">>
  2> iolist_to_binary(html:render({h1, <<"hello world">>})).
  <<"<h1>hello world</h1>">>
  3> iolist_to_binary(html:render({input, [{type, text}, {size, 30}]})).
  <<"<input type=\"text\" size=\"30\">">>
  4> iolist_to_binary(html:render([<<"hi ">>, user.name], [{user.name, <<"joe">>}])).
  <<"hi joe">>
  ...

Pass terms to html:render/1 and format the result with iolist_to_binary/1.

Use html:render/2 with an additional proplist to use for variable lookup.

Here's a more complete example:

  {html, [], [
    {head, {title, <<"Boats.com">>}},
    {body, [], [
      {h1, <<"Boats.com has great deals">>},
      {ul, [], [
        {li, <<"$49 for a canoe">>},
        {li, <<"$39 for a raft">>},
        {li, <<"$29 for a huge boot that floats and can fit 5 people">>}
      ]}
    ]}
  ]}.
