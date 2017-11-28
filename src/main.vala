void run_prompt () {
    stdout.printf("> ");
    string? line = stdin.read_line ();

    var parser = new ValaScript.Parser (line);
    parser.build_ast ();
}

void run_file (string path) {
  stdout.printf("Running %s\n", path);
}

int main (string[] args) {
  if (args.length > 2) {
  } else if (args.length == 2) {
    run_file (args[1]);
  } else {
    run_prompt();
  }

  return 0;
}
