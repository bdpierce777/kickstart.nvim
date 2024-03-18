vim.cmd([[

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
endfunc

function! Is_whitespace(line)
    let s = getline(a:line)
    return Is_whitespace_core(s)
endfunc

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
endfunc

function! Subhead_list_to_ranges(subhead_list)

endfunc

func MyCompare(i1, i2)
   return a:i1[0] == a:i2[0] ? 0 : a:i1[0] > a:i2[0] ? 1 : -1
endfunc

func MyCompare2(i2, i1)
   return a:i2[0] == a:i1[0] ? 0 : a:i2[0] > a:i1[0] ? 1 : -1
endfunc

function! Create_sorted_list(range_list)
    let subhead_list = Range_to_list(a:range_list)
    call sort(subhead_list,"MyCompare")
    return subhead_list
endfunc

function! Range_to_list(range_list)
    let subhead_list = []
    for range_ in a:range_list
        let first_ = range_[0]
        let last_ = range_[1]
        let subheading = getline(first_, last_)
        call add(subhead_list, subheading)
    endfor
    return subhead_list
endfunc
function! Set_subheadings(full_range, sorted_list)
    if len(a:sorted_list) > 1
        let start_ = a:full_range[0]
        let end_ = a:full_range[1]
        let num = start_
        for list_ in a:sorted_list
            for ln in list_
                call setline(num, ln)
                let num += 1
            endfor
        endfor
    endif
endfunc
function! Join_subhead_list(subhead_list)
    let joined_list = []
    for i in a:subhead_list
        for j in i
            call add(joined_list, j)
        endfor
    endfor
    -- "echo string(joined_list)
    return joined_list
endfunc

function! Calc_main_range()
    let current = line('.')
    let last_ = line('$')
    let list_ = [current, last_]
    return list_ 
endfunc

function! Calc_heading_indent(range_)
    let current = a:range_[0]
    let indent_ = indent(current)
    return indent_
endfunc

function! Calc_main_heading_level(range_)
    let current = a:range_[0]
    let indent_ = indent(current)
    let level = Calc_heading_level(current)
    return level
endfunc

function! Calc_heading_level(line)
    if Is_whitespace(a:line)
        let hl = s:IS_WHITESPACE
    else
        let ind = indent(a:line)
        let hl = Indent_to_heading_level_core(ind)
        return hl
    endif
    return hl
endfunc

function! Indent_to_heading_level_core(ind)
    let hl = 0
    if a:ind % 4 == 0
        let hl = a:ind / 4
    else
        let hl = s:INVALID_LEVEL
    endif
    return hl
endfunc

function! Calc_next_indent(range_)
    let start_ = a:range_[0] + 1
    let last_ = a:range_[1]
    let first_indent = Calc_heading_indent(a:range_)
    let next_indent = 9999
    let indent_ =  -999
    let level =  -999
    for line_ in range(start_, last_)
        let indent_ = indent(line_)
        let level = Calc_heading_level(line_)
        if Is_whitespace(line_)
            continue
        elseif level == s:INVALID_LEVEL
        endif
        if indent_ > first_indent 
            if indent_ < next_indent
                let next_indent = indent_
            endif
        else
            break
        endif
    endfor
    if next_indent == 9999
        return s:NO_SUBHEADS
    else
        let next_level = Indent_to_heading_level_core(next_indent)
        if next_level == s:INVALID_LEVEL
            let next_indent = s:INVALID_LEVEL
        endif
        return next_indent
    endif
endfunc

function! Calc_next_level(range_)
    let start_ = a:range_[0]
    let last_ = a:range_[1]
    let next_indent =  Calc_next_indent(a:range_)
    if next_indent == s:NO_SUBHEADS
        return s:NO_SUBHEADS
    elseif next_indent == s:INVALID_LEVEL
        return s:INVALID_LEVEL
    else
        let next_level = Indent_to_heading_level_core(next_indent)
        return next_level
    endif

endfunc

function! Is_end_of_file(n)
    if a:n > line('$')
        return 1
    else
        return 0
    endif
endfunc

function! Calc_next_line(n)
    let next = a:n + 1
    if Is_end_of_file(next)
        return s:EOF
    else
        return next
    endif
endfunc

function! Calc_last_line(line_)
    if a:line_ == s:EOF
        return line('$'
    else return (a:line - 1)
    endfunc

    function! Calc_subhead_ranges(range_)
        let subhead_locations = Calc_subhead_locations(a:range_)
        let ranges = []
        if len(subhead_locations) <= 1
            return ranges
        endif
        let start_ = 1
        let end_ = len(subhead_locations) - 2
        for i in range(start_, end_)
            let first_ = subhead_locations[i]
            let next_ = subhead_locations[i+1]
            if next_ == s:EOF
                let last_ =  line('$')
            else
                let last_ = next_ - 1 
            endif
            let r = [first_, last_]
            let ranges += [r]
        endfor
        return ranges



    endfunc
    function! Calc_subhead_locations(range_)
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
            let indent_ = indent(line)
            let level = Calc_heading_level(line)
            if level == s:IS_WHITESPACE
                continue
            elseif indent_ < next_indent
                call extend(subhead_locations, [line])
                return subhead_locations

            elseif level == s:INVALID_LEVEL
                continue

            elseif indent_ > next_indent
                continue
            elseif level == next_level
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
        let line += 1
        let next_line = Calc_next_line(line)
        call extend(subhead_locations, [next_line])
        return subhead_locations

    endfunc

    function! Sort_subheads()
        echo "hello from Sort_subheads"
        return
        let range_ = Calc_main_range()
        call Sort_subheads_core(range_)
        return
    endfunc

    function! Sort_subheads_core(range_)
        echo "Sort_subheads_core() start"
        return
        let subhead_ranges = Calc_subhead_ranges(a:range_)
        let full_range = Calc_full_range(subhead_ranges)
        let sorted_list = Create_sorted_list(subhead_ranges)
        call Set_subheadings(full_range, sorted_list)
        return
        let subhead_list = Range_to_list(subhead_ranges)
        call Echo_list_of_list(subhead_list)
        let sorted_list = Create_sorted_list(subhead_ranges)
        return
        let joined_list = Join_subhead_list(sorted_list)
        for ln in joined_list
        endfor
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
    endfunc

    function! Calc_full_range(subhead_ranges)
        if len(a:subhead_ranges) < 1
            return []
        else
            let start_ = a:subhead_ranges[0][0]
            let end = (a:subhead_ranges[-1][1])
            let range_ = [start_, end]
            return range_
        endif

    endfunc




    function! Is_valid_range(range_)
        echo "Is_valid_range(".a:range_ . ")"
    endfunc

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
    endfunc

    function! Test_whitespace_conversion()
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
        let i = 0
        for ln in range(first_, last_)
            let s = ls2[i]
            call setline(ln, s)
            let i += 1
        endfor
        return
    endfunc

    function! Echo_list_of_list(ls)
        echo "Echo_list_of_list(start)"
        for ls2 in a:ls
            for ln in ls2
                echo ln
            endfor
        endfor
    endfunc
    function! Echo_list(ls)
        echo "Echo_list(start)"
        for ln in a:ls
            echo ln
        endfor
    endfunc

    function! User1()
        echo User1()
        return
        call Sort_subheads()
        return
    endfunc

    func Compare_subheadings(one, two)
        let first_a = a:one[0]
        let first_b = a:two[0]
        if first_a <# first_b
            return -1
        elseif first_a ==# first_b
            return 0
        else
            return 1
        endif
    endfunc
    let mapleader = ','
]])
