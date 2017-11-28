namespace ValaScript {
    abstract class Expr {
        private Token _token;

        public Token token {
            get { return _token; }
        }

        protected Expr (Token token) {
            _token = token;
        }
    }

    abstract class Stmt {}

    class CompoundStmt : Stmt {
        private Array<Stmt> _statements = new Array<Stmt> ();

        public Array<Stmt> statements {
            get { return _statements; }
        }

        public void add_stmt (Stmt stmt) {
            statements.append_val (stmt);
        }
    }

    class ExprStmt : Stmt {
        private Expr _expr;

        public Expr expr {
            get { return _expr; }
        }

        public ExprStmt(Expr expr) {
            _expr = expr;
        }

        public Token token {
            get { return expr.token; }
        }
    }

    class UnaryExpr : Expr {
        private Expr _expr;

        public UnaryExpr (Token token, Expr expr) {
            base (token);
            _expr = expr;
        }

        public Expr expr {
            get { return _expr; }
        }
    }

    class BinaryExpr : Expr {
        private Expr _left;
        private Expr _right;

        public BinaryExpr (Token token, Expr left, Expr right) {
            base (token);
            _left = left;
            _right = right;
        }

        public Expr left {
            get { return _left; }
        }

        public Expr right {
            get { return _right; }
        }
    }

    class CallExpr : Expr {
        private Array<Expr> _parameters = new Array<Expr> ();
        private Expr _callee;

        public Array<Expr> parameters {
            get { return _parameters; }
        }

        public Expr callee {
            get { return _callee; }
        }

        public CallExpr (Token token, Expr callee) {
            base (token);
            _callee = callee;
        }

        public void add_parameter (Expr parameter) {
            _parameters.append_val (parameter);
        }
    }

    class AccessExpr : Expr {
        private Expr _accessee;
        private Expr _accessor;

        private Expr accessee {
            get { return _accessee; }
        }

        private Expr accessor {
            get { return _accessor; }
        }

        public AccessExpr (Token token, Expr accessee, Expr accessor) {
            base (token);
            _accessee = accessee;
            _accessor = accessor;
        }
    }

    class IntegerLiteral : Expr {
        public IntegerLiteral (Token token) {
            base (token);
        }

        public int get_value () {
            return int.parse (token.lexeme);
        }
    }

    class FloatLiteral : Expr {
        public FloatLiteral (Token token) {
            base (token);
        }
    }

    class StringLiteral : Expr {
        public StringLiteral (Token token) {
            base (token);
        }

        public string get_value () {
            return token.lexeme;
        }
    }

    class IdentifierLiteral : Expr {
        public IdentifierLiteral (Token token) {
            base (token);
        }

        public string get_name () {
            return token.lexeme;
        }
    }
}
