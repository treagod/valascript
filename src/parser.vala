using Gee;

namespace ValaScript {
    class Parser {
        private enum Precedence {
            LOWEST, ASSIGNMENT, CONDITIONAL, LOGIC_OR, LOGIC_AND, EQUALITY, IN, COMPARISON,
            BIT_OR, BIT_XOR, BIT_AND,SHIFT, RANGE, TERM, FACTOR, UNARY, CALL
        }
        private Scanner scanner;
        private Token current_token;
        private Token next_token;

        public Parser(string source) {
            scanner = new Scanner (source);
            current_token = scanner.get_token ();
            next_token = scanner.get_token ();
        }

        public CompoundStmt build_ast () {
            var comp_stmt = new CompoundStmt();

            while (current_token.typ != TokenType.EOF) {
                skip_newline ();
                comp_stmt.add_stmt (next_stmt ());
                skip_newline ();
            }
            return comp_stmt;
        }

        private Stmt next_stmt () {
            switch (current_token.typ) {
            case TokenType.WHILE:
                return next_while_stmt ();
            case TokenType.FOR:
                return next_for_stmt ();
            default:
                return next_expression_statement ();
            }
        }

        private Stmt next_expression_statement () {
            return new ExprStmt (parse_expression ());
        }

        private Expr parse_expression (Precedence precedence = Precedence.LOWEST) {
            var expr = parse_prefix ();

            while (!(current_token.typ == TokenType.NEWLINE || current_token.typ == TokenType.EOF) &&
                    precedence < precendece_of (current_token)) {
                expr = parse_infix(expr);
            }

            return expr;
        }

        private Expr parse_prefix () {
            switch (current_token.typ) {
            case TokenType.IF:
            case TokenType.INTEGER: return next_int_literal ();
            case TokenType.FLOAT: return next_float_literal ();
            case TokenType.STRING: return next_string_literal ();
            case TokenType.IDENTIFIER: return next_identifier_literal ();
            case TokenType.MINUS:
            case TokenType.PLUS:
            case TokenType.NOT:
                return next_unary_expression ();
            default:
                assert_not_reached ();
            }
        }

        private Expr parse_infix (Expr expr) {
            switch (current_token.typ) {
            case TokenType.PLUS:
            case TokenType.MINUS:
            case TokenType.ASTERISK:
            case TokenType.SLASH:
            case TokenType.PLUS_EQUAL:
            case TokenType.MINUS_EQUAL:
            case TokenType.ASTERISK_EQUAL:
            case TokenType.SLASH_EQUAL:
                return next_binary_expression (expr);
            case TokenType.LEFT_PAREN:
                return next_call_expression (expr);
            case TokenType.LEFT_BRACKET:
                return next_access_expression (expr);
            default:
                assert_not_reached ();
            }
        }

        private Expr next_int_literal () {
            return next_literal (TokenType.INTEGER);
        }

        private Expr next_string_literal () {
            return next_literal (TokenType.STRING);
        }

        private Expr next_float_literal () {
            return next_literal (TokenType.FLOAT);
        }

        private Expr next_identifier_literal () {
            return next_literal (TokenType.IDENTIFIER);
        }

        private Expr next_literal (TokenType typ) {
            var token = current_token;
            consume(typ);

            switch (typ) {
            case TokenType.INTEGER: return new IntegerLiteral (token);
            case TokenType.FLOAT: return new FloatLiteral (token);
            case TokenType.STRING: return new StringLiteral (token);
            case TokenType.IDENTIFIER: return new IdentifierLiteral (token);
            default:
                assert_not_reached ();
            }
        }

        private Expr next_binary_expression (Expr expr) {
            var token = current_token;
            switch (token.typ) {
            case TokenType.PLUS:
                consume (TokenType.PLUS); break;
            case TokenType.MINUS:
                consume (TokenType.MINUS); break;
            case TokenType.ASTERISK:
                consume (TokenType.ASTERISK); break;
            case TokenType.SLASH:
                consume (TokenType.SLASH); break;
            default:
                assert_not_reached ();
            }

            return new BinaryExpr (token, expr, parse_expression (precendece_of (token)));
        }

        private Expr next_unary_expression () {
            var token = current_token;
            switch (current_token.typ) {
            case TokenType.MINUS: consume (TokenType.MINUS); break;
            case TokenType.PLUS: consume (TokenType.PLUS); break;
            case TokenType.NOT: consume (TokenType.NOT); break;
            default:
                assert_not_reached ();
            }

            return new UnaryExpr(token, parse_expression (Precedence.UNARY));
        }

        private Expr next_call_expression (Expr expr) {
            var token = current_token;
            var call_expr = new CallExpr (token, expr);
            var first = true;
            consume (TokenType.LEFT_PAREN);

            while (!(current_token.typ == TokenType.RIGHT_PAREN || current_token.typ == TokenType.EOF)) {
                if (!first) consume (TokenType.COMMA);

                call_expr.add_parameter (parse_expression ());
                first = false;
            }

            consume (TokenType.RIGHT_PAREN);

            return call_expr;
        }

        private Expr next_access_expression (Expr expr) {
            var token = current_token;
            consume (TokenType.LEFT_BRACKET);

            var accessor = parse_expression ();

            consume (TokenType.RIGHT_BRACKET);

            return new AccessExpr (token, expr, accessor);
        }

        private Stmt next_for_stmt () {
            return new CompoundStmt ();
        }

        private Stmt next_while_stmt () {
            return new CompoundStmt ();
        }

        private Precedence precendece_of (Token token) {
            switch (token.typ) {
            case TokenType.PLUS:
            case TokenType.MINUS:
                return Precedence.TERM;
            case TokenType.ASTERISK:
            case TokenType.SLASH:
                return Precedence.FACTOR;
            case TokenType.EQUAL:
                return Precedence.EQUALITY;
            case TokenType.LEFT_PAREN:
            case TokenType.LEFT_BRACKET:
                return Precedence.CALL;
            default:
                return Precedence.LOWEST;
            }
        }

        private void consume(TokenType typ) {
            if (current_token.typ == typ) {
                current_token = next_token;
                next_token = scanner.get_token ();
            } else {
                stderr.printf("Expected %s, got %s. (%d:%d)\n", typ.to_string (), current_token.typ.to_string (), 1, 2);
                Process.exit(1);
            }
        }

        private void skip_newline () {
            while(current_token.typ == TokenType.NEWLINE) {
                consume (TokenType.NEWLINE);
            }
        }
    }
}
