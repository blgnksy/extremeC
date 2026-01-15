#==============================================================================
#
#   Comprehensive GDB Configuration for C, C++, and Python
#
#   Based on STL GDB evaluators/views/utilities - 1.03
#   Extended with threading, memory, GStreamer/DeepStream, and Python support
#
#   Usage: source ~/.gdbinit or copy to ~/.gdbinit
#   Type 'help user-defined' to see all custom commands
#
#==============================================================================

#==============================================================================
# GENERAL SETTINGS
#==============================================================================

set pagination off
set print thread-events off
set breakpoint pending on
set disassemble-next-line on
set confirm off
set verbose off

# History
set history save on
set history size 10000
set history filename ~/.gdb_history

# Print settings
set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off
set print array-indexes on
set print elements 0
set print null-stop on

# Assembly flavor
set disassembly-flavor intel

#==============================================================================
# EXCEPTION & ERROR CATCHING
#==============================================================================

catch throw
catch catch

# Uncomment these if you want to break on every throw/terminate
# break __cxa_throw
# break std::terminate
# break abort

# C error functions
# break __assert_fail
# break __stack_chk_fail

#==============================================================================
# SIGNAL HANDLING
#==============================================================================

# Default signal handling for multimedia/pipeline applications
define signals_multimedia
    handle SIGPIPE nostop noprint pass
    handle SIGUSR1 nostop noprint pass
    handle SIGUSR2 nostop noprint pass
    handle SIG32 nostop noprint pass
    handle SIG33 nostop noprint pass
    handle SIG34 nostop noprint pass
    printf "Signal handling configured for multimedia debugging\n"
    printf "SIGPIPE, SIGUSR1, SIGUSR2, SIG32-34: nostop noprint pass\n"
end
document signals_multimedia
    Configure signal handling for multimedia/GStreamer applications.
    Ignores common signals that would otherwise interrupt debugging.
end

define signals_default
    handle SIGPIPE stop print pass
    handle SIGUSR1 stop print pass
    handle SIGUSR2 stop print pass
    printf "Signal handling reset to defaults\n"
end
document signals_default
    Reset signal handling to GDB defaults.
end

define signals_show
    info signals
end
document signals_show
    Show current signal handling configuration.
end

#==============================================================================
# STL CONTAINERS: std::vector<>
#==============================================================================

define pvector
    if $argc == 0
        help pvector
    else
        set $size = $arg0._M_impl._M_finish - $arg0._M_impl._M_start
        set $capacity = $arg0._M_impl._M_end_of_storage - $arg0._M_impl._M_start
        set $size_max = $size - 1
    end
    if $argc == 1
        set $i = 0
        while $i < $size
            printf "elem[%u]: ", $i
            p *($arg0._M_impl._M_start + $i)
            set $i++
        end
    end
    if $argc == 2
        set $idx = $arg1
        if $idx < 0 || $idx > $size_max
            printf "idx1, idx2 are not in acceptable range: [0..%u].\n", $size_max
        else
            printf "elem[%u]: ", $idx
            p *($arg0._M_impl._M_start + $idx)
        end
    end
    if $argc == 3
        set $start_idx = $arg1
        set $stop_idx = $arg2
        if $start_idx > $stop_idx
            set $tmp_idx = $start_idx
            set $start_idx = $stop_idx
            set $stop_idx = $tmp_idx
        end
        if $start_idx < 0 || $stop_idx < 0 || $start_idx > $size_max || $stop_idx > $size_max
            printf "idx1, idx2 are not in acceptable range: [0..%u].\n", $size_max
        else
            set $i = $start_idx
            while $i <= $stop_idx
                printf "elem[%u]: ", $i
                p *($arg0._M_impl._M_start + $i)
                set $i++
            end
        end
    end
    if $argc > 0
        printf "Vector size = %u\n", $size
        printf "Vector capacity = %u\n", $capacity
        printf "Element "
        whatis $arg0._M_impl._M_start
    end
end
document pvector
    Prints std::vector<T> information.
    Syntax: pvector <vector> <idx1> <idx2>
    Note: idx, idx1 and idx2 must be in acceptable range [0..<vector>.size()-1].
    Examples:
    pvector v - Prints vector content, size, capacity and T typedef
    pvector v 0 - Prints element[idx] from vector
    pvector v 1 2 - Prints elements in range [idx1..idx2] from vector
end

#==============================================================================
# STL CONTAINERS: std::list<>
#==============================================================================

define plist
    if $argc == 0
        help plist
    else
        set $head = &$arg0._M_impl._M_node
        set $current = $arg0._M_impl._M_node._M_next
        set $size = 0
        while $current != $head
            if $argc == 2
                printf "elem[%u]: ", $size
                p *($arg1*)($current + 1)
            end
            if $argc == 3
                if $size == $arg2
                    printf "elem[%u]: ", $size
                    p *($arg1*)($current + 1)
                end
            end
            set $current = $current._M_next
            set $size++
        end
        printf "List size = %u \n", $size
        if $argc == 1
            printf "List "
            whatis $arg0
            printf "Use plist <variable_name> <element_type> to see the elements in the list.\n"
        end
    end
end
document plist
    Prints std::list<T> information.
    Syntax: plist <list> <T> <idx>: Prints list size, if T defined all elements or just element at idx
    Examples:
    plist l - prints list size and definition
    plist l int - prints all elements and list size
    plist l int 2 - prints the third element in the list (if exists) and list size
end

define plist_member
    if $argc == 0
        help plist_member
    else
        set $head = &$arg0._M_impl._M_node
        set $current = $arg0._M_impl._M_node._M_next
        set $size = 0
        while $current != $head
            if $argc == 3
                printf "elem[%u]: ", $size
                p (*($arg1*)($current + 1)).$arg2
            end
            if $argc == 4
                if $size == $arg3
                    printf "elem[%u]: ", $size
                    p (*($arg1*)($current + 1)).$arg2
                end
            end
            set $current = $current._M_next
            set $size++
        end
        printf "List size = %u \n", $size
        if $argc == 1
            printf "List "
            whatis $arg0
            printf "Use plist_member <variable_name> <element_type> <member> to see the elements in the list.\n"
        end
    end
end
document plist_member
    Prints std::list<T> member information.
    Syntax: plist_member <list> <T> <member> <idx>
    Examples:
    plist_member l int member - prints all elements and list size
    plist_member l int member 2 - prints the third element in the list (if exists) and list size
end

#==============================================================================
# STL CONTAINERS: std::map<> and std::multimap<>
#==============================================================================

define pmap
    if $argc == 0
        help pmap
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Map "
            whatis $tree
            printf "Use pmap <variable_name> <left_element_type> <right_element_type> to see the elements in the map.\n"
        end
        if $argc == 3
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u].left: ", $i
                p *($arg1*)$value
                set $value = $value + sizeof($arg1)
                printf "elem[%u].right: ", $i
                p *($arg2*)$value
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 4
            set $idx = $arg3
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u].left: ", $i
                    p *($arg1*)$value
                    set $value = $value + sizeof($arg1)
                    printf "elem[%u].right: ", $i
                    p *($arg2*)$value
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        if $argc == 5
            set $idx1 = $arg3
            set $idx2 = $arg4
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                set $valueLeft = *($arg1*)$value
                set $valueRight = *($arg2*)($value + sizeof($arg1))
                if $valueLeft == $idx1 && $valueRight == $idx2
                    printf "elem[%u].left: ", $i
                    p $valueLeft
                    printf "elem[%u].right: ", $i
                    p $valueRight
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Map size = %u\n", $tree_size
    end
end
document pmap
    Prints std::map<TLeft and TRight> or std::multimap<TLeft and TRight> information.
    Syntax: pmap <map> <TtypeLeft> <TypeRight> <valLeft> <valRight>
    Examples:
    pmap m - prints map size and definition
    pmap m int int - prints all elements and map size
    pmap m int int 20 - prints the element(s) with left-value = 20 (if any) and map size
    pmap m int int 20 200 - prints the element(s) with left-value = 20 and right-value = 200
end

define pmap_member
    if $argc == 0
        help pmap_member
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Map "
            whatis $tree
            printf "Use pmap <variable_name> <left_element_type> <right_element_type> to see the elements in the map.\n"
        end
        if $argc == 5
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u].left: ", $i
                p (*($arg1*)$value).$arg2
                set $value = $value + sizeof($arg1)
                printf "elem[%u].right: ", $i
                p (*($arg3*)$value).$arg4
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 6
            set $idx = $arg5
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u].left: ", $i
                    p (*($arg1*)$value).$arg2
                    set $value = $value + sizeof($arg1)
                    printf "elem[%u].right: ", $i
                    p (*($arg3*)$value).$arg4
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Map size = %u\n", $tree_size
    end
end
document pmap_member
    Prints std::map<TLeft and TRight> member information.
    Syntax: pmap_member <map> <TtypeLeft> <memberLeft> <TypeRight> <memberRight> <valLeft>
    Examples:
    pmap_member m class1 member1 class2 member2 - prints class1.member1 : class2.member2
    pmap_member m class1 member1 class2 member2 lvalue - prints where class1 == lvalue
end

#==============================================================================
# STL CONTAINERS: std::set<> and std::multiset<>
#==============================================================================

define pset
    if $argc == 0
        help pset
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Set "
            whatis $tree
            printf "Use pset <variable_name> <element_type> to see the elements in the set.\n"
        end
        if $argc == 2
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u]: ", $i
                p *($arg1*)$value
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 3
            set $idx = $arg2
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u]: ", $i
                    p *($arg1*)$value
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Set size = %u\n", $tree_size
    end
end
document pset
    Prints std::set<T> or std::multiset<T> information.
    Syntax: pset <set> <T> <val>
    Examples:
    pset s - prints set size and definition
    pset s int - prints all elements and the size of s
    pset s int 20 - prints the element(s) with value = 20 (if any) and the size of s
end

#==============================================================================
# STL CONTAINERS: std::deque<>
#==============================================================================

define pdequeue
    if $argc == 0
        help pdequeue
    else
        set $size = 0
        set $start_cur = $arg0._M_impl._M_start._M_cur
        set $start_last = $arg0._M_impl._M_start._M_last
        set $start_stop = $start_last
        while $start_cur != $start_stop
            p *$start_cur
            set $start_cur++
            set $size++
        end
        set $finish_first = $arg0._M_impl._M_finish._M_first
        set $finish_cur = $arg0._M_impl._M_finish._M_cur
        set $finish_last = $arg0._M_impl._M_finish._M_last
        if $finish_cur < $finish_last
            set $finish_stop = $finish_cur
        else
            set $finish_stop = $finish_last
        end
        while $finish_first != $finish_stop
            p *$finish_first
            set $finish_first++
            set $size++
        end
        printf "Dequeue size = %u\n", $size
    end
end
document pdequeue
    Prints std::dequeue<T> information.
    Syntax: pdequeue <dequeue>
    Elements are listed "left to right" (front to back)
    Example: pdequeue d
end

#==============================================================================
# STL CONTAINERS: std::stack<>
#==============================================================================

define pstack
    if $argc == 0
        help pstack
    else
        set $start_cur = $arg0.c._M_impl._M_start._M_cur
        set $finish_cur = $arg0.c._M_impl._M_finish._M_cur
        set $size = $finish_cur - $start_cur
        set $i = $size - 1
        while $i >= 0
            p *($start_cur + $i)
            set $i--
        end
        printf "Stack size = %u\n", $size
    end
end
document pstack
    Prints std::stack<T> information.
    Syntax: pstack <stack>
    Elements are listed "top to bottom" (top-most is first to pop)
    Example: pstack s
end

#==============================================================================
# STL CONTAINERS: std::queue<>
#==============================================================================

define pqueue
    if $argc == 0
        help pqueue
    else
        set $start_cur = $arg0.c._M_impl._M_start._M_cur
        set $finish_cur = $arg0.c._M_impl._M_finish._M_cur
        set $size = $finish_cur - $start_cur
        set $i = 0
        while $i < $size
            p *($start_cur + $i)
            set $i++
        end
        printf "Queue size = %u\n", $size
    end
end
document pqueue
    Prints std::queue<T> information.
    Syntax: pqueue <queue>
    Elements are listed "front to back" (front is first to pop)
    Example: pqueue q
end

#==============================================================================
# STL CONTAINERS: std::priority_queue<>
#==============================================================================

define ppqueue
    if $argc == 0
        help ppqueue
    else
        set $size = $arg0.c._M_impl._M_finish - $arg0.c._M_impl._M_start
        set $capacity = $arg0.c._M_impl._M_end_of_storage - $arg0.c._M_impl._M_start
        set $i = $size - 1
        while $i >= 0
            p *($arg0.c._M_impl._M_start + $i)
            set $i--
        end
        printf "Priority queue size = %u\n", $size
        printf "Priority queue capacity = %u\n", $capacity
    end
end
document ppqueue
    Prints std::priority_queue<T> information.
    Syntax: ppqueue <priority_queue>
    Elements are listed "top to bottom" (top-most is first to pop)
    Example: ppqueue pq
end

#==============================================================================
# STL CONTAINERS: std::bitset<>
#==============================================================================

define pbitset
    if $argc == 0
        help pbitset
    else
        p /t $arg0._M_w
    end
end
document pbitset
    Prints std::bitset<n> information.
    Syntax: pbitset <bitset>
    Example: pbitset b
end

#==============================================================================
# STL CONTAINERS: std::string and std::wstring
#==============================================================================

define pstring
    if $argc == 0
        help pstring
    else
        printf "String \t\t\t= \"%s\"\n", $arg0._M_data()
        printf "String size/length \t= %u\n", $arg0._M_rep()._M_length
        printf "String capacity \t= %u\n", $arg0._M_rep()._M_capacity
        printf "String ref-count \t= %d\n", $arg0._M_rep()._M_refcount
    end
end
document pstring
    Prints std::string information (pre-C++11 COW implementation).
    Syntax: pstring <string>
    Example: pstring s
end

define pwstring
    if $argc == 0
        help pwstring
    else
        call printf("WString \t\t= \"%ls\"\n", $arg0._M_data())
        printf "WString size/length \t= %u\n", $arg0._M_rep()._M_length
        printf "WString capacity \t= %u\n", $arg0._M_rep()._M_capacity
        printf "WString ref-count \t= %d\n", $arg0._M_rep()._M_refcount
    end
end
document pwstring
    Prints std::wstring information (pre-C++11 COW implementation).
    Syntax: pwstring <wstring>
    Example: pwstring s
end

# C++11 SSO string (most modern implementations)
define pstring11
    if $argc == 0
        help pstring11
    else
        printf "String: \"%s\"\n", $arg0.c_str()
        printf "Size: %zu\n", $arg0.size()
        printf "Capacity: %zu\n", $arg0.capacity()
    end
end
document pstring11
    Prints std::string information (C++11 SSO implementation).
    Syntax: pstring11 <string>
    Example: pstring11 s
end

#==============================================================================
# C++11/14/17 SMART POINTERS
#==============================================================================

define pshared
    if $argc == 0
        help pshared
    else
        printf "=== std::shared_ptr ===\n"
        printf "Pointer:    %p\n", $arg0._M_ptr
        if $arg0._M_ptr != 0
            printf "Use count:  %d\n", $arg0._M_refcount._M_pi->_M_use_count
            printf "Weak count: %d\n", $arg0._M_refcount._M_pi->_M_weak_count
            printf "Value:\n"
            p *$arg0._M_ptr
        else
            printf "  (nullptr)\n"
        end
    end
end
document pshared
    Print std::shared_ptr details including reference counts.
    Syntax: pshared <shared_ptr_var>
    Example: pshared my_shared_ptr
end

define punique
    if $argc == 0
        help punique
    else
        printf "=== std::unique_ptr ===\n"
        set $ptr = $arg0._M_t._M_t._M_head_impl
        printf "Pointer: %p\n", $ptr
        if $ptr != 0
            printf "Value:\n"
            p *$ptr
        else
            printf "  (nullptr)\n"
        end
    end
end
document punique
    Print std::unique_ptr details.
    Syntax: punique <unique_ptr_var>
    Example: punique my_unique_ptr
end

define pweak
    if $argc == 0
        help pweak
    else
        printf "=== std::weak_ptr ===\n"
        printf "Pointer:    %p\n", $arg0._M_ptr
        if $arg0._M_refcount._M_pi != 0
            printf "Use count:  %d\n", $arg0._M_refcount._M_pi->_M_use_count
            printf "Weak count: %d\n", $arg0._M_refcount._M_pi->_M_weak_count
            printf "Expired:    %s\n", $arg0._M_refcount._M_pi->_M_use_count == 0 ? "yes" : "no"
        end
    end
end
document pweak
    Print std::weak_ptr details.
    Syntax: pweak <weak_ptr_var>
    Example: pweak my_weak_ptr
end

#==============================================================================
# C++17 TYPES: std::optional, std::variant, std::string_view
#==============================================================================

define poptional
    if $argc < 2
        help poptional
    else
        printf "=== std::optional ===\n"
        if $arg0._M_engaged
            printf "Status: engaged\n"
            printf "Value: "
            p *($arg1*)&($arg0._M_payload._M_payload)
        else
            printf "Status: empty (nullopt)\n"
        end
    end
end
document poptional
    Print std::optional details.
    Syntax: poptional <optional_var> <contained_type>
    Example: poptional my_opt int
end

define pstring_view
    if $argc == 0
        help pstring_view
    else
        printf "=== std::string_view ===\n"
        printf "Data:   %p\n", $arg0._M_str
        printf "Length: %zu\n", $arg0._M_len
        if $arg0._M_len > 0 && $arg0._M_len < 1000
            printf "Content: \"%.*s\"\n", (int)$arg0._M_len, $arg0._M_str
        end
    end
end
document pstring_view
    Print std::string_view details.
    Syntax: pstring_view <string_view_var>
    Example: pstring_view sv
end

#==============================================================================
# C DEBUGGING: MEMORY INSPECTION
#==============================================================================

define hexdump
    if $argc < 2
        printf "Usage: hexdump <address> <num_bytes>\n"
    else
        set $addr = (unsigned char*)$arg0
        set $len = $arg1
        set $i = 0
        while $i < $len
            if ($i % 16) == 0
                printf "\n0x%08lx: ", (unsigned long)($addr + $i)
            end
            printf "%02x ", $addr[$i]
            if ($i % 16) == 7
                printf " "
            end
            set $i = $i + 1
        end
        # Print ASCII representation
        printf "\n"
    end
end
document hexdump
    Hexdump memory region.
    Syntax: hexdump <address> <num_bytes>
    Example: hexdump buffer 64
end

define hexdump_ascii
    if $argc < 2
        printf "Usage: hexdump_ascii <address> <num_bytes>\n"
    else
        set $addr = (unsigned char*)$arg0
        set $len = $arg1
        set $i = 0
        while $i < $len
            if ($i % 16) == 0
                if $i > 0
                    printf " |"
                    set $j = $i - 16
                    while $j < $i
                        set $c = $addr[$j]
                        if $c >= 32 && $c < 127
                            printf "%c", $c
                        else
                            printf "."
                        end
                        set $j = $j + 1
                    end
                    printf "|\n"
                end
                printf "0x%08lx: ", (unsigned long)($addr + $i)
            end
            printf "%02x ", $addr[$i]
            if ($i % 16) == 7
                printf " "
            end
            set $i = $i + 1
        end
        # Handle remaining ASCII
        set $rem = $i % 16
        if $rem != 0
            set $pad = 16 - $rem
            while $pad > 0
                printf "   "
                if $pad == 9
                    printf " "
                end
                set $pad = $pad - 1
            end
        end
        printf " |"
        set $start = $i - ($rem == 0 ? 16 : $rem)
        while $start < $i
            set $c = $addr[$start]
            if $c >= 32 && $c < 127
                printf "%c", $c
            else
                printf "."
            end
            set $start = $start + 1
        end
        printf "|\n"
    end
end
document hexdump_ascii
    Hexdump memory region with ASCII representation.
    Syntax: hexdump_ascii <address> <num_bytes>
    Example: hexdump_ascii buffer 64
end

define ascii
    if $argc == 0
        printf "Usage: ascii <address> [length]\n"
    else
        if $argc == 1
            x/s $arg0
        else
            printf "%.*s\n", $arg1, (char*)$arg0
        end
    end
end
document ascii
    Print memory as ASCII string.
    Syntax: ascii <address> [max_length]
    Example: ascii str_ptr 100
end

define vmmap
    shell cat /proc/`pidof -s $(ps -p $PPID -o comm=)`/maps 2>/dev/null || cat /proc/$PPID/maps 2>/dev/null || echo "Memory map not available (no /proc?)"
end
document vmmap
    Show process memory map from /proc/<pid>/maps.
    Usage: vmmap
end

define malloc_info
    call (void)malloc_info(0, stdout)
end
document malloc_info
    Print malloc statistics (glibc).
    Usage: malloc_info
end

define heap_info
    call (void)malloc_stats()
end
document heap_info
    Print heap statistics (glibc).
    Usage: heap_info
end

#==============================================================================
# C DEBUGGING: DATA STRUCTURES
#==============================================================================

# Print array with count
define parray
    if $argc < 2
        printf "Usage: parray <array_ptr> <count> [start_idx]\n"
    else
        set $arr = $arg0
        set $count = $arg1
        set $start = 0
        if $argc == 3
            set $start = $arg2
        end
        set $i = $start
        while $i < $start + $count
            printf "[%d]: ", $i
            p $arr[$i]
            set $i = $i + 1
        end
        printf "Array elements printed: %d\n", $count
    end
end
document parray
    Print C array elements.
    Syntax: parray <array_ptr> <count> [start_idx]
    Example: parray my_array 10
    Example: parray my_array 5 10  (prints elements 10-14)
end

# Linked list traversal for C
define clist
    if $argc < 2
        printf "Usage: clist <head_ptr> <next_member>\n"
        printf "Example: clist my_list next\n"
    else
        set $node = $arg0
        set $count = 0
        set $max = 1000
        while $node != 0 && $count < $max
            printf "[%d] %p: ", $count, $node
            p *$node
            set $node = $node->$arg1
            set $count = $count + 1
        end
        if $count >= $max
            printf "Warning: Stopped at %d nodes (possible cycle?)\n", $max
        end
        printf "Total nodes: %d\n", $count
    end
end
document clist
    Traverse and print a C linked list.
    Syntax: clist <head_ptr> <next_member_name>
    Example: clist head next
end

# Print struct/union offsets
define offsets
    if $argc == 0
        printf "Usage: offsets <type>\n"
    else
        ptype /o $arg0
    end
end
document offsets
    Print struct/union member offsets.
    Syntax: offsets <type_name>
    Example: offsets "struct my_struct"
end

#==============================================================================
# THREAD DEBUGGING
#==============================================================================

define btall
    thread apply all bt
end
document btall
    Print backtrace for all threads.
    Usage: btall
end

define threads_info
    printf "=== Thread Summary ===\n"
    info threads
    printf "\n=== Brief Backtraces ===\n"
    thread apply all bt 3
end
document threads_info
    Show all threads with brief backtraces.
    Usage: threads_info
end

define threads_full
    printf "=== Full Thread Backtraces ===\n"
    thread apply all bt full
end
document threads_full
    Show all threads with full backtraces including locals.
    Usage: threads_full
end

define tswitch
    if $argc != 1
        printf "Usage: tswitch <thread_num>\n"
    else
        thread $arg0
        frame
        list
    end
end
document tswitch
    Switch to thread and show context.
    Syntax: tswitch <thread_number>
    Example: tswitch 2
end

define find_deadlock
    printf "=== Threads potentially blocked on locks ===\n"
    printf "Looking for: __lll_lock_wait, pthread_mutex_lock, futex, sem_wait...\n\n"
    thread apply all bt 8
    printf "\n=== Check for threads with 'lock_wait', 'futex', or 'sem_' in backtrace ===\n"
end
document find_deadlock
    Help identify threads blocked on locks (potential deadlock).
    Usage: find_deadlock
end

define mutex_info
    if $argc == 0
        printf "Usage: mutex_info <pthread_mutex_t*>\n"
    else
        printf "=== pthread_mutex_t ===\n"
        printf "Lock value: %d\n", ((pthread_mutex_t*)$arg0)->__data.__lock
        printf "Owner TID:  %d\n", ((pthread_mutex_t*)$arg0)->__data.__owner
        printf "Count:      %d\n", ((pthread_mutex_t*)$arg0)->__data.__count
        printf "Kind:       %d (0=normal, 1=recursive, 2=errorcheck)\n", ((pthread_mutex_t*)$arg0)->__data.__kind
    end
end
document mutex_info
    Print pthread_mutex_t internals (glibc/NPTL).
    Syntax: mutex_info <mutex_ptr>
    Example: mutex_info &my_mutex
end

#==============================================================================
# BREAKPOINT HELPERS
#==============================================================================

define bp
    if $argc == 0
        info breakpoints
    else
        break $arg0
    end
end
document bp
    Set breakpoint or list all breakpoints.
    Syntax: bp [location]
    Example: bp main
    Example: bp (lists all)
end

define bpc
    if $argc < 2
        printf "Usage: bpc <location> <condition>\n"
        printf "Example: bpc main.c:42 'x > 100'\n"
    else
        break $arg0 if $arg1
    end
end
document bpc
    Set conditional breakpoint.
    Syntax: bpc <location> <condition>
    Example: bpc process_data 'size > 1000'
end

define bpt
    if $argc == 0
        printf "Usage: bpt <location>\n"
    else
        tbreak $arg0
    end
end
document bpt
    Set temporary breakpoint (auto-deletes after hit).
    Syntax: bpt <location>
    Example: bpt main
end

define bpregex
    if $argc == 0
        printf "Usage: bpregex <pattern>\n"
    else
        rbreak $arg0
    end
end
document bpregex
    Set breakpoint on all functions matching regex.
    Syntax: bpregex <regex_pattern>
    Example: bpregex process_.*
end

define bp_save
    if $argc == 0
        save breakpoints ~/.gdb_breakpoints
        printf "Breakpoints saved to ~/.gdb_breakpoints\n"
    else
        save breakpoints $arg0
        printf "Breakpoints saved to %s\n", "$arg0"
    end
end
document bp_save
    Save breakpoints to file.
    Syntax: bp_save [filename]
    Default: ~/.gdb_breakpoints
end

define bp_load
    if $argc == 0
        source ~/.gdb_breakpoints
        printf "Breakpoints loaded from ~/.gdb_breakpoints\n"
    else
        source $arg0
        printf "Breakpoints loaded from %s\n", "$arg0"
    end
end
document bp_load
    Load breakpoints from file.
    Syntax: bp_load [filename]
    Default: ~/.gdb_breakpoints
end

define bpd
    if $argc == 0
        disable breakpoints
        printf "All breakpoints disabled\n"
    else
        disable $arg0
    end
end
document bpd
    Disable breakpoint(s).
    Syntax: bpd [breakpoint_num]
    Example: bpd 3
    Example: bpd (disables all)
end

define bpe
    if $argc == 0
        enable breakpoints
        printf "All breakpoints enabled\n"
    else
        enable $arg0
    end
end
document bpe
    Enable breakpoint(s).
    Syntax: bpe [breakpoint_num]
    Example: bpe 3
    Example: bpe (enables all)
end

#==============================================================================
# WATCHPOINT HELPERS
#==============================================================================

define ww
    if $argc == 0
        printf "Usage: ww <expression>\n"
    else
        watch $arg0
        printf "Write watchpoint set on: %s\n", "$arg0"
    end
end
document ww
    Set write watchpoint (break when value changes).
    Syntax: ww <variable_or_expression>
    Example: ww my_var
    Example: ww *ptr
end

define wr
    if $argc == 0
        printf "Usage: wr <expression>\n"
    else
        rwatch $arg0
        printf "Read watchpoint set on: %s\n", "$arg0"
    end
end
document wr
    Set read watchpoint (break when value is read).
    Syntax: wr <variable_or_expression>
    Example: wr my_var
end

define wa
    if $argc == 0
        printf "Usage: wa <expression>\n"
    else
        awatch $arg0
        printf "Access watchpoint set on: %s\n", "$arg0"
    end
end
document wa
    Set access watchpoint (break on read or write).
    Syntax: wa <variable_or_expression>
    Example: wa my_var
end

#==============================================================================
# CALL STACK HELPERS
#==============================================================================

define ctx
    printf "=== Current Context ===\n"
    frame
    printf "\n=== Source ===\n"
    list
    printf "\n=== Arguments ===\n"
    info args
    printf "\n=== Locals ===\n"
    info locals
end
document ctx
    Show current execution context (frame, source, args, locals).
    Usage: ctx
end

define btf
    bt full
end
document btf
    Backtrace with all local variables.
    Usage: btf
end

define up_n
    if $argc != 1
        printf "Usage: up_n <count>\n"
    else
        set $i = 0
        while $i < $arg0
            up
            set $i = $i + 1
        end
    end
end
document up_n
    Go up N stack frames.
    Syntax: up_n <count>
    Example: up_n 3
end

define down_n
    if $argc != 1
        printf "Usage: down_n <count>\n"
    else
        set $i = 0
        while $i < $arg0
            down
            set $i = $i + 1
        end
    end
end
document down_n
    Go down N stack frames.
    Syntax: down_n <count>
    Example: down_n 3
end

define args
    info args
end
document args
    Show current function arguments.
    Usage: args
end

define locals
    info locals
end
document locals
    Show current function local variables.
    Usage: locals
end

#==============================================================================
# EXCEPTION DEBUGGING (C++)
#==============================================================================

define check_exception
    if $argc != 1
        printf "Usage: check_exception <frame_number>\n"
        printf "Use when stopped at __cxa_throw\n"
    else
        frame $arg0
        printf "=== Registers (x86-64) ===\n"
        printf "RDI (exception object): "
        info registers rdi
        printf "RSI (type_info):        "
        info registers rsi
        printf "RDX (destructor):       "
        info registers rdx
        printf "\n=== Exception Type Info ===\n"
        set $typeinfo = $rsi
        printf "type_info at: %p\n", $typeinfo
        printf "type name:    %s\n", (*(char**)($typeinfo + 8))
    end
end
document check_exception
    Inspect C++ exception at __cxa_throw (x86-64).
    Syntax: check_exception <frame_number>
    Example: check_exception 0
end

define check_exception_arm64
    if $argc != 1
        printf "Usage: check_exception_arm64 <frame_number>\n"
        printf "Use when stopped at __cxa_throw on ARM64/Jetson\n"
    else
        frame $arg0
        printf "=== Registers (ARM64) ===\n"
        printf "X0 (exception object): "
        info registers x0
        printf "X1 (type_info):        "
        info registers x1
        printf "X2 (destructor):       "
        info registers x2
        printf "\n=== Exception Type Info ===\n"
        set $typeinfo = $x1
        printf "type_info at: %p\n", $typeinfo
        printf "type name:    %s\n", (*(char**)($typeinfo + 8))
    end
end
document check_exception_arm64
    Inspect C++ exception at __cxa_throw (ARM64/Jetson).
    Syntax: check_exception_arm64 <frame_number>
    Example: check_exception_arm64 0
end

#==============================================================================
# REGISTER & ASSEMBLY HELPERS
#==============================================================================

define regs
    info registers
end
document regs
    Show all general purpose registers.
    Usage: regs
end

define flags
    info registers eflags
end
document flags
    Show CPU flags register.
    Usage: flags
end

define dis
    if $argc == 0
        disassemble
    else
        disassemble $arg0
    end
end
document dis
    Disassemble current function or specified location.
    Syntax: dis [location]
    Example: dis
    Example: dis main
end

define disn
    if $argc == 0
        x/10i $pc
    else
        x/$arg0i $pc
    end
end
document disn
    Disassemble N instructions from current PC.
    Syntax: disn [count]
    Example: disn 20
end

define dis_range
    if $argc < 2
        printf "Usage: dis_range <start> <end>\n"
    else
        disassemble $arg0, $arg1
    end
end
document dis_range
    Disassemble address range.
    Syntax: dis_range <start_addr> <end_addr>
    Example: dis_range main main+100
end

#==============================================================================
# QUICK EXAMINE SHORTCUTS
#==============================================================================

define xw
    if $argc == 0
        printf "Usage: xw <addr> [count]\n"
    else
        if $argc == 1
            x/16xw $arg0
        else
            x/$arg1xw $arg0
        end
    end
end
document xw
    Examine memory as 32-bit words (hex).
    Syntax: xw <address> [count]
    Example: xw &var 8
end

define xg
    if $argc == 0
        printf "Usage: xg <addr> [count]\n"
    else
        if $argc == 1
            x/8xg $arg0
        else
            x/$arg1xg $arg0
        end
    end
end
document xg
    Examine memory as 64-bit giant words (hex).
    Syntax: xg <address> [count]
    Example: xg &var 4
end

define xb
    if $argc == 0
        printf "Usage: xb <addr> [count]\n"
    else
        if $argc == 1
            x/32xb $arg0
        else
            x/$arg1xb $arg0
        end
    end
end
document xb
    Examine memory as bytes (hex).
    Syntax: xb <address> [count]
    Example: xb buffer 64
end

define xs
    if $argc == 0
        printf "Usage: xs <addr>\n"
    else
        x/s $arg0
    end
end
document xs
    Examine memory as null-terminated string.
    Syntax: xs <address>
    Example: xs str_ptr
end

define xi
    if $argc == 0
        printf "Usage: xi <addr> [count]\n"
    else
        if $argc == 1
            x/10i $arg0
        else
            x/$arg1i $arg0
        end
    end
end
document xi
    Examine memory as instructions.
    Syntax: xi <address> [count]
    Example: xi main 20
end

#==============================================================================
# PYTHON DEBUGGING (for mixed C/Python)
#==============================================================================

# Note: These require python3-dbg or debuginfo for Python

define pybt
    py-bt
end
document pybt
    Show Python backtrace (requires python-dbg).
    Usage: pybt
end

define pylist
    py-list
end
document pylist
    Show Python source at current frame (requires python-dbg).
    Usage: pylist
end

define pylocals
    py-locals
end
document pylocals
    Show Python local variables (requires python-dbg).
    Usage: pylocals
end

define pyup
    py-up
end
document pyup
    Go up one Python frame.
    Usage: pyup
end

define pydown
    py-down
end
document pydown
    Go down one Python frame.
    Usage: pydown
end

define pyprint
    if $argc == 0
        printf "Usage: pyprint <PyObject*>\n"
    else
        call (void)PyObject_Print($arg0, stderr, 0)
        call (void)fflush(stderr)
        printf "\n"
    end
end
document pyprint
    Print a PyObject* using Python's repr.
    Syntax: pyprint <PyObject*>
    Example: pyprint obj
end

define pytype
    if $argc == 0
        printf "Usage: pytype <PyObject*>\n"
    else
        printf "Type: %s\n", ((PyObject*)$arg0)->ob_type->tp_name
    end
end
document pytype
    Print the type name of a PyObject*.
    Syntax: pytype <PyObject*>
    Example: pytype obj
end

define pyrefcnt
    if $argc == 0
        printf "Usage: pyrefcnt <PyObject*>\n"
    else
        printf "Reference count: %ld\n", ((PyObject*)$arg0)->ob_refcnt
    end
end
document pyrefcnt
    Print the reference count of a PyObject*.
    Syntax: pyrefcnt <PyObject*>
    Example: pyrefcnt obj
end

# GIL state (useful for deadlock debugging)
define pygil
    printf "Checking GIL state...\n"
    call (int)PyGILState_Check()
end
document pygil
    Check if current thread holds the GIL.
    Usage: pygil
    Returns: 1 if GIL held, 0 otherwise
end

#==============================================================================
# GSTREAMER DEBUGGING HELPERS
#==============================================================================

define gst_element
    if $argc == 0
        printf "Usage: gst_element <GstElement*>\n"
    else
        printf "=== GstElement ===\n"
        printf "Name:    %s\n", ((GstObject*)$arg0)->name
        printf "Type:    %s\n", G_OBJECT_TYPE_NAME($arg0)
        printf "Parent:  %s\n", ((GstObject*)$arg0)->parent ? ((GstObject*)((GstObject*)$arg0)->parent)->name : "(none)"
        printf "State:   current=%d, pending=%d\n", ((GstElement*)$arg0)->current_state, ((GstElement*)$arg0)->pending_state
        printf "RefCnt:  %d\n", ((GObject*)$arg0)->ref_count
    end
end
document gst_element
    Print GstElement details.
    Syntax: gst_element <GstElement*>
    Example: gst_element element
end

define gst_pad
    if $argc == 0
        printf "Usage: gst_pad <GstPad*>\n"
    else
        printf "=== GstPad ===\n"
        printf "Name:      %s\n", ((GstObject*)$arg0)->name
        printf "Direction: %d (1=SRC, 2=SINK)\n", ((GstPad*)$arg0)->direction
        printf "Parent:    %s\n", ((GstObject*)$arg0)->parent ? ((GstObject*)((GstObject*)$arg0)->parent)->name : "(none)"
        set $peer = ((GstPad*)$arg0)->peer
        if $peer
            printf "Peer:      %s:%s\n", ((GstObject*)((GstObject*)$peer)->parent)->name, ((GstObject*)$peer)->name
        else
            printf "Peer:      (unlinked)\n"
        end
    end
end
document gst_pad
    Print GstPad details.
    Syntax: gst_pad <GstPad*>
    Example: gst_pad pad
end

define gst_buffer
    if $argc == 0
        printf "Usage: gst_buffer <GstBuffer*>\n"
    else
        printf "=== GstBuffer ===\n"
        printf "PTS:      %lu (%.3f sec)\n", ((GstBuffer*)$arg0)->pts, ((GstBuffer*)$arg0)->pts / 1000000000.0
        printf "DTS:      %lu (%.3f sec)\n", ((GstBuffer*)$arg0)->dts, ((GstBuffer*)$arg0)->dts / 1000000000.0
        printf "Duration: %lu (%.3f sec)\n", ((GstBuffer*)$arg0)->duration, ((GstBuffer*)$arg0)->duration / 1000000000.0
        printf "Offset:   %lu\n", ((GstBuffer*)$arg0)->offset
        printf "Size:     %zu\n", gst_buffer_get_size($arg0)
    end
end
document gst_buffer
    Print GstBuffer details.
    Syntax: gst_buffer <GstBuffer*>
    Example: gst_buffer buf
end

define gst_caps
    if $argc == 0
        printf "Usage: gst_caps <GstCaps*>\n"
    else
        printf "=== GstCaps ===\n"
        call (char*)gst_caps_to_string($arg0)
    end
end
document gst_caps
    Print GstCaps as string.
    Syntax: gst_caps <GstCaps*>
    Example: gst_caps caps
end

define gst_message
    if $argc == 0
        printf "Usage: gst_message <GstMessage*>\n"
    else
        printf "=== GstMessage ===\n"
        printf "Type:   %d\n", ((GstMessage*)$arg0)->type
        printf "Source: %s\n", ((GstMessage*)$arg0)->src ? ((GstObject*)((GstMessage*)$arg0)->src)->name : "(none)"
        printf "SeqNum: %u\n", ((GstMessage*)$arg0)->seqnum
    end
end
document gst_message
    Print GstMessage details.
    Syntax: gst_message <GstMessage*>
    Example: gst_message msg
end

define gst_event
    if $argc == 0
        printf "Usage: gst_event <GstEvent*>\n"
    else
        printf "=== GstEvent ===\n"
        printf "Type:      %d\n", ((GstEvent*)$arg0)->type
        printf "Timestamp: %lu\n", ((GstEvent*)$arg0)->timestamp
        printf "SeqNum:    %u\n", ((GstEvent*)$arg0)->seqnum
    end
end
document gst_event
    Print GstEvent details.
    Syntax: gst_event <GstEvent*>
    Example: gst_event event
end

#==============================================================================
# DEEPSTREAM / NVIDIA HELPERS
#==============================================================================

define cuda_error
    printf "=== CUDA Last Error ===\n"
    set $err = cudaGetLastError()
    printf "Error code: %d\n", $err
    call (char*)cudaGetErrorString($err)
end
document cuda_error
    Check last CUDA error.
    Usage: cuda_error
end

define cuda_sync
    printf "Synchronizing CUDA device...\n"
    call (int)cudaDeviceSynchronize()
    printf "Done. Checking errors...\n"
    cuda_error
end
document cuda_sync
    Synchronize CUDA device and check errors.
    Usage: cuda_sync
end

define nvds_batch_meta
    if $argc == 0
        printf "Usage: nvds_batch_meta <NvDsBatchMeta*>\n"
    else
        printf "=== NvDsBatchMeta ===\n"
        printf "Batch ID:     %u\n", ((NvDsBatchMeta*)$arg0)->batch_id
        printf "Num Frames:   %u\n", ((NvDsBatchMeta*)$arg0)->num_frames_in_batch
        printf "Max Frames:   %u\n", ((NvDsBatchMeta*)$arg0)->max_frames_in_batch
    end
end
document nvds_batch_meta
    Print NvDsBatchMeta details.
    Syntax: nvds_batch_meta <NvDsBatchMeta*>
    Example: nvds_batch_meta batch_meta
end

define nvds_frame_meta
    if $argc == 0
        printf "Usage: nvds_frame_meta <NvDsFrameMeta*>\n"
    else
        printf "=== NvDsFrameMeta ===\n"
        printf "Pad Index:    %u\n", ((NvDsFrameMeta*)$arg0)->pad_index
        printf "Batch ID:     %u\n", ((NvDsFrameMeta*)$arg0)->batch_id
        printf "Frame Num:    %d\n", ((NvDsFrameMeta*)$arg0)->frame_num
        printf "Source ID:    %u\n", ((NvDsFrameMeta*)$arg0)->source_id
        printf "Width:        %u\n", ((NvDsFrameMeta*)$arg0)->source_frame_width
        printf "Height:       %u\n", ((NvDsFrameMeta*)$arg0)->source_frame_height
        printf "Num Objects:  %u\n", ((NvDsFrameMeta*)$arg0)->num_obj_meta
    end
end
document nvds_frame_meta
    Print NvDsFrameMeta details.
    Syntax: nvds_frame_meta <NvDsFrameMeta*>
    Example: nvds_frame_meta frame_meta
end

define nvds_obj_meta
    if $argc == 0
        printf "Usage: nvds_obj_meta <NvDsObjectMeta*>\n"
    else
        printf "=== NvDsObjectMeta ===\n"
        printf "Class ID:     %d\n", ((NvDsObjectMeta*)$arg0)->class_id
        printf "Object ID:    %lu\n", ((NvDsObjectMeta*)$arg0)->object_id
        printf "Confidence:   %f\n", ((NvDsObjectMeta*)$arg0)->confidence
        printf "Label:        %s\n", ((NvDsObjectMeta*)$arg0)->obj_label
        printf "BBox (LTWH):  %.1f, %.1f, %.1f, %.1f\n", \
            ((NvDsObjectMeta*)$arg0)->rect_params.left, \
            ((NvDsObjectMeta*)$arg0)->rect_params.top, \
            ((NvDsObjectMeta*)$arg0)->rect_params.width, \
            ((NvDsObjectMeta*)$arg0)->rect_params.height
    end
end
document nvds_obj_meta
    Print NvDsObjectMeta details.
    Syntax: nvds_obj_meta <NvDsObjectMeta*>
    Example: nvds_obj_meta obj_meta
end

#==============================================================================
# LOGGING & SESSION MANAGEMENT
#==============================================================================

define log_start
    if $argc == 0
        set logging file /tmp/gdb_session.log
    else
        set logging file $arg0
    end
    set logging overwrite on
    set logging enabled on
    printf "Logging started to: %s\n", $argc == 0 ? "/tmp/gdb_session.log" : "$arg0"
end
document log_start
    Start logging GDB output to file.
    Syntax: log_start [filename]
    Default: /tmp/gdb_session.log
end

define log_append
    if $argc == 0
        set logging file /tmp/gdb_session.log
    else
        set logging file $arg0
    end
    set logging overwrite off
    set logging enabled on
    printf "Logging (append) started to: %s\n", $argc == 0 ? "/tmp/gdb_session.log" : "$arg0"
end
document log_append
    Start logging GDB output (append mode).
    Syntax: log_append [filename]
end

define log_stop
    set logging enabled off
    printf "Logging stopped\n"
end
document log_stop
    Stop logging.
    Usage: log_stop
end

define session_save
    if $argc == 0
        printf "Usage: session_save <filename>\n"
        printf "Saves breakpoints, watchpoints, and display expressions\n"
    else
        save breakpoints $arg0.bp
        printf "Session saved to %s.bp\n", "$arg0"
    end
end
document session_save
    Save debugging session (breakpoints).
    Syntax: session_save <base_filename>
    Example: session_save my_session
end

define session_load
    if $argc == 0
        printf "Usage: session_load <filename>\n"
    else
        source $arg0.bp
        printf "Session loaded from %s.bp\n", "$arg0"
    end
end
document session_load
    Load debugging session.
    Syntax: session_load <base_filename>
    Example: session_load my_session
end

#==============================================================================
# CORE DUMP HELPERS
#==============================================================================

define core_info
    printf "=== Core Dump Info ===\n"
    info target
    printf "\n=== Threads ===\n"
    info threads
    printf "\n=== Current Frame ===\n"
    frame
    printf "\n=== Signal ===\n"
    info signal
end
document core_info
    Show summary information about loaded core dump.
    Usage: core_info
end

define core_bt_all
    printf "=== All Thread Backtraces ===\n"
    thread apply all bt full
end
document core_bt_all
    Show full backtrace for all threads in core dump.
    Usage: core_bt_all
end

#==============================================================================
# CONVENIENCE ALIASES (only non-conflicting with GDB builtins)
#==============================================================================

# Info shortcuts (GDB doesn't have these by default)
alias -a il = info locals
alias -a ia = info args
alias -a ib = info breakpoints
alias -a it = info threads
alias -a ir = info registers
alias -a iv = info variables
alias -a ifn = info functions

# Frame shortcut
alias -a fr = frame

# Note: GDB already provides these built-in aliases:
#   wh=whatis
#   r=run, c=continue, s=step, n=next, si=stepi, ni=nexti
#   f=finish, u=until, q=quit, b=break, d=delete, bt=backtrace
#   p=print, i=info

#==============================================================================
# QUICK HELP
#==============================================================================

define gdb_help
    printf "=== Custom GDB Commands Quick Reference ===\n\n"
    printf "STL Containers:\n"
    printf "  pvector, plist, pmap, pset, pdequeue, pstack, pqueue, ppqueue\n"
    printf "  pbitset, pstring, pstring11, pshared, punique, poptional\n\n"
    printf "C Helpers:\n"
    printf "  parray, clist, hexdump, hexdump_ascii, ascii, offsets\n"
    printf "  vmmap, malloc_info, heap_info\n\n"
    printf "Threading:\n"
    printf "  btall, threads_info, threads_full, tswitch, find_deadlock, mutex_info\n\n"
    printf "Python:\n"
    printf "  pybt, pylist, pylocals, pyup, pydown, pyprint, pytype, pyrefcnt, pygil\n\n"
    printf "GStreamer:\n"
    printf "  gst_element, gst_pad, gst_buffer, gst_caps, gst_message, gst_event\n\n"
    printf "DeepStream/CUDA:\n"
    printf "  cuda_error, cuda_sync, nvds_batch_meta, nvds_frame_meta, nvds_obj_meta\n\n"
    printf "Breakpoints:\n"
    printf "  bp, bpc, bpt, bpregex, bp_save, bp_load, bpe, bpd\n\n"
    printf "Watchpoints:\n"
    printf "  ww (write), wr (read), wa (access)\n\n"
    printf "Memory:\n"
    printf "  xw, xg, xb, xs, xi (examine shortcuts)\n\n"
    printf "Context:\n"
    printf "  ctx, btf, regs, dis, disn, args, locals\n\n"
    printf "Session:\n"
    printf "  log_start, log_stop, session_save, session_load\n\n"
    printf "Signals:\n"
    printf "  signals_multimedia, signals_default, signals_show\n\n"
    printf "Type 'help <command>' for detailed usage.\n"
    printf "Type 'help user-defined' for complete list.\n"
end
document gdb_help
    Show quick reference for custom GDB commands.
    Usage: gdb_help
end

#==============================================================================
# STARTUP MESSAGE
#==============================================================================

printf "\n"
printf "╔══════════════════════════════════════════════════════════════╗\n"
printf "║     Custom .gdbinit loaded - C/C++/Python/GStreamer/CUDA     ║\n"
printf "║          Type 'gdb_help' for command reference               ║\n"
printf "╚══════════════════════════════════════════════════════════════╝\n"
printf "\n"
