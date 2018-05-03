#!/usr/bin/env luajit

local ffi = require("ffi")

local c = ffi.load("libcmark")

ffi.cdef[[

  /*  Simple Interface */
  char *cmark_markdown_to_html(const char *text, size_t len, int options);

  /* Version information */
  int cmark_version(void);
  const char *cmark_version_string(void);

  ]]

local cmark = {}

-- Simple Interface
cmark.markdown_to_html  = c.cmark_markdown_to_html

-- Version information
cmark.version        =  c.cmark_version
cmark.version_string = c.cmark_version_string

return cmark
