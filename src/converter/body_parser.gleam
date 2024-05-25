import gleam/list
import gleam/result
import gleam/string

type LinkError {
  InvalidMdLink
}

fn remove_last_element(
  elements: List(String),
  selected_elements: List(String),
) -> List(String) {
  case elements {
    [_] -> remove_last_element([], selected_elements)
    [a, ..b] -> remove_last_element(b, list.append(selected_elements, [a]))
    [] -> selected_elements
  }
}

fn get_filename_from_md_link(md_link: String) -> Result(String, LinkError) {
  let filename =
    string.split(md_link, on: "/")
    |> list.last()

  case filename {
    Ok(a) -> Ok(string.replace(a, ")", ""))
    _ -> Error(InvalidMdLink)
  }
}

pub fn fix_image_url(md_link: String, image_url_prefix: String) -> String {
  case get_filename_from_md_link(md_link) {
    Ok(filename) -> {
      let name = case string.split(filename, on: ".") {
        [a, ..b] -> {
          remove_last_element(b, [])
          |> list.append([a], _)
          |> string.join(with: ".")
        }
        [] -> ""
      }

      "![" <> name <> "](" <> image_url_prefix <> filename <> ")"
    }
    _ -> md_link
  }
}

fn update_local_image_urls(
  lines: List(String),
  image_url_prefix: String,
) -> List(String) {
  list.map(lines, fn(line) {
    case string.contains(line, "![") {
      True -> fix_image_url(line, image_url_prefix)
      False -> line
    }
  })
}

pub fn to_astro(body: String, image_url_prefix: String) -> String {
  string.split(body, on: "\n\n")
  |> update_local_image_urls(image_url_prefix)
  |> string.join(with: "\n\n")
}
