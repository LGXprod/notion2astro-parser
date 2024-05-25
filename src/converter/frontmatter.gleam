import gleam/io
import gleam/list
import gleam/result
import gleam/string

import birl

import utils/text

pub type NotionError {
  InvalidProp
}

pub fn get_date() {
  let date = birl.to_iso8601(birl.now())

  case string.split(date, on: "T") {
    [date, _] -> {
      case string.split(date, on: "-") {
        [year, month, day] -> day <> "-" <> month <> "-" <> year
        _ -> ""
      }
    }
    _ -> ""
  }
}

fn get_notion_key_value(prop: String) -> Result(#(String, String), NotionError) {
  let colon_split_text = string.split(prop, on: ":")

  case colon_split_text {
    [_] -> Error(InvalidProp)
    [a, b] -> Ok(#(a, b))
    [a, ..rest] -> Ok(#(a, string.join(rest, with: ":")))
    _ -> Error(InvalidProp)
  }
}

pub fn enclose_frontmatter_value(
  line: String,
  enclosure: #(String, String),
) -> Result(String, NotionError) {
  case get_notion_key_value(line) {
    Error(error) -> Error(error)
    Ok(key_value) -> {
      let #(start_val, end_val) = enclosure
      let #(key, value) = key_value

      let formatted_value = start_val <> text.trim(value) <> end_val
      Ok(key <> ": " <> formatted_value)
    }
  }
}

pub fn format_list(line: String) -> Result(String, NotionError) {
  case get_notion_key_value(line) {
    Error(error) -> Error(error)
    Ok(key_value) -> {
      let #(key, value) = key_value
      let formatted_value =
        value
        |> text.trim()
        |> string.split(on: ", ")
        |> list.map(fn(a) { "\"" <> text.trim(a) <> "\"" })
        |> string.join(with: ", ")
        |> fn(a) { "[" <> a <> "]" }

      Ok(key <> ": " <> formatted_value)
    }
  }
}

pub fn fix_notion_props(
  lines: List(String),
  remove_props: List(String),
  list_props: List(String),
) -> List(String) {
  let filtered_lines =
    list.filter(lines, fn(line) {
      let prop =
        list.find(remove_props, fn(a) { string.contains(line, a) })
        |> result.unwrap("not found")

      case prop {
        "not found" -> True
        _ -> False
      }
    })

  list.map(filtered_lines, fn(line) {
    let is_tag_prop =
      list.find(list_props, fn(a) { string.contains(line, a) })
      |> result.unwrap("not found")
      |> fn(a) { a != "not found" }

    case is_tag_prop {
      True -> result.unwrap(format_list(line), "")
      False -> result.unwrap(enclose_frontmatter_value(line, #("\"", "\"")), "")
    }
  })
}

pub fn to_astro(
  notion_props: String,
  remove_props: List(String),
  list_props: List(String),
  add_fields: List(String),
  get_date: fn() -> String,
) -> String {
  notion_props
  |> text.trim()
  |> string.split(on: "\n")
  |> list.filter(fn(a) { a != "" })
  |> list.map(fn(a) { text.trim(a) })
  |> fix_notion_props(remove_props, list_props)
  |> list.append(add_fields, _)
  |> list.append(["pubDate: " <> get_date()])
  |> list.append(["---"])
  |> list.append(["---"], _)
  |> string.join(with: "\n")
}
