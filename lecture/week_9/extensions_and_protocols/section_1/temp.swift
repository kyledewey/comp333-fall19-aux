indirect enum List<A> {
    case cons(A, List<A>)
    case empty
}

func map<A, B>(list: List<A>, f: (A) -> B) -> List<B> {
    switch list {
    case .cons(let head, let tail):
        return List.cons(f(head), map(list: tail, f: f))
    case .empty:
        return List.empty
    }
}

func foldLeft<A, B>(list: List<A>,
                    accum: B,
                    f: (B, A) -> B) -> B {
    switch list {
    case .cons(let head, let tail):
        return foldLeft(list: tail, accum: f(accum, head), f: f)
    case .empty:
        return accum
    }
}

let list = List.cons(1, List.cons(2, List.cons(3, List.empty)))
//                                          (a, e) => a + e
let result = foldLeft(list: list, accum: 0, f: { (a, e) in a + e })
print(result)
