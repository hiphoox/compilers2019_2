defmodule Lexer do

  def scan_word(string, flag) do
    #Realiza limpieza del código
    words = Saneador.fix_format(string)
    case words do
      [""] -> {:error, "Error. Archivo código fuente vacío."}
        _ ->  start_lexing(words, flag) #Comienza a generar lista de Tokens
    #deberá devolver la lista de tokens
    end
  end


  def start_lexing(words, flag) do
    token_list = Enum.flat_map(words, &lex_raw_tokens/1)
    #s hubo error en la sintaxis, debe de haber un token llamado ":error".
    if Enum.member?(token_list, :error) do
      #Si dicho token no existe, entonces devuelve tupla de error
      {:error, "Error léxico." }
    else
      #revisa la bandera para mostrar o no en pantalla la lista de tokens
       if flag == :show_token do
        token_list2= Enum.dedup(token_list)
        IO.inspect(token_list)
        IO.puts("LISTA DE TOKENS CON OPERADORES UNARIOS OPTIMIZADOS...")
        IO.inspect(token_list2)
         #Solo mostrar lista de tokens y finalizar ejecución en el orquestador.
         {:only_tokens, token_list}
      #   {:op_tokens,token_list2}
       else
           token_list2= Enum.dedup(token_list)
         {:ok, token_list}
       end
     end
  end


  def lex_raw_tokens(program) when program != "" do #Búsqueda de patrones en la cadena de código
    {token, cadena_restante} =
    case program do
        "{" <> cadena_restante -> {:open_brace, cadena_restante}
        "}" <> cadena_restante -> {:close_brace, cadena_restante}
        "(" <> cadena_restante -> {:open_paren, cadena_restante}
        ")" <> cadena_restante -> {:close_paren, cadena_restante}
        ";" <> cadena_restante -> {:semicolon, cadena_restante}
        "return" <> cadena_restante -> {:return_Keyword, cadena_restante}
        "int" <> cadena_restante -> {:int_Keyword, cadena_restante}
        "main" <> cadena_restante -> {:main_Keyword, cadena_restante}
        "-" <> cadena_restante -> {:negation_Keyword, cadena_restante}
        "!" <> cadena_restante -> {:logicalNeg_Keyword, cadena_restante}
        "~" <> cadena_restante -> {:bitewise_Keyword, cadena_restante}
        "+" <> cadena_restante -> {:addition_Keyword, cadena_restante}
        "*" <> cadena_restante -> {:multiplication_Keyword, cadena_restante}
        "/" <> cadena_restante -> {:division_Keyword, cadena_restante}

        :error -> {:error, nil}
        #Si no hubo ninguna coincidencia, inserta la cadena error
        #si se encontró un error, guarda en cadena restante {:error, motivo}
        cadena_restante -> get_constant_chk_error(cadena_restante)
        end

        tokens_restantes = lex_raw_tokens(cadena_restante)
        [token | tokens_restantes]

  end

    def lex_raw_tokens(_program) do
      []
    end

  def get_constant_chk_error(remain_string) do
    #Constante o cadena inválida, procesar
    if Regex.run(~r/-?\d+/, remain_string) != nil do
        case Regex.run(~r/\d+/, remain_string) do
           [valor] -> {{:constant, String.to_integer(valor)}, String.trim_leading(remain_string, valor)}
        end
      else #Si no fue una constante, fue un error. Mostrar en pantalla el string inválido.
          IO.puts("La palabra " <> remain_string <> " es inválida." )
          {:error, ""}
      end
    end
end
