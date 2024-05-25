import gleeunit/should

import utils/text

pub fn trim_text_test() {
  // test leading and ending spaces are removed, but spaces between chars aren't
  text.trim("   ab cd  ")
  |> should.equal("ab cd")

  // if n number of spaces are the only chars present the result should be an empty string
  text.trim("   ")
  |> should.equal("")

  // an empty string should produce an empty string
  text.trim("")
  |> should.equal("")
}
