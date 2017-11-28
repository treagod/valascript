using Gee;


namespace ValaScript {
    class Scanner {
        private string _source;
        private int position;
        private char current_char;
        private HashMap<string, TokenType> keywords = new HashMap<string, TokenType> ();

        public Scanner (string src) {
            _source = src;
            position = 0;
            current_char = _source[0];
            create_keywords ();
        }

        public string source {
            get { return _source; }
        }

        public Token get_token () {
            if (is_whitespace () || is_comment ()) {
                skip_whitespace ();
                skip_comment ();
            }

            if (is_key_or_id ()){
                return next_key_or_id ();
            }

            if (current_char.isdigit ()) {
                if (current_char == '0') {
                    // Todo: Convert to right decimal
                    if (peek () == 'x') return next_hex ();
                    if (peek () == 'b') return next_binary ();
                    if (peek () == 'o') return next_octal ();
                }
                return next_number ();
            }

            if (current_char == '"') return next_string ();

            if (current_char == '+') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.PLUS_EQUAL);

                return next_token (current_char, TokenType.PLUS);
            }

            if (current_char == '-') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.MINUS_EQUAL);

                return next_token (current_char, TokenType.MINUS);
            }

            if (current_char == '*') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.ASTERISK_EQUAL);

                return next_token (current_char, TokenType.ASTERISK);
            }

            if (current_char == '/') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.SLASH_EQUAL);

                return next_token (current_char, TokenType.SLASH);
            }

            if (current_char == '=') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.EQUAL_EQUAL);

                return next_token (current_char, TokenType.EQUAL);
            }

            if (current_char == '<') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.LESS_EQUAL);

                return next_token (current_char, TokenType.LESS_EQUAL);
            }

            if (current_char == '>') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.GREATER_EQUAL);

                return next_token (current_char, TokenType.GREATER);
            }

            if (current_char == '!') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.NOT_EQUAL);

                return next_token (current_char, TokenType.NOT);
            }

            if (current_char == '/') {
                if (peek () == '=') return next_combined_operator(current_char, TokenType.SLASH_EQUAL);

                return next_token (current_char, TokenType.SLASH);
            }

            if (current_char == '\n') return next_token (current_char, TokenType.NEWLINE); // Todo: Rename

            if (current_char == '(') return next_token (current_char, TokenType.LEFT_PAREN);

            if (current_char == ')') return next_token (current_char, TokenType.RIGHT_PAREN);

            if (current_char == '[') return next_token (current_char, TokenType.LEFT_BRACKET);

            if (current_char == ']') return next_token (current_char, TokenType.RIGHT_BRACKET);

            if (current_char == '{') return next_token (current_char, TokenType.LEFT_BRACE);

            if (current_char == '}') return next_token (current_char, TokenType.RIGHT_BRACE);

            if (current_char == '\0') return next_token (current_char, TokenType.EOF);

            advance ();
            return new Token ("Invalid", position, TokenType.INVALID);
        }

        private Token next_token (char c, TokenType typ) {
            int pos = position;
            advance();
            return new Token(c.to_string (), pos, typ);
        }

        private Token next_combined_operator (char op, TokenType typ) {
            var pos = position;
            advance (); advance ();
            return new Token(op.to_string () + "=", pos, typ);
        }

        private Token next_number () {
            var number_builder = new StringBuilder ();
            var pos = position;

            while (current_char.isdigit ()) {
                number_builder.append_c (current_char);
                advance ();
            }
            return new Token (number_builder.str, pos, TokenType.INTEGER);
        }

        private Token next_string () {
            var pos = position;
            advance ();
            var string_builder = new StringBuilder ();
            char previous_char = '"';

            while (!(current_char == '\0' || (current_char == '"'))) {
                if (current_char == '\\') {
                    if (peek () == '"') {
                        advance ();
                    } else if (peek () == 'n') {
                        advance (); advance ();
                        string_builder.append_c ('\n');
                        continue;
                    } else if (peek () == 't') {
                        advance (); advance ();
                        string_builder.append_c ('\t');
                        continue;
                    } // Todo: Add other controll chars
                }
                string_builder.append_c (current_char);
                previous_char = current_char;
                advance ();
            }

            advance ();

            return new Token (string_builder.str, pos, TokenType.STRING);
        }

        private Token next_octal () {
            var pos = position;
            advance (); advance ();
            var number_builder = new StringBuilder ();

            while (is_oct ()) {
                number_builder.append_c (current_char);
                advance ();
            }
            return new Token (number_builder.str, pos, TokenType.INTEGER);
        }

        private Token next_binary () {
            var pos = position;
            var number_builder = new StringBuilder ();
            number_builder.append_c (current_char); advance ();
            number_builder.append_c (current_char); advance ();

            while (is_bin()) {
                number_builder.append_c (current_char);
                advance ();
            }
            var decimal = int.parse(number_builder.str);
            stdout.printf("%d\n", decimal);
            return new Token (decimal.to_string (), pos, TokenType.INTEGER);
        }

        private Token next_hex () {
            var pos = position;
            advance (); advance ();
            var number_builder = new StringBuilder ();

            while (is_hex()) {
                number_builder.append_c (current_char);
                advance ();
            }
            return new Token (convert_to_decimal_string (number_builder.str), pos, TokenType.INTEGER);
        }

        private Token next_key_or_id () {
            var key_or_id_builder = new StringBuilder ();
            var pos = position;

            if (current_char == '_') {
                key_or_id_builder.append_c (current_char);
                advance ();
            }

            while (current_char.isalnum ()) {
                key_or_id_builder.append_c (current_char);
                advance ();
            }

            var key_or_id = key_or_id_builder.str;

            if (keywords.has_key (key_or_id)) {
                return new Token (key_or_id_builder.str, pos, keywords.get(key_or_id));
            }

            return new Token (key_or_id_builder.str, pos, TokenType.IDENTIFIER);
        }

        private bool is_key_or_id () {
            return current_char.isalpha () || current_char == '_';
        }

        private char peek(int i = 1) {
            if (position + i > _source.length) return '\0';
            return _source[position + i];
        }

        private void advance () {
            position += 1;
            if (position >= _source.length) {
                current_char = '\0';
            } else {
                current_char = _source[position];
            }
        }

        private void create_keywords () {
            keywords.set("if", TokenType.IF);
            keywords.set("else", TokenType.ELSE);
            keywords.set("true", TokenType.TRUE);
            keywords.set("false", TokenType.FALSE);
            keywords.set("class", TokenType.CLASS);
            keywords.set("is", TokenType.IS);
            keywords.set("in", TokenType.IN);
            keywords.set("while", TokenType.WHILE);
            keywords.set("for", TokenType.FOR);
            keywords.set("break", TokenType.BREAK);
            keywords.set("continue", TokenType.CONTINUE);
            keywords.set("return", TokenType.RETURN);
        }

        private bool is_hex () {
            return current_char >= 'a' && current_char <= 'f' ||
                   current_char >= 'A' && current_char <= 'F' ||
                   current_char.isdigit ();
        }

        private bool is_whitespace () {
            return current_char == ' ' || current_char == '\t' || current_char == '\v';
        }

        private bool is_comment () {
            return current_char == '/' && peek () == '/';
        }

        private void skip_comment () {
            if (is_comment ()) {
                while (!(current_char == '\n' || current_char == '\0')) {
                    advance ();
                }
            }
        }

        private void skip_whitespace () {
            while (is_whitespace ()) {
                advance ();
            }
        }

        private bool is_oct () {
            return current_char.isdigit () && !(current_char == '8' || current_char == '9');
        }

        private bool is_bin () {
            return current_char == '0' || current_char == '1';
        }
    }
}
