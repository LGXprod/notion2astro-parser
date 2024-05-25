import converter/body_parser
import converter/frontmatter
import gleam/result
import gleam/string

type DocumentError {
  CannotSplitDoc
}

fn split_notion_doc(text: String) -> Result(#(String, String), DocumentError) {
  case string.split(text, on: "\n\n") {
    [_, props, ..body] -> Ok(#(props, string.join(body, with: "\n\n")))
    _ -> Error(CannotSplitDoc)
  }
}

pub fn convert_to_astro(
  text: String,
  remove_props: List(String),
  list_props: List(String),
  add_fields: List(String),
  image_url_prefix: String,
) -> String {
  case split_notion_doc(text) {
    Ok(#(props, body)) -> {
      let doc_frontmatter =
        frontmatter.to_astro(
          props,
          remove_props,
          list_props,
          add_fields,
          frontmatter.get_date,
        )

      let doc_body = body_parser.to_astro(body, image_url_prefix)

      doc_frontmatter <> "\n\n" <> doc_body
    }
    _ -> text
  }
}
