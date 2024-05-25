import gleam/list
import gleam/result
import gleam/string

fn remove_leading_spaces(chars: List(String)) -> List(String) {
  case chars {
    [" ", ..rest] -> remove_leading_spaces(rest)
    _ -> chars
  }
}

pub fn trim(text: String) -> String {
  let text_left_trimmed =
    string.split(text, on: "")
    |> remove_leading_spaces

  list.reverse(text_left_trimmed)
  |> remove_leading_spaces
  |> list.reverse()
  |> string.join(with: "")
}
