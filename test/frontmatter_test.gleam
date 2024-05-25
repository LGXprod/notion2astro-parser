import gleam/result
import gleeunit/should

import converter/frontmatter

pub fn string_format_test() {
  "Name: Test Name"
  |> frontmatter.enclose_frontmatter_value(#("\"", "\""))
  |> should.be_ok()
  |> should.equal("Name: \"Test Name\"")

  "Name:   Test Name  "
  |> frontmatter.enclose_frontmatter_value(#("\"", "\""))
  |> should.be_ok()
  |> should.equal("Name: \"Test Name\"")

  "Name Test Name"
  |> frontmatter.enclose_frontmatter_value(#("\"", "\""))
  |> should.be_error()
}

pub fn list_format_test() {
  "Tags: tag1, tag 2,  tag3"
  |> frontmatter.format_list()
  |> should.be_ok()
  |> should.equal("Tags: [\"tag1\", \"tag 2\", \"tag3\"]")

  "Tags: tag1"
  |> frontmatter.format_list()
  |> should.be_ok()
  |> should.equal("Tags: [\"tag1\"]")

  "Tags tag1"
  |> frontmatter.enclose_frontmatter_value(#("\"", "\""))
  |> should.be_error()
}

pub fn to_astro_test() {
  ["prop1: abc", "prop2: def", "prop3: 1, 2, 3", "prop4: ghi"]
  |> frontmatter.fix_notion_props(["prop2"], ["prop3"])
  |> should.equal([
    "prop1: \"abc\"", "prop3: [\"1\", \"2\", \"3\"]", "prop4: \"ghi\"",
  ])
}

pub fn convert_to_frontmatter_test() {
  let date = frontmatter.get_date()

  let result = "---
layout: ../../layouts/BlogPostLayout.astro
title: \"Simple Graph Database Setup with Neo4j and Docker\"
subtitle: \"A Tutorial on Neo4j Docker Configuration, Environment Variables, and Memory Management\"
Tags: [\"Docker\", \"Neo4j\", \"Tutorial\"]
pubDate: " <> date <> "
---"

  let notion_props =
    "
  Priority: P1
  Difficulty: Easy
  Status: Published
  Created time: November 20, 2023 10:24 PM
  Last edited time: January 13, 2024 2:06 PM
  Collections: Databases, Graphs
  Tags: Docker, Neo4j, Tutorial

  "

  let remove_props = [
    "Difficulty", "Status", "Created time", "Last edited time", "Collections",
    "Priority",
  ]

  let add_props = [
    "layout: ../../layouts/BlogPostLayout.astro",
    "title: \"Simple Graph Database Setup with Neo4j and Docker\"",
    "subtitle: \"A Tutorial on Neo4j Docker Configuration, Environment Variables, and Memory Management\"",
  ]

  let tag_props = ["Tags"]

  frontmatter.to_astro(notion_props, remove_props, tag_props, add_props, fn() {
    date
  })
  |> should.equal(result)
}
