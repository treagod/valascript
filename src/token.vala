namespace ValaScript {
    public enum TokenType {
        INTEGER, FLOAT, STRING, IDENTIFIER,

        // Operators
        PLUS, MINUS, ASTERISK, SLASH, LEFT_PAREN, RIGHT_PAREN, LEFT_BRACKET, RIGHT_BRACKET,
        LEFT_BRACE, RIGHT_BRACE, PLUS_EQUAL, MINUS_EQUAL, ASTERISK_EQUAL, SLASH_EQUAL, EQUAL_EQUAL,
        LESS, LESS_EQUAL, GREATER, GREATER_EQUAL, EQUAL, NOT, NOT_EQUAL,

        // Keywords
        IF, ELSE, TRUE, FALSE, CLASS, IS,

        INVALID, NEWLINE, EOF
    }

    class Token {
        private TokenType _type;
        private string _lexeme;
        private int _position;

        public TokenType typ {
            get { return _type; }
        }

        public string lexeme {
            get { return _lexeme; }
        }

        public int position {
            get { return _position; }
        }

        public Token (string lexeme, int position, TokenType typ) {
            _type = typ;
            _lexeme = lexeme;
            _position = position;
        }
    }
}
