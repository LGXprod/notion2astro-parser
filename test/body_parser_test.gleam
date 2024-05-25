import converter/body_parser
import gleeunit/should

pub fn fix_image_url_test() {
  let md_link =
    "![Screenshot 2024-01-12 at 5.01.22 pm.png](Simple%20Graph%20Database%20Setup%20with%20Neo4j%20and%20Docker%20e037bfa05ed945ab81a876031c00f9a7/Screenshot_2024-01-12_at_5.01.22_pm.png)"

  body_parser.fix_image_url(md_link, "/images/blog/content/")
  |> should.equal(
    "![Screenshot_2024-01-12_at_5.01.22_pm](/images/blog/content/Screenshot_2024-01-12_at_5.01.22_pm.png)",
  )
}
