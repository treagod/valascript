void run_prompt () {
    stdout.printf("> ");
    string? line = stdin.read_line ();

    var scanner = new ValaScript.Scanner (line);
    var token = scanner.next_token ();
    while (token.typ != ValaScript.TokenType.EOF) {
        stdout.printf ("%s %d %s\n", token.lexeme, token.position, token.typ.to_string ());
        token = scanner.next_token ();
    }

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
