#!/usr/bin/env luajit

local ffi = require("ffi")

local c = ffi.load("libcmark")

ffi.cdef[[

  /* ## Simple Interface */
  char *cmark_markdown_to_html(const char *text, size_t len, int options);

 /* ## Node Structure */

  typedef enum {
  /* Error status */
  CMARK_NODE_NONE,

    /* Block */
    CMARK_NODE_DOCUMENT,
    CMARK_NODE_BLOCK_QUOTE,
    CMARK_NODE_LIST,
    CMARK_NODE_ITEM,
    CMARK_NODE_CODE_BLOCK,
    CMARK_NODE_HTML_BLOCK,
    CMARK_NODE_CUSTOM_BLOCK,
    CMARK_NODE_PARAGRAPH,
    CMARK_NODE_HEADING,
    CMARK_NODE_THEMATIC_BREAK,

    CMARK_NODE_FIRST_BLOCK = CMARK_NODE_DOCUMENT,
    CMARK_NODE_LAST_BLOCK = CMARK_NODE_THEMATIC_BREAK,

    /* Inline */
    CMARK_NODE_TEXT,
    CMARK_NODE_SOFTBREAK,
    CMARK_NODE_LINEBREAK,
    CMARK_NODE_CODE,
    CMARK_NODE_HTML_INLINE,
    CMARK_NODE_CUSTOM_INLINE,
    CMARK_NODE_EMPH,
    CMARK_NODE_STRONG,
    CMARK_NODE_LINK,
    CMARK_NODE_IMAGE,

    CMARK_NODE_FIRST_INLINE = CMARK_NODE_TEXT,
    CMARK_NODE_LAST_INLINE = CMARK_NODE_IMAGE,
  } cmark_node_type;

  typedef enum {
    CMARK_NO_LIST,
    CMARK_BULLET_LIST,
    CMARK_ORDERED_LIST
  } cmark_list_type;

  typedef enum {
    CMARK_NO_DELIM,
    CMARK_PERIOD_DELIM,
    CMARK_PAREN_DELIM
  } cmark_delim_type;

  typedef struct cmark_node cmark_node;
  typedef struct cmark_parser cmark_parser;
  typedef struct cmark_iter cmark_iter;
  typedef struct cmark_mem {
    void *(*calloc)(size_t, size_t);
    void *(*realloc)(void *, size_t);
    void (*free)(void *);
  } cmark_mem;

  /* ## Creating and Destroying Nodes */
  cmark_node *cmark_node_new(cmark_node_type type);
  cmark_node *cmark_node_new_with_mem(cmark_node_type type, cmark_mem *mem);
  void cmark_node_free(cmark_node *node);
  cmark_node *cmark_node_next(cmark_node *node);
  mark_node *cmark_node_previous(cmark_node *node);
  cmark_node *cmark_node_parent(cmark_node *node);
  cmark_node *cmark_node_first_child(cmark_node *node);
  cmark_node *cmark_node_last_child(cmark_node *node);


  /* ## Iterator */

  typedef enum {
    CMARK_EVENT_NONE,
    CMARK_EVENT_DONE,
    CMARK_EVENT_ENTER,
    CMARK_EVENT_EXIT
  } cmark_event_type;


  cmark_iter *cmark_iter_new(cmark_node *root);
  void cmark_iter_free(cmark_iter *iter);
  cmark_event_type cmark_iter_next(cmark_iter *iter);
  cmark_node *cmark_iter_get_node(cmark_iter *iter);
  cmark_event_type cmark_iter_get_event_type(cmark_iter *iter);
  cmark_node *cmark_iter_get_root(cmark_iter *iter);
  void cmark_iter_reset(cmark_iter *iter, cmark_node *current, cmark_event_type event_type);

  /* ## Accessors */

  void *cmark_node_get_user_data(cmark_node *node);
  int cmark_node_set_user_data(cmark_node *node, void *user_data);
  cmark_node_type cmark_node_get_type(cmark_node *node);
  const char *cmark_node_get_type_string(cmark_node *node);
  const char *cmark_node_get_literal(cmark_node *node);
  int cmark_node_set_literal(cmark_node *node, const char *content);
  int cmark_node_get_heading_level(cmark_node *node);
  int cmark_node_set_heading_level(cmark_node *node, int level);
  cmark_list_type cmark_node_get_list_type(cmark_node *node);
  int cmark_node_set_list_type(cmark_node *node,cmark_list_type type);
  cmark_delim_type cmark_node_get_list_delim(cmark_node *node);
  int cmark_node_set_list_delim(cmark_node *node,cmark_delim_type delim);
  int cmark_node_get_list_start(cmark_node *node);
  int cmark_node_set_list_start(cmark_node *node, int start);
  int cmark_node_get_list_tight(cmark_node *node);
  int cmark_node_set_list_tight(cmark_node *node, int tight);
  const char *cmark_node_get_fence_info(cmark_node *node);
  int cmark_node_set_fence_info(cmark_node *node, const char *info);
  const char *cmark_node_get_url(cmark_node *node);
  int cmark_node_set_url(cmark_node *node, const char *url);
  const char *cmark_node_get_title(cmark_node *node);
  int cmark_node_set_title(cmark_node *node, const char *title);
  const char *cmark_node_get_on_enter(cmark_node *node);
  int cmark_node_set_on_enter(cmark_node *node,const char *on_enter);
  const char *cmark_node_get_on_exit(cmark_node *node);
  int cmark_node_set_on_exit(cmark_node *node, const char *on_exit);
  int cmark_node_get_start_line(cmark_node *node);
  int cmark_node_get_start_column(cmark_node *node);
  int cmark_node_get_end_line(cmark_node *node);
  int cmark_node_get_end_column(cmark_node *node);

  /* ## Tree Manipulation */
  void cmark_node_unlink(cmark_node *node);
  int cmark_node_insert_before(cmark_node *node,cmark_node *sibling);
  int cmark_node_insert_after(cmark_node *node, cmark_node *sibling);
  int cmark_node_replace(cmark_node *oldnode, cmark_node *newnode);
  int cmark_node_prepend_child(cmark_node *node, cmark_node *child);
  int cmark_node_append_child(cmark_node *node, cmark_node *child);
  void cmark_consolidate_text_nodes(cmark_node *root);

  /* ## Parsing */
  cmark_parser *cmark_parser_new(int options);
  cmark_parser *cmark_parser_new_with_mem(int options, cmark_mem *mem);
  void cmark_parser_free(cmark_parser *parser);
  void cmark_parser_feed(cmark_parser *parser, const char *buffer, size_t len);
  cmark_node *cmark_parser_finish(cmark_parser *parser);
  cmark_node *cmark_parse_document(const char *buffer, size_t len, int options);
  cmark_node *cmark_parse_file(FILE *f, int options);


  /* ## Rendering */
  char *cmark_render_xml(cmark_node *root, int options);
  char *cmark_render_html(cmark_node *root, int options);
  char *cmark_render_man(cmark_node *root, int options, int width);
  char *cmark_render_commonmark(cmark_node *root, int options, int width);
  char *cmark_render_latex(cmark_node *root, int options, int width);

  /* ## Version information */
  int cmark_version(void);
  const char *cmark_version_string(void);

  ]]

local cmark = {}

local as_string = function(f)
   return function(x)
      local result = f(x)
      if result == nil then
         return ""
      else
         return ffi.string(result)
      end
   end
end

-- Simple Interface

cmark.markdown_to_html      = c.cmark_markdown_to_html

--[[
-- Node Structure
-- Error status
cmark.NONE      = c.CMARK_NODE_NONE

-- Block
cmark.DOCUMENT      = c.CMARK_NODE_DOCUMENT
cmark.BLOCK_QUOTE   = c.CMARK_NODE_BLOCK_QUOTE
cmark.LIST          = c.CMARK_NODE_LIST
cmark.ITEM          = c.CMARK_NODE_ITEM
cmark.CODE_BLOCK    = c.CMARK_NODE_CODE_BLOCK
cmark.HTML_BLOCK    = c.CMARK_NODE_HTML_BLOCK
cmark.CUSTOM_BLOCK  = c.CMARK_NODE_CUSTOM_BLOCK
cmark.PARAGRAPH     = c.CMARK_NODE_PARAGRAPH
cmark.HEADING       = c.CMARK_NODE_HEADING
cmark.THEMATIC_BREAK   = c.CMARK_NODE_THEMATIC_BREAK

cmark.FIRST_BLOCK   = c.CMARK_NODE_FIRST_BLOCK
cmark.LAST_BLOCK    = c.CMARK_NODE_LAST_BLOCK

-- Inline

cmark.TEXT          = c.CMARK_NODE_TEXT
cmark.SOFTBREAK     = c.CMARK_NODE_SOFTBREAK
cmark.LINEBREAK     = c.CMARK_NODE_LINEBREAK
cmark.CODE          = c.CMARK_NODE_CODE
cmark.HTML_INLINE   = c.CMARK_NODE_HTML_INLINE
cmark.CUSTOM_INLINE = c.CMARK_NODE_CUSTOM_INLINE
cmark.EMPH          = c.CMARK_NODE_EMPH
cmark.STRONG        = c.CMARK_NODE_STRONG
cmark.HTML_LINK     = c.CMARK_NODE_LINK
cmark.IMAGE         = c.CMARK_NODE_IMAGE
cmark.EMPH          = c.CMARK_NODE_EMPH
cmark.STRONG        = c.CMARK_NODE_STRONG

cmark.FIRST_INLINE  = c.CMARK_NODE_FIRST_INLINE
cmark.LAST_INLINE   = c.CMARK_NODE_LAST_INLINE

--lists types
cmark.NO_LIST       = c.CMARK_NO_LIST
cmark.BULLET_LIST   = c.CMARK_BULLET_LIST
cmark.ORDERED_LIST  = c.CMARK_ORDERED_LIST

--delim type
cmark.NO_DELIM       = c.CMARK_NO_DELIM
cmark.PERIOD_DELIM   = c.CMARK_PERIOD_DELIM
cmark.PAREN_DELIM    = c.CMARK_PAREN_DELIM

-- Creating and Destroying Nodes
-- cmark.markdown_to_html = as_string(c.cmark_markdown_to_html)
cmark.node_new = c.cmark_node_new
-- cmark_node *cmark_node_new_with_mem
cmark.node_free = c.cmark_node_free

-- Tree Traversal
cmark.node_next = c.cmark_node_next
cmark.node_previous = c.cmark_node_previous
cmark.node_parent = c.cmark_node_parent
cmark.node_first_child = c.cmark_node_first_child
cmark.node_last_child = c.cmark_node_last_child

-- Iterator
cmark.EVENT_NONE  = c.CMARK_EVENT_NONE
cmark.EVENT_DONE  = c.CMARK_EVENT_DONE
cmark.EVENT_ENTER = c.CMARK_EVENT_ENTER
cmark.EVENT_EXIT  = c.CMARK_EVENT_EXIT

cmark.iter_new  =  c.cmark_iter_new
cmark.iter_free =  c.cmark_iter_free
cmark.iter_next =  c.cmark_iter_next
cmark.iter_get_node =  c.cmark_iter_get_node
cmark.iter_get_event_type =  c.cmark_iter_get_event_type
cmark.iter_get_root =  c.cmark_iter_get_root
cmark.iter_reset =  c.cmark_iter_reset

-- Accessors

cmark.node_get_user_data =  c.cmark_node_get_user_data
cmark.node_set_user_data =  c.cmark_node_set_user_data
cmark.node_get_type =  c.cmark_node_get_type
cmark.node_get_type_string =  c.cmark_node_get_type_string
-- cmark.node_get_string_content =as_string(c.cmark_node_get_string_content)
cmark.node_get_literal =  c.cmark_node_get_literal
cmark.node_set_literal =  c.cmark_node_set_literal
cmark.node_get_heading_level   =  c.cmark_node_get_heading_level
cmark.node_set_heading_level   =  c.cmark_node_set_heading_level
cmark.node_node_set_list_type  =  c.cmark_node_set_list_type
cmark.node_node_get_list_delim =  c.cmark_node_get_list_delim
cmark.node_set_list_delim      =  c.cmark_node_set_list_delim
cmark.node_get_list_start      =  c.cmark_node_get_list_start
cmark.node_set_list_start      =  c.cmark_node_set_list_start
cmark.node_get_list_tight      =  c.cmark_node_get_list_tight
cmark.node_get_fence_info      =  c.cmark_node_get_fence_info
cmark.node_set_list_tight      =  c.cmark_node_set_list_tight
cmark.node_get_url      =  c.cmark_node_get_url
cmark.node_set_url      =  c.cmark_node_set_url
cmark.node_set_title      =  c.cmark_node_set_title
cmark.node_get_on_enter      =  c.cmark_node_get_on_enter
cmark.node_get_on_exit      =  c.cmark_node_get_on_exit
cmark.node_set_on_exit      =  c.cmark_node_set_on_exit
cmark.node_get_start_line      =  c.cmark_node_get_start_line
cmark.node_get_end_line      =  c.cmark_node_get_end_line
cmark.node_get_start_column     =  c.cmark_node_get_start_column
cmark.node_get_end_column     =  c.cmark_node_get_end_column

-- Tree Manipulation
cmark.node_unlink     =  c.cmark_node_unlink
cmark.node_insert_before     =  c.cmark_node_insert_before
cmark.node_insert_after     =  c.cmark_node_insert_after
cmark.node_prepend_child     =  c.cmark_node_prepend_child
cmark.node_append_child     =  c.cmark_node_append_child
cmark.consolidate_text_nodes    =  c.cmark_consolidate_text_nodes

-- Parsing
-- * Simple interface:
-- cmark.parse_document("Hello *world*", 13,CMARK_OPT_DEFAULT);
cmark.parser_new     =  c.cmark_parser_new
cmark.parser_new_with_mem     =  c.cmark_parser_new_with_mem
cmark.parser_free     =  c.cmark_parser_free
cmark.parser_new     =  c.cmark_parser_new
cmark.parser_new     =  c.cmark_parser_new
cmark.parser_feed     =  c.cmark_parser_feed
cmark.parser_finish    =  c.cmark_parser_finish
cmark.parser_feed     =  c.cmark_parse_document
cmark.cparse_file     =  c.cmark_parse_file

-- Rendering
cmark.render_xml     =  c.cmark_render_xml
cmark.render_html     =  c.cmark_render_html
cmark.render_commonmark   =  c.cmark_render_commonmark
cmark.render_latex     =  c.cmark_render_latex
--]]
-- Version information
cmark.version        =  c.cmark_version
cmark.version_string = c.cmark_version_string

--[[

local type_table = {
   'block_quote',
   'list',
   'list_item',
   'code_block',
   'html',
   'paragraph',
   'header',
   'hrule',
   'reference_def',
   'text',
   'softbreak',
   'linebreak',
   'inline_code',
   'inline_html',
   'emph',
   'strong',
   'link',
   'image',
}
type_table[0] = 'document'

local type_to_s = function(node)
   return type_table[tonumber(c.cmark_node_get_type(node))]
end

-- return node type as string
cmark.node_type = type_to_s

local can_have_children = function(node)
   local node_type = cmark.node_get_type(node)
   return (node_type == cmark.DOCUMENT or
           node_type == cmark.BLOCK_QUOTE or
           node_type == cmark.LIST or
           node_type == cmark.LIST_ITEM or
           node_type == cmark.HEADER or
           node_type == cmark.PARAGRAPH or
           node_type == cmark.REFERENCE_DEF or
           node_type == cmark.EMPH or
           node_type == cmark.STRONG or
           node_type == cmark.LINK or
           node_type == cmark.IMAGE)
end

cmark.can_have_children = can_have_children

local walk_ast = function(cur)
   collectgarbage("stop")  -- without this we get segfault on linux, why?
   while cur ~= nil do
      if can_have_children(cur) then
         coroutine.yield(cur, 'begin')
         child = cmark.node_first_child(cur)
         if child == nil then
            coroutine.yield(cur, 'end')
         end
      else
         coroutine.yield(cur, nil)
         child = nil
      end
      if child == nil then
         next = cmark.node_next(cur)
         while next == nil do
            cur = cmark.node_parent(cur)
            if cur == nil then
               break
            else
               coroutine.yield(cur, 'end')
               next = cmark.node_next(cur)
            end
         end
         cur = next
      else
         cur = child
      end
   end
   collectgarbage("restart")
end

cmark.walk = function(cur)
   local co = coroutine.create(function() walk_ast(cur) end)
   return function()  -- iterator
      local status, direction, node = coroutine.resume(co)
      return direction, node
   end
end
--]]
return cmark
