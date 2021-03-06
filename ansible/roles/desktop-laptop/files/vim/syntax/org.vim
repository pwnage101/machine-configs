" Support org authoring markup as closely as possible
" (we're adding two markdown-like variants for =code= and blockquotes)
" -----------------------------------------------------------------------------

" Inline markup
" *bold*, /italic/, _underline_, +strike-through+, =code=, ~verbatim~
" Note:
" - /italic/ is rendered as reverse in most terms (works fine in gVim, though)
" - +strike-through+ doesn't work on Vim / gVim
" - the non-standard `code' markup is also supported
" - =code= and ~verbatim~ are also supported as block-level markup, see below.
" Ref: http://orgmode.org/manual/Emphasis-and-monospace.html
"syntax match org_bold /\*[^ ]*\*/

" FIXME: Always make org_bold syntax define before org_heading syntax
"        to make sure that org_heading syntax got higher priority(help :syn-priority) than org_bold.
"        If there is any other good solution, please help fix it.
syntax region org_bold      start="\S\@<=\*\|\*\S\@="   end="\S\@<=\*\|\*\S\@="  keepend oneline
syntax region org_italic    start="\S\@<=\/\|\/\S\@="   end="\S\@<=\/\|\/\S\@="  keepend oneline
syntax region org_underline start="\S\@<=_\|_\S\@="       end="\S\@<=_\|_\S\@="    keepend oneline
syntax region org_code      start="\S\@<==\|=\S\@="       end="\S\@<==\|=\S\@="    keepend oneline
syntax region org_code      start="\S\@<=`\|`\S\@="       end="\S\@<='\|'\S\@="    keepend oneline
syntax region org_verbatim  start="\S\@<=\~\|\~\S\@="     end="\S\@<=\~\|\~\S\@="  keepend oneline

hi def org_bold      term=bold      cterm=bold      gui=bold
hi def org_italic    term=italic    cterm=italic    gui=italic
hi def org_underline term=underline cterm=underline gui=underline

" Headings: {{{1
" Load Settings: {{{2
if !exists('g:org_heading_highlight_colors')
	let g:org_heading_highlight_colors = ['Title', 'Constant', 'Identifier', 'Statement', 'PreProc', 'Type', 'Special']
endif

if !exists('g:org_heading_highlight_levels')
	let g:org_heading_highlight_levels = len(g:org_heading_highlight_colors)
endif

if !exists('g:org_heading_shade_leading_stars')
	let g:org_heading_shade_leading_stars = 1
endif

" Enable Syntax HL: {{{2
unlet! s:i s:j s:contains
let s:i = 1
let s:j = len(g:org_heading_highlight_colors)
let s:contains = ' contains=org_timestamp,org_timestamp_inactive,org_subtask_percent,org_subtask_number,org_subtask_percent_100,org_subtask_number_all,org_list_checkbox,org_bold,org_italic,org_underline,org_code,org_verbatim'
if g:org_heading_shade_leading_stars == 1
	let s:contains = s:contains . ',org_shade_stars'
	syntax match org_shade_stars /^\*\{2,\}/me=e-1 contained
	hi def link org_shade_stars Ignore
else
	hi clear org_shade_stars
endif

while s:i <= g:org_heading_highlight_levels
	exec 'syntax match org_heading' . s:i . ' /^\*\{' . s:i . '\}\s.*/' . s:contains
	exec 'hi def link org_heading' . s:i . ' ' . g:org_heading_highlight_colors[(s:i - 1) % s:j]
	let s:i += 1
endwhile
unlet! s:i s:j s:contains

" Todo Keywords: {{{1
" Load Settings: {{{2
if !exists('g:org_todo_keywords')
	let g:org_todo_keywords = ['TODO', '|', 'DONE']
endif

if !exists('g:org_todo_keyword_faces')
	let g:org_todo_keyword_faces = []
endif

" Enable Syntax HL: {{{2
let s:todo_headings = ''
let s:i = 1
while s:i <= g:org_heading_highlight_levels
	if s:todo_headings == ''
		let s:todo_headings = 'containedin=org_heading' . s:i
	else
		let s:todo_headings = s:todo_headings . ',org_heading' . s:i
	endif
	let s:i += 1
endwhile
unlet! s:i

if !exists('g:loaded_org_syntax')
	let g:loaded_org_syntax = 1

	function! OrgExtendHighlightingGroup(base_group, new_group, settings)
		let l:base_hi = ''
		redir => l:base_hi
		silent execute 'highlight ' . a:base_group
		redir END
		let l:group_hi = substitute(split(l:base_hi, '\n')[0], '^' . a:base_group . '\s\+xxx', '', '')
		execute 'highlight ' . a:new_group . l:group_hi . ' ' . a:settings
	endfunction

	function! OrgInterpretFaces(faces)
		let l:res_faces = ''
		if type(a:faces) == 3
			let l:style = []
			for l:f in a:faces
				let l:_f = [l:f]
				if type(l:f) == 3
					let l:_f = l:f
				endif
				for l:g in l:_f
					if type(l:g) == 1 && l:g =~ '^:'
						if l:g !~ '[\t ]'
							continue
						endif
						let l:k_v = split(l:g)
						if l:k_v[0] == ':foreground'
							let l:gui_color = ''
							let l:found_gui_color = 0
							for l:color in split(l:k_v[1], ',')
								if l:color =~ '^#'
									let l:found_gui_color = 1
									let l:res_faces = l:res_faces . ' guifg=' . l:color
								elseif l:color != ''
									let l:gui_color = l:color
									let l:res_faces = l:res_faces . ' ctermfg=' . l:color
								endif
							endfor
							if ! l:found_gui_color && l:gui_color != ''
								let l:res_faces = l:res_faces . ' guifg=' . l:gui_color
							endif
						elseif l:k_v[0] == ':background'
							let l:gui_color = ''
							let l:found_gui_color = 0
							for l:color in split(l:k_v[1], ',')
								if l:color =~ '^#'
									let l:found_gui_color = 1
									let l:res_faces = l:res_faces . ' guibg=' . l:color
								elseif l:color != ''
									let l:gui_color = l:color
									let l:res_faces = l:res_faces . ' ctermbg=' . l:color
								endif
							endfor
							if ! l:found_gui_color && l:gui_color != ''
								let l:res_faces = l:res_faces . ' guibg=' . l:gui_color
							endif
						elseif l:k_v[0] == ':weight' || l:k_v[0] == ':slant' || l:k_v[0] == ':decoration'
							if index(l:style, l:k_v[1]) == -1
								call add(l:style, l:k_v[1])
							endif
						endif
					elseif type(l:g) == 1
						" TODO emacs interprets the color and automatically determines
						" whether it should be set as foreground or background color
						let l:res_faces = l:res_faces . ' ctermfg=' . l:k_v[1] . ' guifg=' . l:k_v[1]
					endif
				endfor
			endfor
			let l:s = ''
			for l:i in l:style
				if l:s == ''
					let l:s = l:i
				else
					let l:s = l:s . ','. l:i
				endif
			endfor
			if l:s != ''
				let l:res_faces = l:res_faces . ' term=' . l:s . ' cterm=' . l:s . ' gui=' . l:s
			endif
		elseif type(a:faces) == 1
			" TODO emacs interprets the color and automatically determines
			" whether it should be set as foreground or background color
			let l:res_faces = l:res_faces . ' ctermfg=' . a:faces . ' guifg=' . a:faces
		endif
		return l:res_faces
	endfunction

	function! s:ReadTodoKeywords(keywords, todo_headings)
		let l:default_group = 'Todo'
		for l:i in a:keywords
			if type(l:i) == 3
				call s:ReadTodoKeywords(l:i, a:todo_headings)
				continue
			endif
			if l:i == '|'
				let l:default_group = 'Question'
				continue
			endif
			" strip access key
			let l:_i = substitute(l:i, "\(.*$", "", "")

			let l:group = l:default_group
			for l:j in g:org_todo_keyword_faces
				if l:j[0] == l:_i
					let l:group = 'org_todo_keyword_face_' . l:_i
					call OrgExtendHighlightingGroup(l:default_group, l:group, OrgInterpretFaces(l:j[1]))
					break
				endif
			endfor
			exec 'syntax match org_todo_keyword_' . l:_i . ' /\*\{1,\}\s\{1,\}\zs' . l:_i .'\(\s\|$\)/ ' . a:todo_headings
			exec 'hi def link org_todo_keyword_' . l:_i . ' ' . l:group
		endfor
	endfunction
endif

call s:ReadTodoKeywords(g:org_todo_keywords, s:todo_headings)
unlet! s:todo_headings

" Timestamps: {{{1
"<2003-09-16 Tue>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \a\a\a>\)/
"<2003-09-16 Tue 12:00>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d>\)/
"<2003-09-16 Tue 12:00-12:30>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d-\d\d:\d\d>\)/

"<2003-09-16 Tue>--<2003-09-16 Tue>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \a\a\a>--<\d\d\d\d-\d\d-\d\d \a\a\a>\)/
"<2003-09-16 Tue 12:00>--<2003-09-16 Tue 12:00>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d>--<\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d>\)/

syn match org_timestamp /\(<%%(diary-float.\+>\)/

"[2003-09-16 Tue]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \a\a\a\]\)/
"[2003-09-16 Tue 12:00]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d\]\)/

"[2003-09-16 Tue]--[2003-09-16 Tue]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \a\a\a\]--\[\d\d\d\d-\d\d-\d\d \a\a\a\]\)/
"[2003-09-16 Tue 12:00]--[2003-09-16 Tue 12:00]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d\]--\[\d\d\d\d-\d\d-\d\d \a\a\a \d\d:\d\d\]\)/

syn match org_timestamp_inactive /\(\[%%(diary-float.\+\]\)/

hi def link org_timestamp PreProc
hi def link org_timestamp_inactive Comment

" Deadline And Schedule: {{{1
syn match org_deadline_scheduled /^\s*\(DEADLINE\|SCHEDULED\):/
hi def link org_deadline_scheduled PreProc

" Tables: {{{1
syn match org_table /^\s*|.*/ contains=org_timestamp,org_timestamp_inactive,hyperlink,org_table_separator,org_table_horizontal_line
syn match org_table_separator /\(^\s*|[-+]\+|\?\||\)/ contained
hi def link org_table_separator Type

" Hyperlinks: {{{1
syntax match hyperlink	"\[\{2}[^][]*\(\]\[[^][]*\)\?\]\{2}" contains=hyperlinkBracketsLeft,hyperlinkURL,hyperlinkBracketsRight containedin=ALL
syntax match hyperlinkBracketsLeft	contained "\[\{2}"     conceal
syntax match hyperlinkURL				    contained "[^][]*\]\[" conceal
syntax match hyperlinkBracketsRight	contained "\]\{2}"     conceal
hi def link hyperlink Underlined

" Comments: {{{1
syntax match org_comment /^#.*/
hi def link org_comment Comment

" Bullet Lists: {{{1
" Ordered Lists:
" 1. list item
" 1) list item
" a. list item
" a) list item
syn match org_list_ordered "^\s*\(\a\|\d\+\)[.)]\s" nextgroup=org_list_item
hi def link org_list_ordered Identifier

" Unordered Lists:
" - list item
" * list item
" + list item
" + and - don't need a whitespace prefix
syn match org_list_unordered "^\(\s*[-+]\|\s\+\*\)\s" nextgroup=org_list_item
hi def link org_list_unordered Identifier

" Definition Lists:
" - Term :: expl.
" 1) Term :: expl.
syntax match org_list_def /.*\s\+::/ contained
hi def link org_list_def PreProc

syntax match org_list_item /.*$/ contained contains=org_subtask_percent,org_subtask_number,org_subtask_percent_100,org_subtask_number_all,org_list_checkbox,org_bold,org_italic,org_underline,org_code,org_verbatim,org_timestamp,org_timestamp_inactive,org_list_def
syntax match org_list_checkbox /\[[ X-]]/ contained
hi def link org_list_bullet Identifier
hi def link org_list_checkbox     PreProc

" Block Delimiters: {{{1
syntax case ignore
syntax match  org_block_delimiter /^#+BEGIN_.*/
syntax match  org_block_delimiter /^#+END_.*/
syntax match  org_key_identifier  /^#+[^ ]*:/
syntax match  org_title           /^#+TITLE:.*/  contains=org_key_identifier
hi def link org_block_delimiter Comment
hi def link org_key_identifier  Comment
hi def link org_title           Title

" Block Markup: {{{1
" we consider all BEGIN/END sections as 'verbatim' blocks (inc. 'quote', 'verse', 'center')
" except 'example' and 'src' which are treated as 'code' blocks.
" Note: the non-standard '>' prefix is supported for quotation lines.
" Note: the '^:.*" rule must be defined before the ':PROPERTIES:' one below.
" TODO: http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
syntax match  org_verbatim /^\s*>.*/
syntax match  org_code     /^\s*:.*/
syntax region org_verbatim start="^#+BEGIN_.*"      end="^#+END_.*"      keepend contains=org_block_delimiter
syntax region org_code     start="^#+BEGIN_SRC"     end="^#+END_SRC"     keepend contains=org_block_delimiter
syntax region org_code     start="^#+BEGIN_EXAMPLE" end="^#+END_EXAMPLE" keepend contains=org_block_delimiter
hi def link org_code     String
hi def link org_verbatim String

" Properties: {{{1
syn region Error matchgroup=org_properties_delimiter start=/^\s*:PROPERTIES:\s*$/ end=/^\s*:END:\s*$/ contains=org_property keepend
syn match org_property /^\s*:[^\t :]\+:\s\+[^\t ]/ contained contains=org_property_value
syn match org_property_value /:\s\zs.*/ contained
hi def link org_properties_delimiter PreProc
hi def link org_property             Statement
hi def link org_property_value       Constant
" Break down subtasks
syntax match org_subtask_number /\[\d*\/\d*]/ contained
syntax match org_subtask_percent /\[\d*%\]/ contained
syntax match org_subtask_number_all /\[\(\d\+\)\/\1\]/ contained
syntax match org_subtask_percent_100 /\[100%\]/ contained

hi def link org_subtask_number String
hi def link org_subtask_percent String
hi def link org_subtask_percent_100 Identifier
hi def link org_subtask_number_all Identifier

" Plugin SyntaxRange: {{{1
" This only works if you have SyntaxRange installed:
" https://github.com/vim-scripts/SyntaxRange

" BEGIN_SRC
if exists('g:loaded_SyntaxRange')
  call SyntaxRange#Include('#+BEGIN_SRC\ vim', '#+END_SRC', 'vim', 'comment')
  call SyntaxRange#Include('#+BEGIN_SRC\ python', '#+END_SRC', 'python', 'comment')
  call SyntaxRange#Include('#+BEGIN_SRC\ c', '#+END_SRC', 'c', 'comment')
  " cpp must be below c, otherwise you get c syntax hl for cpp files
  call SyntaxRange#Include('#+BEGIN_SRC\ cpp', '#+END_SRC', 'cpp', 'comment')
  call SyntaxRange#Include('#+BEGIN_SRC\ ruby', '#+END_SRC', 'ruby', 'comment')
  " call SyntaxRange#Include('#+BEGIN_SRC\ lua', '#+END_SRC', 'lua', 'comment')
  " call SyntaxRange#Include('#+BEGIN_SRC\ lisp', '#+END_SRC', 'lisp', 'comment')

  " LaTeX
  call SyntaxRange#Include('\\begin[.*]{.*}', '\\end{.*}', 'tex')
  call SyntaxRange#Include('\\begin{.*}', '\\end{.*}', 'tex')
  call SyntaxRange#Include('\\\[', '\\\]', 'tex')
endif

" vi: ft=vim:tw=80:sw=4:ts=4:fdm=marker
