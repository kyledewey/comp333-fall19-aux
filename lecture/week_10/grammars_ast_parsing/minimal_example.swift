indirect enum MyList<A> {
    case cons(A, MyList<A>)
    case empty
} // MyList

enum ParseResult<A> {
    case success(MyList<Token>, A)
    case failure(String)
} // ParseResult

typealias Parser<A> = (MyList<Token>) -> ParseResult<A>

enum Token {
    case integerToken(Int)
    case plusToken
} // Token

extension Token: Equatable {
    static func ==(leftToken: Token, rightToken: Token) -> Bool {
        switch (leftToken, rightToken) {
        case (.integerToken(let leftNum), .integerToken(let rightNum)):
            return leftNum == rightNum
        case (.plusToken, .plusToken):
            return true
        case _:
            return false
        }
    } // ==
} // extension Token

indirect enum Exp {
    case integer(Int)
    case plus(Exp, Exp)
} // Exp

struct Unit {}

func tokenP(_ expectedToken: Token) -> Parser<Unit> {
    return { tokens in
        switch tokens {
        case .cons(let receivedToken, let rest):
            if expectedToken == receivedToken {
                return ParseResult.success(rest, Unit())
            } else {
                return ParseResult.failure(
                  "Expected: \(expectedToken); Received: \(receivedToken)")
            }
        case .empty:
            return ParseResult.failure("Out of tokens")
        }
    }
} // tokenP

func numP() -> Parser<Int> {
    return { tokens in
        switch tokens {
        case .cons(.integerToken(let value), let rest):
            return ParseResult.success(rest, value)
        case .cons(let received, _):
            return ParseResult.failure(
              "Expected number token; Received: \(received)")
        case .empty:
            return ParseResult.failure("Out of tokens")
        }
    }
} // numP

func andP<A, B>(_ leftParser: @escaping @autoclosure () -> Parser<A>,
                _ rightParser: @escaping @autoclosure () -> Parser<B>) -> Parser<(A, B)> {
    return { tokens in
        switch leftParser()(tokens) {
        case .success(let restLeft, let a):
            switch rightParser()(restLeft) {
            case .success(let restRight, let b):
                return ParseResult.success(restRight, (a, b))
            case .failure(let error):
                return ParseResult.failure(error)
            }
        case .failure(let error):
            return ParseResult.failure(error)
        }
    }
} // andP

func orP<A>(_ leftParser: @escaping @autoclosure () -> Parser<A>,
            _ rightParser: @escaping @autoclosure () -> Parser<A>) -> Parser<A> {
    return { tokens in
        switch leftParser()(tokens) {
        case .failure(_):
            return rightParser()(tokens)
        case let success: return success
        }
    }
} // orP

func integerP() -> Parser<Exp> {
    return { tokens in 
        switch numP()(tokens) {
        case .success(let rest, let num):
            return ParseResult.success(rest, Exp.integer(num))
        case .failure(let error):
            return ParseResult.failure(error)
        }
    }
} // integerP

func plusP() -> Parser<Exp> {
    return { tokens in
        let parser = andP(integerP(),
                          andP(tokenP(Token.plusToken),
                               expressionP()))
        switch parser(tokens) {
        case let .success(rest, (leftExp, (_, rightExp))):
            return ParseResult.success(rest, Exp.plus(leftExp, rightExp))
        case .failure(let error):
            return ParseResult.failure(error)
        }
    }
} // plusP


// grammar:
// exp ::= integer '+' exp | integer
// Note: this is still slightly buggy; we end up parsing 1 + 2 + 3 as 1 + (2 + 3),
// instead of as (1 + 2) + 3.  This can be fixed by changing the grammar a bit.
// However, we won't get into this here; this is beyond the scope of the class.

func expressionP() -> Parser<Exp> {
    return orP(plusP(), integerP())
} // expressionP

print(expressionP()(MyList.cons(Token.integerToken(123),
                                MyList.empty)))
print(expressionP()(MyList.cons(Token.integerToken(123),
                                MyList.cons(Token.plusToken,
                                            MyList.cons(Token.integerToken(456),
                                                        MyList.empty)))))
print(expressionP()(MyList.cons(Token.integerToken(123),
                                MyList.cons(Token.plusToken,
                                            MyList.cons(Token.integerToken(456),
                                                        MyList.cons(Token.plusToken,
                                                                    MyList.cons(Token.integerToken(789),
                                                                                MyList.empty)))))))

             
