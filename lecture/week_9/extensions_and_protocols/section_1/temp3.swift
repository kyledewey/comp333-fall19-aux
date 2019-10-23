enum Foo<A> {
    case foo(A)
}

extension Foo {
    func getA() -> A {
        switch self {
        case .foo(let a):
            return a
        }
    }
}
