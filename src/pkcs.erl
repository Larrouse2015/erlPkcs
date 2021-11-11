-module (pkcs).

-export ([
		  pad/1,
		  pad/2,
		  unpad/1,
		  unpad/2,
		  pkcs5_pad/1,
		  pkcs5_unpad/1
]).

%%pkcs5 is same as pkcs7 when set the blockSize of 8

pad(Bin) ->
  pad(Bin, 8).

pkcs5_pad(Bin) ->
	pad(Bin, 8).
					  

pad(Bin,BlockSize) when is_binary(Bin)->
	Diff = byte_size(Bin) rem BlockSize,
	pad2(Bin, BlockSize-Diff);
pad(Str,BlockSize) when is_list(Str)->
	Bin = unicode:characters_to_binary(Str),
	Diff = byte_size(Bin) rem BlockSize,
	pad2(Bin, BlockSize-Diff).

pad2(Bin,PaddingNum) ->
	PadList =  erlang:list_to_binary([PaddingNum || _ <- lists:seq(1, PaddingNum)]),
	<<Bin/binary,PadList/binary>>.
	

pkcs5_unpad(Bin) ->
	unpad(Bin,8).


unpad(<<>>) ->
  <<>>;
unpad(Bin) ->
	unpad(Bin,8).
	
unpad(<<>>,_) ->
	{ok,<<>>};
unpad(Bin,BlockSize) when is_binary(Bin)->
	Last = binary:last(Bin),
	Size = byte_size(Bin) - Last,
	RemSize = Size rem BlockSize,
	unpad2(Bin,RemSize,BlockSize,Size);
unpad(Str,BlockSize) when is_list(Str)->
	Bin = unicode:characters_to_binary(Str),
	unpad(Bin,BlockSize).
  
unpad2(Bin,0,BlockSize,Size) ->
	PadBin = erlang:list_to_binary([BlockSize || _ <- lists:seq(1, BlockSize)]),
	unpad3(Bin,PadBin,Size);
unpad2(Bin,RemSize,BlockSize,Size) ->
	PadNum = BlockSize - RemSize,
	PadBin = erlang:list_to_binary([PadNum || _ <- lists:seq(1, PadNum)]),
	unpad3(Bin,PadBin,Size).


unpad3(Bin,PadBin,Size) ->
  case Bin of
    <<Data:Size/binary,PadBin/binary>> ->
		{ok,Data};
    _ ->
		{error,bad_padding}
  end.