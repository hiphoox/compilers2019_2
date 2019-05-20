defmodule Parser do
  def parse_program(token_list) do
    function = parse_function(token_list)

    case function do
      {{:error, error_message, linea}, _rest} ->
        {:error, error_message, linea}

      {function_node, rest} ->
        if rest == [] do
          %AST{node_name: :program, left_node: function_node}
        else
          {:error, "Error: thera are more elements after Keyword 'end' ", 0}
        end
    end
  end

  def parse_function([{next_token, line} | rest]) do
    if next_token == :intkeyword do
      [{next_token, line} | rest] = rest

      if next_token == :mainkeyword do
        [{next_token, line} | rest] = rest

        if next_token == :open_parenthesis do
          [{next_token, line} | rest] = rest

          if next_token == :close_parenthesis do
            [{next_token, line} | rest] = rest

            if next_token == :open_brace do
              statement = parse_statement(rest)

              case statement do
                {{:error, error_message, line}, rest} ->
                  {{:error, error_message, line}, rest}

                {statement_node, [{next_token, line} | rest]} ->
                  if next_token == :close_brace do
                    {%AST{node_name: :function, value: :main, left_node: statement_node}, rest}
                  else
                    {{:error, "Error: it was found -> <- when expecting  ->close brace<- ",line}, rest}
                  end
              end
            else
              {{:error, "Error: it was found ->#{next_token}<- when expecting  ->open brace<- ",line},rest}
            end
          else
            {{:error, "Error: it was found ->#{next_token}<- when expecting  ->close parenthesis<- ",line},rest}
          end
        else
          {{:error, "Error: it was found ->#{next_token}<- when expecting  ->open parenthesis<-",line},rest}
        end
      else
        {{:error, "Error: it was found ->#{next_token}<- when expecting  ->main<-",line},rest}
      end
    else
      {{:error, "Error: it was found ->#{next_token}<- when expecting  ->return type<-",line},rest}
    end
  end

  def parse_statement([{next_token, line} | rest]) do
    if next_token == :returnkeyword do
      expression = parse_expression(rest)

      case expression do
        {{:error, error_message}, rest} ->
          {{:error, error_message}, rest}

        {exp_node, [{next_token, line} | rest]} ->
          if next_token == :semicolon do
            {%AST{node_name: :return, left_node: exp_node}, rest}
          else
            {{:error, "Error: it was found ->#{next_token}<- when expecting  ->semicolon<- ",line},
             rest}
          end
      end
    else
      {{:error, "Error: it was found ->#{next_token}<- when expecting  ->return keyword<- ",line}, rest}
    end
  end

  def parse_expression([{next_token, line} | rest]) do
    case next_token do
      {:constant, value} -> {%AST{node_name: :constant, value: value}, rest}
      _ -> {{:error, "Error: it was found ->#{next_token}<- when expecting  ->constant<- ",line}, rest}
    end
  end

  def parse_unary_op([{next_token,numline} | rest]) do
    case next_token do
      :negative_keyword ->
        parexpres=parse_expression(rest)
        {nodo,rest_necesario}=parexpres
        {%AST{node_name: :unary_negative, left_node: nodo}, rest_necesario}
      :complement_keyword ->
        parexpres=parse_expression(rest)
        {_,rest_necesario}=parexpres
        {%AST{node_name: :unary_complement, left_node: parexpres}, rest_necesario}
      _ -> {{:error, "Error, arbol",numline,next_token}, rest}
    end
end
end
