package cup.example;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%public
%unicode
%line
%column
%cup
%char
%{

    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is){
		this(is);
        symbolFactory = sf;
    }
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader){
		this(reader);
        symbolFactory = sf;
    }
    
    private StringBuffer sb;
    private ComplexSymbolFactory symbolFactory;
    private int csline,cscolumn;

    public Symbol symbol(String name, int code){
		return symbolFactory.newSymbol(name, code,
						new Location(yyline+1,yycolumn+1, yychar), // -yylength()
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength())
				);
    }
    public Symbol symbol(String name, int code, String lexem){
	return symbolFactory.newSymbol(name, code, 
						new Location(yyline+1, yycolumn +1, yychar), 
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength()), lexem);
    }
    
    protected void emit_warning(String message){
    	System.out.println("scanner warning: " + message + " at : 2 "+ 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
    
    protected void emit_error(String message){
    	System.out.println("scanner error: " + message + " at : 2" + 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
%}

Newline    = \r | \n | \r\n
Whitespace = [ \t\f] | {Newline}

/* Comentarios */
Comment = {TraditionalComment} | {EndOfLineComment}
TraditionalComment = "/*" {CommentContent} \*+ "/"
EndOfLineComment = "//" [^\r\n]* {Newline}
CommentContent = ( [^*] | \*+[^*/] )*

ident = ([:jletter:] | "_" ) ([:jletterdigit:] | [:jletter:] | "_" )*

/* Identificador array */
mem = MEM\[{pos}\]
pos = 0 | [1-9][0-9]?

/* Número decimal entero */
Number = 0 | [1-9][0-9]*

/* Número entero hexadecimal */
HexInteger = 0 [xX] 0* {HexDigit} {1,8}
HexDigit   = [0-9a-fA-F]

/* Números decimales */
Float  = ({Float1}|{Float2}|{Float3}) {Exp}?
Float1 = [0-9]+ \. [0-9]*
Float2 = \. [0-9]+
Float3 = [0-9]+
Exp    = [eE] [+-]? [0-9]+

%eofval{
    return symbolFactory.newSymbol("EOF",sym.EOF);
%eofval}

%state CODESEG

%%  

<YYINITIAL> {

  {Whitespace} {                              }
  {Comment}    {                              }

  /* OPERADORES */
  "+"          { return symbolFactory.newSymbol("PLUS", PLUS);     }
  "-"          { return symbolFactory.newSymbol("MINUS", MINUS);   }
  "*"          { return symbolFactory.newSymbol("TIMES", TIMES);   }
  "/"          { return symbolFactory.newSymbol("DIVIDE", DIVIDE); }
  "exp"        { return symbolFactory.newSymbol("EXP", EXP);       }
  "log"        { return symbolFactory.newSymbol("LOG", LOG);       }
  "cos"        { return symbolFactory.newSymbol("COS", COS);       }
  "sin"        { return symbolFactory.newSymbol("SIN", SIN);       }

  /* SEPARADORES, PARÉNTESIS Y ASIGNACIONES */
  ";"          { return symbolFactory.newSymbol("SEMI", SEMI);     }
  "("          { return symbolFactory.newSymbol("LPAREN", LPAREN); }
  ")"          { return symbolFactory.newSymbol("RPAREN", RPAREN); }
  "="          { return symbolFactory.newSymbol("ASSIGN", ASSIGN); }

  /* NÚMEROS */
  {Number}     { return symbolFactory.newSymbol("NUMBER", NUMBER, Integer.parseInt(yytext())); }
  {HexInteger} { return symbolFactory.newSymbol("HEX", HEX, Integer.parseInt(yytext().substring(2, yytext().length()), 16)); }
  {Float}      { return symbolFactory.newSymbol("FLOAT", FLOAT, Float.parseFloat(yytext())); }

  /* POSICIONES DE ARRAY MEM */
  {mem}        { return symbolFactory.newSymbol("MEM", MEM, Integer.parseInt(yytext().substring(4, yytext().length()-1))); }
}



// error fallback
.|\n          { emit_warning("Unrecognized character '" +yytext()+"' -- ignored"); }
