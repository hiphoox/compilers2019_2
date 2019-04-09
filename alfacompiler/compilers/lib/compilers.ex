defmodule Compilers do
  @moduledoc """
  Documentation for Compilers.
  """


@commands %{
  "help" => "Help",
  "t" => "Lexer",
  "a" => "Parser",
  "s" => "Assembly"
}


def main(args) do
   args
   |> parseando_args
   |> procesando_args

end

def parseando_args(args) do
  OptionParser.parse(args, switches: [help: :boolean])

end

defp procesando_args({_, [file_name],_}) do
  compile_file(file_name)
end


defp procesando_args({[help: true],_,_}) do
  print_help_message()
end


defp procesando_args({ _, ["t" ,file_name], _}) do
  lexer(file_name)
end

defp procesando_args({ _, ["p" ,file_name], _}) do
  parser(file_name)
end

defp procesando_args({ _, ["s" ,file_name], _}) do
  assembly(file_name)
end

defp procesando_args({ _, ["a" ,file_name], _}) do
  parser(file_name)
end



#################        Banderas     ##############3
defp print_help_message do
  IO.puts("Bandera de AYUDA \n");
  IO.puts("Las opciones de uso del compilador son: \n");
  IO.puts("-t Se muestra la lista de tokens\n");
  IO.puts("-a Se muestra el árbol AST\n");
  IO.puts("-s Se muestra el codigo ensamblador \n");


  @commands
  |> Enum.map(fn({command, description}) -> IO.puts("  #{command} - #{description}") end)
end

defp assembly(file_path) do
  IO.puts("Se imprimira el Ensamblador")
    File.read!(file_path)
    |> Saneador.limpiado()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> CodeGenerator.generate_code()

end

defp lexer(file_path) do
  IO.puts("Se imprimira el Lexer")
    File.read!(file_path)
    |> Saneador.limpiado()
    |> Lexer.scan_words()

end

defp parser(file_path) do
  IO.puts("Se imprimira el Parser")
  File.read!(file_path)
  |> Saneador.limpiado()
  |> Lexer.scan_words()
  |> Parser.parse_program()

end



  defp compile_file(file_path) do
    IO.puts("Compiling file: " <> file_path)
    assembly_path = String.replace_trailing(file_path, ".c", ".s")
    File.read!(file_path)
    |> Saneador.limpiado()
    |> IO.inspect(label: "\nSanitizer ouput")
    |> Lexer.scan_words()
    |> IO.inspect(label: "\nLexer ouput")
    |> Parser.parse_program()
    |> IO.inspect(label: "\nParser ouput")
    |> CodeGenerator.generate_code()
    |> Linker.generate_binary(assembly_path)
  end
end
