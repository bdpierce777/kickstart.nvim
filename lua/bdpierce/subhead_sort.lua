vim.cmd{[[
let s:NO_SUBHEADS = -3
let s:IS_WHITESPACE = -2
let s:INVALID_LEVEL = -1
let s:EOF = -1

function! Isspace_(c)
    let b = stridx(" \t\n\r\f", a:c)
    if b == -1
        return 0
    else
        return 1
    endif
endfunction

function! Is_whitespace(line)
    let s = getline(a:line)
    return Is_whitespace_core(s)
endfunction

function! Is_whitespace_core(s)
    let l = len(a:s)
    for i in range(len(a:s))
        let c = strpart(a:s, i, 1)
        let b = Isspace_(c)
        if !b
            return 0
        endif
    endfor
    return 1
endfunction

function! Subhead_list_to_ranges(subhead_list)

endfunction

function! Create_sorted_list(range_list)
    " Convert to lists of lines
    "echo "Create_sorted_list(start)"
    "echo "\trange = " . string(a:range_list)
    let subhead_list = Range_to_list(a:range_list)
    "echo "-"
    "echo "subhead_list:"
    "echo string(subhead_list)
    "echo "-"

    " Sort by the heading line (assumes the heading is the first line)
    call sort(subhead_list,'MyCompare')
    "call subheadings->sort(function("MyCompare"))
    "echo "SORTED subhead_list:"
    "echo string(subhead_list)
    "echo "-"
    return subhead_list

    " Now subheadings contains the sorted subheadings
endfunction

function! Range_to_list(range_list)
    "echo "Range_to_list(start)"
    "echo "\trange_list = " . string(a:range_list)
    let subhead_list = []
    for range_ in a:range_list
        let first_ = range_[0]
        let last_ = range_[1]
        let subheading = getline(first_, last_)
        " Add the subheadings to the subheadings list
        call add(subhead_list, subheading)
    endfor
    return subhead_list
endfunction
function! Set_subheadings(full_range, sorted_list)
    "echo "Subhead_list_to_ranges(start)"
    if len(a:sorted_list) > 1
        let start_ = a:full_range[0]
        let end_ = a:full_range[1]
        let num = start_
        for list_ in a:sorted_list
            for ln in list_
                "echo "\t\tnum, ln = " . num . "\n\t\t" . ln
                call setline(num, ln)
                let num += 1
            endfor
        endfor
    endif
endfunction
" ORIGINAL VERSION - code was duplicated
"function! Range_to_list(range_list)
"    let subhead_list = []
"    for range_ in a:range_list
"        let subhead = []
"        let first = range_[0]
"        let last_ = range_[1]
"        for line in range(first, last_)
"            call add(subhead, getline(line))
"        endfor
"        call extend(subhead_list, [subhead])
"        " I don't believe this case would ever happen, but I did write the code(??)
"        "if subhead != []
"        "    call extend(subhead_list, [subhead])
"        "    "echo "modified subhead_list == " . string(subhead_list)
"        "endif
"    endfor
"    "echo "Range_to_list() returning " . string(subhead_list)
"    return subhead_list
"endfunction

function! Join_subhead_list(subhead_list)
    let joined_list = []
    "echo ">>> " . string(a:subhead_list)
    for i in a:subhead_list
        for j in i
            "echo "\t\t".j
            call add(joined_list, j)
        endfor
    endfor
    "echo "joined_list:"
    "echo string(joined_list)
    return joined_list
endfunction
function! MyCompare(i1, i2)
   return a:i1[0] == a:i2[0] ? 0 : a:i1[0] > a:i2[0] ? 1 : -1
endfunc
"eval mylist->sort("MyCompare")

function! Calc_main_range()
    let current = line('.')
    let last_ = line('$')
    let list_ = [current, last_]
    return list_ 
endfunction

function! Calc_heading_indent(range_)
    let current = a:range_[0]
    let indent_ = indent(current)
    return indent_
endfunction

function! Calc_main_heading_level(range_)
    let current = a:range_[0]
    let indent_ = indent(current)
    let level = Calc_heading_level(current)
    "echo "Calc_main_heading_level() =>\t"."curent line = ".current."\tindent = ".indent_."\tlevel = ".level
    return level
endfunction

function! Calc_heading_level(line)
    " PREFERRED is Calc_heading_level() which also tests for whitespace
    if Is_whitespace(a:line)
        let hl = s:IS_WHITESPACE
    else
        let ind = indent(a:line)
        let hl = Indent_to_heading_level_core(ind)
        return hl
    endif
    "echo "Calc_heading_level(".a:line.") => ".hl
    return hl
endfunction

function! Indent_to_heading_level_core(ind)
    " PREFERRED is Calc_heading_level() which also tests for whitespace
    "echo "Calc_heading_level_core(start) <-- " . a:ind
    let hl = 0
    if a:ind % 4 == 0
        "echo "\t\t hl =".string(a:ind / 4)
        let hl = a:ind / 4
    else
        "echo "\t\t invalid level"
        let hl = s:INVALID_LEVEL
    endif
    return hl
endfunction

function! Calc_next_indent(range_)
    "echo "Calc_next_indent(start)"
    let start_ = a:range_[0] + 1
    let last_ = a:range_[1]
    "let level = Get_heading_level(a:range_)
    let first_indent = Calc_heading_indent(a:range_)
    "let current_level = Get_heading_level(a:range_)
    let next_indent = 9999
    "echo "range = ".start_."\t".last_
    let indent_ =  -999
    let level =  -999
    "echo "line_, indent_, level, next_indent"
    for line_ in range(start_, last_)
        "echo line_ . "(-1) " .  indent_ . " " . level . " " . next_indent
        let indent_ = indent(line_)
        "echo "\tindent_ =".indent_
        let level = Calc_heading_level(line_)
        "echo "\t-> " . indent_ . " -> " . level
        if Is_whitespace(line_)
            "echo "whitespace"
            continue
        elseif level == s:INVALID_LEVEL
            "echo "invalid level"
        endif
        if indent_ > first_indent 
            if indent_ < next_indent
                let next_indent = indent_
                "echo "next_indent change ---> "indent_ . " " . level . " " . next_indent
            endif
        else
            "if an equal or higher level heading is encountered
            "we are done with the loop
            break
        endif
    endfor
    if next_indent == 9999
        "echo "Calc_next_indent()\treturning\t" . s:NO_SUBHEADS
        return s:NO_SUBHEADS
    else
        let next_level = Indent_to_heading_level_core(next_indent)
        if next_level == s:INVALID_LEVEL
            let next_indent = s:INVALID_LEVEL
            "echo "returning invalid indent"
        endif
        "echo "Calc_next_indent()\treturning\t" . next_indent
        return next_indent
    endif
endfunction

function! Calc_next_level(range_)
    "echo "Calc_next_level passed range_ ==>".string(a:range_)
    let start_ = a:range_[0]
    let last_ = a:range_[1]
    let next_indent =  Calc_next_indent(a:range_)
    if next_indent == s:NO_SUBHEADS
        "echo "\t\t no subheads"
        return s:NO_SUBHEADS
    elseif next_indent == s:INVALID_LEVEL
        "echo "\t\t invalid level"
        return s:INVALID_LEVEL
    else
        let next_level = Indent_to_heading_level_core(next_indent)
        "echo "Calc_next_level()\treturning\t".next_level
        return next_level
    endif

endfunction

function! Is_end_of_file(n)
    if a:n > line('$')
        return 1
    else
        return 0
    endif
endfunction

function! Calc_next_line(n)
    let next = a:n + 1
    if Is_end_of_file(next)
        return s:EOF
    else
        return next
    endif
endfunction

function! Calc_last_line(line_)
if a:line_ == s:EOF
    return line('$'
else return (a:line - 1)
endfunction

function! Calc_subhead_ranges(range_)
    "echo "Calc_subhead_ranges(start)"
    let subhead_locations = Calc_subhead_locations(a:range_)
    "echo "\tsubhead_locations\treturned\t".string(subhead_locations)
    let ranges = []
    if len(subhead_locations) <= 1
        "echo "invalid range ==> Done!!"
        return ranges
    endif
    let start_ = 1
    let end_ = len(subhead_locations) - 2
    "echo "\tstart_, end_ = " . start_ . ", " . end_
    "echo "\tsubhead_locations" . string(subhead_locations)
    for i in range(start_, end_)
        "we skip the first location which is the main heading
        "echo "\t\t" . string(subhead_locations)
        "echo "i = " . i
        "echo string(subhead_locations[i])
        let first_ = subhead_locations[i]
        "echo "first_ = " . first_
        let next_ = subhead_locations[i+1]
        if next_ == s:EOF
            let last_ =  line('$')
        else
            let last_ = next_ - 1 
        endif
        let r = [first_, last_]
        let ranges += [r]
        "echo "first_, last_ == " . string(first_) . "\t" .  string(last_)
        "echo "i = " . string(i)
        "echo "ranges = " . string(ranges)
    endfor
    "echo "Calc_subhead_ranges() returning " . string(ranges)
    return ranges

    

endfunction
function! Calc_subhead_locations(range_)
    "the first location == the main heading
    "   could be omitted, but it could also be useful
    "   leaving it in because it gives a complete picture
    "       we can use it to calculate the full range of the main heading
    "       but mainly we will ignore it and work with the subhead ranges
    "the last location == the next line after the last in the range
    "   generally we will subtract 1 to get the end of the last range
    "   but this value could also represent the EOF
    "       and then the last line of the file is theend of the last range
    "
    "problem #1 - 0 subheadings >>> next_level == 999 because 
    "echo "Calc_subhead_locations(start)"
    let start_ = a:range_[0]
    let last_ = a:range_[1]
    let first_indent = Calc_heading_indent(a:range_)
    let level = Calc_main_heading_level(a:range_)
    let next_indent = Calc_next_indent(a:range_)
    let next_level = Calc_next_level(a:range_)

    if next_level == s:NO_SUBHEADS
        return [start_]
    elseif next_level == s:INVALID_LEVEL
        echo "WARNING - invalid level encountered in Sort_subheads()"
        echo "\tPROBABLY NOT WHAT THE USER INTENDED TO HAPPEN!"
        return [start_]
    endif
    let subhead_locations = [start_]
    for line in range((start_ + 1), last_)
        " WE NEED TO KNOW BOTH INDENT AND LEVEL
        let indent_ = indent(line)
        let level = Calc_heading_level(line)
        if level == s:IS_WHITESPACE
            continue
        elseif indent_ < next_indent
            "case one - we have encountered a higher level heading {lower indent}
            call extend(subhead_locations, [line])
            return subhead_locations

        elseif level == s:INVALID_LEVEL
            continue

        elseif indent_ > next_indent
            continue
        elseif level == next_level
            " the only other case
            if level == next_level
                call extend(subhead_locations, [line])
            endif
        else
            echo "WARNING - logical error in Calc_subhead_locations()"
            if level == next_level
                call extend(subhead_locations, [line])
            endif
        endif
    endfor
    "case two - the loop finished without finding a higher level heading {lower indent}
    "   we add the next_line after the range or we add an EOL
    let line += 1
    let next_line = Calc_next_line(line)
    call extend(subhead_locations, [next_line])
    return subhead_locations

endfunction

function! Sort_subheads()
    "echo "Sort_subheads(start)"
    "range will be set from cursor to last line
    let range_ = Calc_main_range()
    call Sort_subheads_core(range_)
    return
endfunction

function! Sort_subheads_core(range_)
    "let level = Calc_main_heading_level(a:range_)
    "let next_level = Calc_next_level(a:range_)
    "let subhead_locations = Calc_subhead_locations(a:range_)
    "echo "Sort_subheads_core(start)"
    "let st = a:range_[0]
    "let lst = a:range_[1]
    "echo "st, lst = " . st . " " . lst
    "for ln in range(st, lst)
    "    echo ln . " -> " . indent(ln)
    "endfor
    let subhead_ranges = Calc_subhead_ranges(a:range_)
    "echo "\tsubhead_ranges = ".string(subhead_ranges)
    let full_range = Calc_full_range(subhead_ranges)
    "echo "\tfull_range = ".string(full_range)
    let sorted_list = Create_sorted_list(subhead_ranges)
    "echo "\tsorted_list = ".string(sorted_list)
    "echo "CALLING SET_SUBHEADINGS"
    call Set_subheadings(full_range, sorted_list)
    " TODO: why doesn't this work - doesn't like the list!!
    "if len(sorted_list) > 1
    "    let start_ = full_range[0]
    "    call setline(start_, sorted_list)
    "endif
    return
    let subhead_list = Range_to_list(subhead_ranges)
    "echo "\n"
    "echo "\n"
    "echo "subhead_list:"
    "echo string(subhead_list)
    "echo "\n"
    call Echo_list_of_list(subhead_list)
    let sorted_list = Create_sorted_list(subhead_ranges)
    return
    "echo "--------------"
    "echo "sorted list:"
    "echo string(sorted_list)
    let joined_list = Join_subhead_list(sorted_list)
    "echo "joined list:"
    "echo string(joined_list)
    for ln in joined_list
        "echo ln
    endfor
    "echo "--------------"
    "echo "Done?!"
    "echo "--------------"
    return
    return
    let main_range = [current, last]
    
    
    echo "Sort_subheads()"."\tlevel = ".level."\tnext_level = ".next_level
    echo "Sort_subheads_core()"
    echo "Done?? - Next Step!!"
    return
    return
    if Is_valid_range(a:range_)
        Sort_subheads_core(a:range_)
    endif
endfunction

function! Calc_full_range(subhead_ranges)
    "expecting a list of ranges for each subhead with its sub-subheadings
    "simply returns the first element of the first range with
    "   the last element of the last range
    if len(a:subhead_ranges) < 1
        return []
    else
        let start_ = a:subhead_ranges[0][0]
        let end = (a:subhead_ranges[-1][1])
        let range_ = [start_, end]
        "echo "Calc_full_range = ".string(range_)
        return range_
    endif

endfunction




function! Is_valid_range(range_)
    echo "Is_valid_range(".a:range_ . ")"
endfunction

function! Test_is_whitespace()
    for n in range(1, line("$"))
        let s = getline(n)
        echo s
        let r = Is_whitespace(n)
        if r == 1
            echo "whitespace"
        else
            echo "not whitespace"
        endif
    endfor
    "let s = input("any string")
endfunction

function! Test_whitespace_conversion()
    "this code works and reverses the lines in the buffer
    "note buffer lines are 1-based while lists are 0-based
    let ls = []
    let first_ = 1
    let last_ = line('$')
    for ln in range(first_, last_)
        let s = getline(ln)
        call add(ls, s)
    endfor
    let ls2 = []
    for ln in ls
        call insert(ls2, ln)
    endfor
    "for ln in ls2
    "    echo ln
    "endfor
    let i = 0
    "let first_ = 0
    "let last_ -= 1
    for ln in range(first_, last_)
        let s = ls2[i]
        call setline(ln, s)
        let i += 1
    endfor
    return
endfunction

function! Echo_list_of_list(ls)
    echo "Echo_list_of_list(start)"
    for ls2 in a:ls
        for ln in ls2
            echo ln
        endfor
    endfor
endfunction
function! Echo_list(ls)
    echo "Echo_list(start)"
    for ln in a:ls
        echo ln
    endfor
endfunction

function! User1()
    "call Test_whitespace_conversion()
    "return
    call Sort_subheads()
    return
    "works
    let subheadings = [[3,2],[4,3],[2,1]]
    "eval sort(subheadings,'Compare_subheadings')
    call sort(subheadings,'Compare_subheadings')
    echo string(subheadings)
    return
    "call Main_heading(current, last)
    "return
    "echo "Done!"
    "return
    "echo "head_level"
    "echo head_level
endfunction

function Compare_subheadings(one, two)
    let first_a = a:one[0]
    let first_b = a:two[0]
    if first_a <# first_b
        return -1
    elseif first_a ==# first_b
        return 0
    else
        return 1
endfunction
"    return
"
"    let s = getline(1)
"    let l = len(s)
"    for i in range(len(s))
"        let p = strpart(s, i, 1)
"        echo "p = " . p
"    endfor
"    return
"
"    let b = -1
"    let x = Isspace_('x')
"    echo "Isspace_() == " . x
"    let x = Isspace_('\t')
"    echo "Isspace_() == " . x
"    let x = Is_whitespace_core('dog')
"    echo "Is_whitespace() == " . x
"    let x = Is_whitespace_core('\t\t\t')
"    echo "Is_whitespace() == " . x
"    let x = Is_whitespace_core('  \n')
"    echo "Is_whitespace() == " . x
"    
"endfunction
echo('kbmap being sourced')

]]}

