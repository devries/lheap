import gleam/io
import gleam/int
import gleam/list

pub fn main() {
  io.println("Hello from lheap!")
  let tree =
    new()
    |> insert_list([#(2, Nil), #(1, Nil), #(3, Nil), #(5, Nil), #(4, Nil)])

  io.debug(tree)

  let r = pop(tree)
  case r {
    Error(_) -> io.println("There was an error")
    Ok(#(t, v, _)) -> {
      io.debug(popall(t, []))
      io.println("Found: " <> int.to_string(v))
    }
  }
}

pub opaque type Tree(element) {
  Null
  Node(
    key: Int,
    s: Int,
    left: Tree(element),
    right: Tree(element),
    payload: element,
  )
}

pub fn merge(a: Tree(element), b: Tree(element)) -> Tree(element) {
  case a, b {
    Null, Null -> Null
    Null, _ -> b
    _, Null -> a
    Node(a_key, _, a_left, a_right, a_payload), Node(b_key, _, _, _, _) -> {
      case a_key > b_key {
        True -> merge(b, a)
        False -> {
          let newright = merge(a_right, b)
          case a_left, newright {
            Null, Node(_, _, _, _, _) ->
              Node(
                key: a_key,
                s: 1,
                left: newright,
                right: a_left,
                payload: a_payload,
              )
            Node(_, l_s, _, _, _), Node(_, r_s, _, _, _) if l_s < r_s ->
              Node(
                key: a_key,
                s: l_s + 1,
                left: newright,
                right: a_left,
                payload: a_payload,
              )
            _, Node(_, r_s, _, _, _) ->
              Node(
                key: a_key,
                s: r_s + 1,
                left: a_left,
                right: newright,
                payload: a_payload,
              )
            _, _ -> Null
          }
        }
      }
    }
  }
}

pub fn new() -> Tree(element) {
  Null
}

pub fn insert(a: Tree(element), value: Int, payload: element) -> Tree(element) {
  let b = Node(value, 1, Null, Null, payload)
  merge(a, b)
}

pub fn insert_list(
  a: Tree(element),
  values: List(#(Int, element)),
) -> Tree(element) {
  case values {
    [] -> a
    [first, ..rest] -> {
      let n = insert(a, first.0, first.1)
      insert_list(n, rest)
    }
  }
}

pub fn pop(a: Tree(element)) -> Result(#(Tree(element), Int, element), Nil) {
  case a {
    Null -> Error(Nil)
    Node(val, _, left, right, payload) ->
      Ok(#(merge(left, right), val, payload))
  }
}

fn popall(a: Tree(element), acc: List(#(Int, element))) -> List(#(Int, element)) {
  let r = pop(a)
  case r {
    Error(_) -> list.reverse(acc)
    Ok(#(t, v, p)) -> {
      popall(t, [#(v, p), ..acc])
    }
  }
}
