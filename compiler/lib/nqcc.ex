defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "help" => "Prints this help",
    "o newName" => "Change file name",
    "s" => "Retrieves assembly file",
    "t" => "Retrieves token list",
    "a" => "Retrieves AST"
  }

  def main(args) do
    args
    |> parse_args
    |> process_args
  end

  def parse_args(args) do
    OptionParser.parse(args, switches: [help: :boolean,t: :boolean,a: :boolean , s: :boolean ,o: :boolean])
  end

  defp process_args({[help: true], _, _}) do
    print_help_message()
  end

  defp process_args({[t: true],[file_name], _}) do
    print_token_list(file_name)
  end

  defp process_args({[a: true],[file_name], _}) do
    print_AST(file_name)
  end

  defp process_args({[s: true],[file_name], _}) do
    print_Assembly(file_name)
  end

  defp process_args({[o: true],[newName,file_name], _}) do
    compile_file_with_new_name(newName,file_name)
  end

  defp process_args({_, [file_name], _}) do
    compile_file(file_name)
  end

 defp compile_file(file_path) do
    IO.puts("Compiling file: " <> file_path)
    assembly_path = String.replace_trailing(file_path, ".c", ".s")

    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> CodeGenerator.generate_code()
    |> Linker.generate_binary(assembly_path)
end

defp compile_file_with_new_name(newName,file_path) do
  IO.puts("Compiling file: " <> file_path)
  basename = Path.basename(file_path)
  assembly_path = String.replace(file_path,basename,newName)
  assembly_path <> ".s"
  File.read!(file_path)
  |> Sanitizer.sanitize_source()
  |> Lexer.scan_words()
  |> Parser.parse_program()
  |> CodeGenerator.generate_code()
  |> Linker.generate_binary(assembly_path)
end


  defp print_token_list(file_path) do
  IO.puts("\n TOKEN LIST \n")
  File.read!(file_path)
  |> Sanitizer.sanitize_source()
  |> Lexer.scan_words()
  |> IO.inspect()
  end

  defp print_AST(file_path) do
    IO.puts("\n  AST TREE \n")
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> IO.inspect()
  end

  defp print_Assembly(file_path) do
    IO.puts("\n  AST TREE \n")
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> CodeGenerator.generate_code()
    |> IO.inspect()

  end

  defp print_help_message do
    IO.puts("\nnqcc --help file_name \n")

    IO.puts("\nThe compiler supports following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
