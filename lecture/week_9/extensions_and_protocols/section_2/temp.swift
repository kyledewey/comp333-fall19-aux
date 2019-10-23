indirect enum List<A> {
    case cons(A, List<A>)
    case empty
}

func map<A, B>(list: List<A>, f: (A) -> B) -> List<B> {
    // want: B
    // want: A
    switch list {
    case .cons(let head, let tail):
        // head: A
        // tail: List<A>
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
        // head: A
        // tail: List<A>
        // want: B (not accum)
        // way one: call f
        // way two: call foldLeft
        //return foldLeft(list: tail, accum: f(accum, head), f: f)

        return f(foldLeft(list: tail, accum: accum, f: f), head)
    case .empty:
        return accum
    }
    //return accum
}
