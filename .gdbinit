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
# LINUX KERNEL DEBUGGING
#==============================================================================
#
# For full kernel debugging support, load the kernel's GDB scripts:
#   (gdb) add-auto-load-safe-path /path/to/linux/scripts/gdb/vmlinux-gdb.py
#   (gdb) source /path/to/linux/scripts/gdb/vmlinux-gdb.py
#
# Or add to your .gdbinit:
#   add-auto-load-safe-path /path/to/linux
#   set auto-load safe-path /
#
# The kernel provides: lx-dmesg, lx-lsmod, lx-ps, lx-symbols, etc.
# Type 'apropos lx-' to see all kernel commands when loaded.
#==============================================================================

#------------------------------------------------------------------------------
# Kernel List Helpers (struct list_head)
#------------------------------------------------------------------------------

define lx_list_head
    if $argc == 0
        printf "Usage: lx_list_head <list_head_ptr>\n"
    else
        printf "=== list_head @ %p ===\n", $arg0
        printf "next: %p\n", ((struct list_head *)$arg0)->next
        printf "prev: %p\n", ((struct list_head *)$arg0)->prev
        if ((struct list_head *)$arg0)->next == $arg0
            printf "Status: EMPTY (points to self)\n"
        else
            printf "Status: Has entries\n"
        end
    end
end
document lx_list_head
    Print struct list_head details.
    Syntax: lx_list_head <list_head_ptr>
    Example: lx_list_head &my_list
end

define lx_list_for_each
    if $argc < 2
        printf "Usage: lx_list_for_each <head_ptr> <type> <member> [max]\n"
        printf "Example: lx_list_for_each &devices \"struct device\" list 10\n"
    else
        set $head = (struct list_head *)$arg0
        set $pos = $head->next
        set $count = 0
        set $max = 100
        if $argc >= 4
            set $max = $arg3
        end
        while $pos != $head && $count < $max
            set $entry = ($arg1 *)((char *)$pos - (unsigned long)&(($arg1 *)0)->$arg2)
            printf "[%d] %p: ", $count, $entry
            p *$entry
            set $pos = $pos->next
            set $count++
        end
        if $pos != $head
            printf "... stopped at %d entries (use max param for more)\n", $max
        end
        printf "Total entries: %d\n", $count
    end
end
document lx_list_for_each
    Iterate kernel list_head and print container structures.
    Uses container_of logic to get the containing structure.
    Syntax: lx_list_for_each <head_ptr> <container_type> <member_name> [max_entries]
    Example: lx_list_for_each &module_list "struct module" list 20
end

define lx_list_count
    if $argc == 0
        printf "Usage: lx_list_count <head_ptr>\n"
    else
        set $head = (struct list_head *)$arg0
        set $pos = $head->next
        set $count = 0
        while $pos != $head && $count < 10000
            set $pos = $pos->next
            set $count++
        end
        printf "List entries: %d\n", $count
    end
end
document lx_list_count
    Count entries in a kernel list_head.
    Syntax: lx_list_count <head_ptr>
    Example: lx_list_count &my_list
end

#------------------------------------------------------------------------------
# Kernel Hlist Helpers (struct hlist_head/hlist_node)
#------------------------------------------------------------------------------

define lx_hlist_for_each
    if $argc < 2
        printf "Usage: lx_hlist_for_each <hlist_head_ptr> <type> <member> [max]\n"
    else
        set $head = (struct hlist_head *)$arg0
        set $pos = $head->first
        set $count = 0
        set $max = 100
        if $argc >= 4
            set $max = $arg3
        end
        while $pos != 0 && $count < $max
            set $entry = ($arg1 *)((char *)$pos - (unsigned long)&(($arg1 *)0)->$arg2)
            printf "[%d] %p: ", $count, $entry
            p *$entry
            set $pos = $pos->next
            set $count++
        end
        printf "Total entries: %d\n", $count
    end
end
document lx_hlist_for_each
    Iterate kernel hlist and print container structures.
    Syntax: lx_hlist_for_each <hlist_head_ptr> <container_type> <member_name> [max]
    Example: lx_hlist_for_each &hash_bucket "struct my_entry" hnode
end

#------------------------------------------------------------------------------
# Red-Black Tree Helpers (struct rb_root/rb_node)
#------------------------------------------------------------------------------

define lx_rb_first
    if $argc == 0
        printf "Usage: lx_rb_first <rb_root_ptr>\n"
    else
        set $n = ((struct rb_root *)$arg0)->rb_node
        if $n == 0
            printf "Tree is empty\n"
        else
            while $n->rb_left != 0
                set $n = $n->rb_left
            end
            printf "First node: %p\n", $n
        end
    end
end
document lx_rb_first
    Find first (leftmost) node in rb_tree.
    Syntax: lx_rb_first <rb_root_ptr>
end

define lx_rb_next
    if $argc == 0
        printf "Usage: lx_rb_next <rb_node_ptr>\n"
    else
        set $node = (struct rb_node *)$arg0
        if $node->rb_right
            set $node = $node->rb_right
            while $node->rb_left
                set $node = $node->rb_left
            end
            printf "Next node: %p\n", $node
        else
            set $parent = $node->__rb_parent_color & ~3
            while $parent && $node == ((struct rb_node *)$parent)->rb_right
                set $node = (struct rb_node *)$parent
                set $parent = $node->__rb_parent_color & ~3
            end
            if $parent
                printf "Next node: %p\n", $parent
            else
                printf "No next node (was last)\n"
            end
        end
    end
end
document lx_rb_next
    Find next node in rb_tree traversal.
    Syntax: lx_rb_next <rb_node_ptr>
end

define lx_rb_for_each
    if $argc < 3
        printf "Usage: lx_rb_for_each <rb_root_ptr> <type> <member> [max]\n"
    else
        set $root = (struct rb_root *)$arg0
        set $max = 100
        if $argc >= 4
            set $max = $arg3
        end
        set $count = 0
        # Find first
        set $n = $root->rb_node
        if $n != 0
            while $n->rb_left != 0
                set $n = $n->rb_left
            end
            while $n != 0 && $count < $max
                set $entry = ($arg1 *)((char *)$n - (unsigned long)&(($arg1 *)0)->$arg2)
                printf "[%d] %p: ", $count, $entry
                p *$entry
                set $count++
                # rb_next inline
                if $n->rb_right
                    set $n = $n->rb_right
                    while $n->rb_left
                        set $n = $n->rb_left
                    end
                else
                    set $parent = (struct rb_node *)($n->__rb_parent_color & ~3)
                    while $parent && $n == $parent->rb_right
                        set $n = $parent
                        set $parent = (struct rb_node *)($n->__rb_parent_color & ~3)
                    end
                    set $n = $parent
                end
            end
        end
        printf "Total entries: %d\n", $count
    end
end
document lx_rb_for_each
    Iterate rb_tree in-order and print container structures.
    Syntax: lx_rb_for_each <rb_root_ptr> <container_type> <member_name> [max]
    Example: lx_rb_for_each &my_tree "struct my_node" rb
end

#------------------------------------------------------------------------------
# Task/Process Helpers
#------------------------------------------------------------------------------

define lx_current
    printf "=== Current Task ===\n"
    p $lx_current()
end
document lx_current
    Print current task_struct (requires kernel GDB scripts loaded).
    Usage: lx_current
end

define lx_task_info
    if $argc == 0
        printf "Usage: lx_task_info <task_struct_ptr>\n"
    else
        set $t = (struct task_struct *)$arg0
        printf "=== task_struct @ %p ===\n", $t
        printf "comm:       %.16s\n", $t->comm
        printf "pid:        %d\n", $t->pid
        printf "tgid:       %d\n", $t->tgid
        printf "state:      %ld\n", $t->__state
        printf "flags:      0x%x\n", $t->flags
        printf "on_cpu:     %d\n", $t->on_cpu
        printf "prio:       %d\n", $t->prio
        printf "policy:     %d\n", $t->policy
        printf "nr_cpus_allowed: %d\n", $t->nr_cpus_allowed
        printf "mm:         %p\n", $t->mm
        printf "active_mm:  %p\n", $t->active_mm
        printf "parent:     %p (pid %d)\n", $t->parent, $t->parent->pid
        printf "real_parent:%p (pid %d)\n", $t->real_parent, $t->real_parent->pid
    end
end
document lx_task_info
    Print task_struct details.
    Syntax: lx_task_info <task_struct_ptr>
    Example: lx_task_info init_task
end

define lx_task_stack
    if $argc == 0
        printf "Usage: lx_task_stack <task_struct_ptr>\n"
    else
        set $t = (struct task_struct *)$arg0
        printf "=== Task Stack Info ===\n"
        printf "stack:      %p\n", $t->stack
        # Stack end is typically stack + THREAD_SIZE
        printf "Stack pointer (if saved): check thread.sp\n"
    end
end
document lx_task_stack
    Print task stack information.
    Syntax: lx_task_stack <task_struct_ptr>
end

#------------------------------------------------------------------------------
# Spinlock / Mutex / RwLock Helpers
#------------------------------------------------------------------------------

define lx_spinlock
    if $argc == 0
        printf "Usage: lx_spinlock <spinlock_t_ptr>\n"
    else
        printf "=== spinlock_t @ %p ===\n", $arg0
        # Raw spinlock structure varies by config
        # For ticket spinlock:
        printf "raw_lock: "
        p ((spinlock_t *)$arg0)->rlock.raw_lock
    end
end
document lx_spinlock
    Print spinlock_t state.
    Syntax: lx_spinlock <spinlock_t_ptr>
    Note: Internal structure varies by kernel config (TICKET, QUEUED, etc.)
end

define lx_mutex
    if $argc == 0
        printf "Usage: lx_mutex <mutex_ptr>\n"
    else
        set $m = (struct mutex *)$arg0
        printf "=== struct mutex @ %p ===\n", $m
        printf "owner:      %p\n", $m->owner
        printf "wait_lock:  "
        p $m->wait_lock
        printf "wait_list empty: %d\n", $m->wait_list.next == &$m->wait_list
    end
end
document lx_mutex
    Print kernel mutex state.
    Syntax: lx_mutex <mutex_ptr>
end

define lx_rwlock
    if $argc == 0
        printf "Usage: lx_rwlock <rwlock_t_ptr>\n"
    else
        printf "=== rwlock_t @ %p ===\n", $arg0
        p *((rwlock_t *)$arg0)
    end
end
document lx_rwlock
    Print rwlock_t state.
    Syntax: lx_rwlock <rwlock_t_ptr>
end

define lx_semaphore
    if $argc == 0
        printf "Usage: lx_semaphore <semaphore_ptr>\n"
    else
        set $s = (struct semaphore *)$arg0
        printf "=== struct semaphore @ %p ===\n", $s
        printf "count:      %d\n", $s->count
        printf "wait_list empty: %d\n", $s->wait_list.next == &$s->wait_list
    end
end
document lx_semaphore
    Print kernel semaphore state.
    Syntax: lx_semaphore <semaphore_ptr>
end

define lx_rcu
    printf "=== RCU State ===\n"
    printf "Check rcu_state, rcu_data per-cpu variables\n"
    printf "rcu_state: "
    p rcu_state
end
document lx_rcu
    Print RCU subsystem state.
    Usage: lx_rcu
end

#------------------------------------------------------------------------------
# Wait Queue Helpers
#------------------------------------------------------------------------------

define lx_waitqueue
    if $argc == 0
        printf "Usage: lx_waitqueue <wait_queue_head_ptr>\n"
    else
        set $wq = (struct wait_queue_head *)$arg0
        printf "=== wait_queue_head @ %p ===\n", $wq
        printf "lock: "
        p $wq->lock
        set $head = &$wq->head
        set $pos = $head->next
        set $count = 0
        while $pos != $head && $count < 100
            set $entry = (struct wait_queue_entry *)((char *)$pos - (unsigned long)&((struct wait_queue_entry *)0)->entry)
            printf "[%d] wait_queue_entry @ %p\n", $count, $entry
            printf "     flags: 0x%x\n", $entry->flags
            printf "     private (task): %p\n", $entry->private
            set $pos = $pos->next
            set $count++
        end
        if $count == 0
            printf "Wait queue is empty\n"
        else
            printf "Total waiters: %d\n", $count
        end
    end
end
document lx_waitqueue
    Print wait_queue_head and list all waiters.
    Syntax: lx_waitqueue <wait_queue_head_ptr>
end

#------------------------------------------------------------------------------
# Work Queue Helpers
#------------------------------------------------------------------------------

define lx_work_struct
    if $argc == 0
        printf "Usage: lx_work_struct <work_struct_ptr>\n"
    else
        set $w = (struct work_struct *)$arg0
        printf "=== work_struct @ %p ===\n", $w
        printf "data:       0x%lx\n", $w->data
        printf "func:       %p ", $w->func
        info symbol $w->func
        printf "entry.next: %p\n", $w->entry.next
        printf "entry.prev: %p\n", $w->entry.prev
    end
end
document lx_work_struct
    Print work_struct details.
    Syntax: lx_work_struct <work_struct_ptr>
end

define lx_delayed_work
    if $argc == 0
        printf "Usage: lx_delayed_work <delayed_work_ptr>\n"
    else
        set $dw = (struct delayed_work *)$arg0
        printf "=== delayed_work @ %p ===\n", $dw
        printf "work.func:  %p ", $dw->work.func
        info symbol $dw->work.func
        printf "timer:      %p\n", &$dw->timer
    end
end
document lx_delayed_work
    Print delayed_work details.
    Syntax: lx_delayed_work <delayed_work_ptr>
end

#------------------------------------------------------------------------------
# Timer Helpers
#------------------------------------------------------------------------------

define lx_timer
    if $argc == 0
        printf "Usage: lx_timer <timer_list_ptr>\n"
    else
        set $t = (struct timer_list *)$arg0
        printf "=== timer_list @ %p ===\n", $t
        printf "expires:    %lu\n", $t->expires
        printf "function:   %p ", $t->function
        info symbol $t->function
        printf "flags:      0x%x\n", $t->flags
    end
end
document lx_timer
    Print timer_list details.
    Syntax: lx_timer <timer_list_ptr>
end

define lx_hrtimer
    if $argc == 0
        printf "Usage: lx_hrtimer <hrtimer_ptr>\n"
    else
        set $t = (struct hrtimer *)$arg0
        printf "=== hrtimer @ %p ===\n", $t
        printf "function:   %p ", $t->function
        info symbol $t->function
        printf "state:      %d\n", $t->state
        printf "_softexpires: %lld\n", $t->_softexpires
    end
end
document lx_hrtimer
    Print hrtimer details.
    Syntax: lx_hrtimer <hrtimer_ptr>
end

#------------------------------------------------------------------------------
# Memory Management Helpers
#------------------------------------------------------------------------------

define lx_page
    if $argc == 0
        printf "Usage: lx_page <page_ptr>\n"
    else
        set $pg = (struct page *)$arg0
        printf "=== struct page @ %p ===\n", $pg
        printf "flags:      0x%lx\n", $pg->flags
        printf "_refcount:  %d\n", $pg->_refcount.counter
        printf "_mapcount:  %d\n", $pg->_mapcount.counter
        printf "mapping:    %p\n", $pg->mapping
        printf "index:      %lu\n", $pg->index
    end
end
document lx_page
    Print struct page details.
    Syntax: lx_page <page_ptr>
end

define lx_vma
    if $argc == 0
        printf "Usage: lx_vma <vm_area_struct_ptr>\n"
    else
        set $v = (struct vm_area_struct *)$arg0
        printf "=== vm_area_struct @ %p ===\n", $v
        printf "vm_start:   0x%lx\n", $v->vm_start
        printf "vm_end:     0x%lx\n", $v->vm_end
        printf "vm_flags:   0x%lx\n", $v->vm_flags
        printf "vm_pgoff:   %lu\n", $v->vm_pgoff
        printf "vm_file:    %p\n", $v->vm_file
        if $v->vm_file
            printf "  filename: %s\n", $v->vm_file->f_path.dentry->d_name.name
        end
        printf "vm_mm:      %p\n", $v->vm_mm
    end
end
document lx_vma
    Print vm_area_struct details.
    Syntax: lx_vma <vm_area_struct_ptr>
end

define lx_mm
    if $argc == 0
        printf "Usage: lx_mm <mm_struct_ptr>\n"
    else
        set $mm = (struct mm_struct *)$arg0
        printf "=== mm_struct @ %p ===\n", $mm
        printf "pgd:         %p\n", $mm->pgd
        printf "mm_users:    %d\n", $mm->mm_users.counter
        printf "mm_count:    %d\n", $mm->mm_count.counter
        printf "map_count:   %d\n", $mm->map_count
        printf "total_vm:    %lu pages\n", $mm->total_vm
        printf "locked_vm:   %lu pages\n", $mm->locked_vm
        printf "pinned_vm:   %lu pages\n", $mm->pinned_vm.counter
        printf "stack_vm:    %lu pages\n", $mm->stack_vm
        printf "start_code:  0x%lx\n", $mm->start_code
        printf "end_code:    0x%lx\n", $mm->end_code
        printf "start_data:  0x%lx\n", $mm->start_data
        printf "end_data:    0x%lx\n", $mm->end_data
        printf "start_brk:   0x%lx\n", $mm->start_brk
        printf "brk:         0x%lx\n", $mm->brk
        printf "start_stack: 0x%lx\n", $mm->start_stack
    end
end
document lx_mm
    Print mm_struct details.
    Syntax: lx_mm <mm_struct_ptr>
end

define lx_slab_cache
    if $argc == 0
        printf "Usage: lx_slab_cache <kmem_cache_ptr>\n"
    else
        set $s = (struct kmem_cache *)$arg0
        printf "=== kmem_cache @ %p ===\n", $s
        printf "name:        %s\n", $s->name
        printf "object_size: %u\n", $s->object_size
        printf "size:        %u\n", $s->size
        printf "align:       %u\n", $s->align
        printf "flags:       0x%x\n", $s->flags
    end
end
document lx_slab_cache
    Print kmem_cache (slab) details.
    Syntax: lx_slab_cache <kmem_cache_ptr>
end

#------------------------------------------------------------------------------
# Per-CPU Variable Helpers
#------------------------------------------------------------------------------

define lx_per_cpu
    if $argc < 2
        printf "Usage: lx_per_cpu <per_cpu_var> <cpu_num>\n"
        printf "Example: lx_per_cpu runqueues 0\n"
    else
        set $offset = __per_cpu_offset[$arg1]
        set $ptr = (void *)((unsigned long)&$arg0 + $offset)
        printf "Per-CPU variable '%s' on CPU %d:\n", "$arg0", $arg1
        printf "Address: %p\n", $ptr
        p *($ptr)
    end
end
document lx_per_cpu
    Access per-CPU variable for specific CPU.
    Syntax: lx_per_cpu <variable_name> <cpu_number>
    Example: lx_per_cpu runqueues 0
end

define lx_this_cpu
    if $argc == 0
        printf "Usage: lx_this_cpu <per_cpu_var>\n"
    else
        # Assumes we can determine current CPU from context
        printf "Use lx_per_cpu with explicit CPU number\n"
        printf "Current CPU detection requires running target\n"
    end
end
document lx_this_cpu
    Access per-CPU variable for current CPU.
    Syntax: lx_this_cpu <variable_name>
    Note: For crash dumps, use lx_per_cpu with explicit CPU number.
end

#------------------------------------------------------------------------------
# Device / Driver Helpers
#------------------------------------------------------------------------------

define lx_device
    if $argc == 0
        printf "Usage: lx_device <device_ptr>\n"
    else
        set $d = (struct device *)$arg0
        printf "=== struct device @ %p ===\n", $d
        printf "kobj.name:     %s\n", $d->kobj.name
        printf "init_name:     %s\n", $d->init_name ? $d->init_name : "(null)"
        printf "bus:           %p", $d->bus
        if $d->bus
            printf " (%s)", $d->bus->name
        end
        printf "\n"
        printf "driver:        %p", $d->driver
        if $d->driver
            printf " (%s)", $d->driver->name
        end
        printf "\n"
        printf "parent:        %p\n", $d->parent
        printf "driver_data:   %p\n", $d->driver_data
    end
end
document lx_device
    Print struct device details.
    Syntax: lx_device <device_ptr>
end

define lx_pci_dev
    if $argc == 0
        printf "Usage: lx_pci_dev <pci_dev_ptr>\n"
    else
        set $p = (struct pci_dev *)$arg0
        printf "=== pci_dev @ %p ===\n", $p
        printf "vendor:      0x%04x\n", $p->vendor
        printf "device:      0x%04x\n", $p->device
        printf "subsystem_vendor: 0x%04x\n", $p->subsystem_vendor
        printf "subsystem_device: 0x%04x\n", $p->subsystem_device
        printf "class:       0x%06x\n", $p->class
        printf "devfn:       %d (slot %d, func %d)\n", $p->devfn, $p->devfn >> 3, $p->devfn & 7
        printf "irq:         %u\n", $p->irq
        printf "driver:      %p", $p->driver
        if $p->driver
            printf " (%s)", $p->driver->name
        end
        printf "\n"
    end
end
document lx_pci_dev
    Print pci_dev details.
    Syntax: lx_pci_dev <pci_dev_ptr>
end

define lx_platform_device
    if $argc == 0
        printf "Usage: lx_platform_device <platform_device_ptr>\n"
    else
        set $p = (struct platform_device *)$arg0
        printf "=== platform_device @ %p ===\n", $p
        printf "name:        %s\n", $p->name
        printf "id:          %d\n", $p->id
        printf "num_resources: %u\n", $p->num_resources
        printf "dev:         %p\n", &$p->dev
    end
end
document lx_platform_device
    Print platform_device details.
    Syntax: lx_platform_device <platform_device_ptr>
end

#------------------------------------------------------------------------------
# Network Helpers
#------------------------------------------------------------------------------

define lx_sk_buff
    if $argc == 0
        printf "Usage: lx_sk_buff <sk_buff_ptr>\n"
    else
        set $skb = (struct sk_buff *)$arg0
        printf "=== sk_buff @ %p ===\n", $skb
        printf "len:         %u\n", $skb->len
        printf "data_len:    %u\n", $skb->data_len
        printf "mac_len:     %u\n", $skb->mac_len
        printf "protocol:    0x%04x\n", $skb->protocol
        printf "head:        %p\n", $skb->head
        printf "data:        %p\n", $skb->data
        printf "tail:        %u\n", $skb->tail
        printf "end:         %u\n", $skb->end
        printf "dev:         %p", $skb->dev
        if $skb->dev
            printf " (%s)", $skb->dev->name
        end
        printf "\n"
        printf "sk:          %p\n", $skb->sk
    end
end
document lx_sk_buff
    Print sk_buff (socket buffer) details.
    Syntax: lx_sk_buff <sk_buff_ptr>
end

define lx_net_device
    if $argc == 0
        printf "Usage: lx_net_device <net_device_ptr>\n"
    else
        set $nd = (struct net_device *)$arg0
        printf "=== net_device @ %p ===\n", $nd
        printf "name:        %s\n", $nd->name
        printf "ifindex:     %d\n", $nd->ifindex
        printf "mtu:         %u\n", $nd->mtu
        printf "flags:       0x%x\n", $nd->flags
        printf "state:       0x%lx\n", $nd->state
        printf "dev_addr:    %02x:%02x:%02x:%02x:%02x:%02x\n", \
            $nd->dev_addr[0], $nd->dev_addr[1], $nd->dev_addr[2], \
            $nd->dev_addr[3], $nd->dev_addr[4], $nd->dev_addr[5]
        printf "netdev_ops:  %p\n", $nd->netdev_ops
    end
end
document lx_net_device
    Print net_device details.
    Syntax: lx_net_device <net_device_ptr>
end

define lx_sock
    if $argc == 0
        printf "Usage: lx_sock <sock_ptr>\n"
    else
        set $sk = (struct sock *)$arg0
        printf "=== struct sock @ %p ===\n", $sk
        printf "sk_state:     %d\n", (int)$sk->__sk_common.skc_state
        printf "sk_family:    %d\n", $sk->__sk_common.skc_family
        printf "sk_type:      %d\n", $sk->sk_type
        printf "sk_protocol:  %d\n", $sk->sk_protocol
        printf "sk_rcvbuf:    %d\n", $sk->sk_rcvbuf
        printf "sk_sndbuf:    %d\n", $sk->sk_sndbuf
    end
end
document lx_sock
    Print struct sock details.
    Syntax: lx_sock <sock_ptr>
end

#------------------------------------------------------------------------------
# File System Helpers
#------------------------------------------------------------------------------

define lx_inode
    if $argc == 0
        printf "Usage: lx_inode <inode_ptr>\n"
    else
        set $i = (struct inode *)$arg0
        printf "=== struct inode @ %p ===\n", $i
        printf "i_ino:       %lu\n", $i->i_ino
        printf "i_mode:      0%o\n", $i->i_mode
        printf "i_nlink:     %u\n", $i->i_nlink
        printf "i_uid:       %u\n", $i->i_uid.val
        printf "i_gid:       %u\n", $i->i_gid.val
        printf "i_size:      %lld\n", $i->i_size
        printf "i_blocks:    %lu\n", $i->i_blocks
        printf "i_sb:        %p\n", $i->i_sb
        printf "i_op:        %p\n", $i->i_op
        printf "i_fop:       %p\n", $i->i_fop
    end
end
document lx_inode
    Print struct inode details.
    Syntax: lx_inode <inode_ptr>
end

define lx_dentry
    if $argc == 0
        printf "Usage: lx_dentry <dentry_ptr>\n"
    else
        set $d = (struct dentry *)$arg0
        printf "=== struct dentry @ %p ===\n", $d
        printf "d_name:      %s\n", $d->d_name.name
        printf "d_inode:     %p\n", $d->d_inode
        printf "d_parent:    %p\n", $d->d_parent
        printf "d_flags:     0x%x\n", $d->d_flags
        printf "d_sb:        %p\n", $d->d_sb
    end
end
document lx_dentry
    Print struct dentry details.
    Syntax: lx_dentry <dentry_ptr>
end

define lx_file
    if $argc == 0
        printf "Usage: lx_file <file_ptr>\n"
    else
        set $f = (struct file *)$arg0
        printf "=== struct file @ %p ===\n", $f
        printf "f_path.dentry: %p\n", $f->f_path.dentry
        if $f->f_path.dentry
            printf "  name:      %s\n", $f->f_path.dentry->d_name.name
        end
        printf "f_inode:     %p\n", $f->f_inode
        printf "f_op:        %p\n", $f->f_op
        printf "f_count:     %ld\n", $f->f_count.counter
        printf "f_flags:     0x%x\n", $f->f_flags
        printf "f_mode:      0x%x\n", $f->f_mode
        printf "f_pos:       %lld\n", $f->f_pos
    end
end
document lx_file
    Print struct file details.
    Syntax: lx_file <file_ptr>
end

define lx_super_block
    if $argc == 0
        printf "Usage: lx_super_block <super_block_ptr>\n"
    else
        set $sb = (struct super_block *)$arg0
        printf "=== super_block @ %p ===\n", $sb
        printf "s_type:      %p (%s)\n", $sb->s_type, $sb->s_type->name
        printf "s_id:        %s\n", $sb->s_id
        printf "s_blocksize: %lu\n", $sb->s_blocksize
        printf "s_flags:     0x%lx\n", $sb->s_flags
        printf "s_root:      %p\n", $sb->s_root
    end
end
document lx_super_block
    Print super_block details.
    Syntax: lx_super_block <super_block_ptr>
end

#------------------------------------------------------------------------------
# Interrupt / IRQ Helpers
#------------------------------------------------------------------------------

define lx_irq_desc
    if $argc == 0
        printf "Usage: lx_irq_desc <irq_number>\n"
    else
        set $desc = irq_desc[$arg0]
        printf "=== irq_desc[%d] @ %p ===\n", $arg0, $desc
        printf "irq_data.irq:   %u\n", $desc->irq_data.irq
        printf "irq_data.hwirq: %lu\n", $desc->irq_data.hwirq
        printf "action:         %p\n", $desc->action
        if $desc->action
            printf "  handler:      %p ", $desc->action->handler
            info symbol $desc->action->handler
            printf "  name:         %s\n", $desc->action->name
        end
        printf "depth:          %u\n", $desc->depth
        printf "irq_count:      %u\n", $desc->irq_count
    end
end
document lx_irq_desc
    Print irq_desc for given IRQ number.
    Syntax: lx_irq_desc <irq_number>
    Example: lx_irq_desc 42
end

#------------------------------------------------------------------------------
# Module Helpers
#------------------------------------------------------------------------------

define lx_module
    if $argc == 0
        printf "Usage: lx_module <module_ptr>\n"
    else
        set $m = (struct module *)$arg0
        printf "=== struct module @ %p ===\n", $m
        printf "name:           %s\n", $m->name
        printf "state:          %d (0=LIVE, 1=COMING, 2=GOING)\n", $m->state
        printf "core_layout.base: %p\n", $m->core_layout.base
        printf "core_layout.size: %u\n", $m->core_layout.size
        printf "init_layout.base: %p\n", $m->init_layout.base
        printf "init_layout.size: %u\n", $m->init_layout.size
    end
end
document lx_module
    Print struct module details.
    Syntax: lx_module <module_ptr>
end

#------------------------------------------------------------------------------
# Kernel Debugging Utilities
#------------------------------------------------------------------------------

define lx_container_of
    if $argc < 3
        printf "Usage: lx_container_of <ptr> <type> <member>\n"
        printf "Returns the container structure address\n"
    else
        set $container = ($arg1 *)((char *)$arg0 - (unsigned long)&(($arg1 *)0)->$arg2)
        printf "Container address: %p\n", $container
        p *$container
    end
end
document lx_container_of
    Perform container_of operation.
    Syntax: lx_container_of <member_ptr> <container_type> <member_name>
    Example: lx_container_of list_ptr "struct my_struct" list
end

define lx_offsetof
    if $argc < 2
        printf "Usage: lx_offsetof <type> <member>\n"
    else
        printf "offsetof(%s, %s) = %lu\n", "$arg0", "$arg1", (unsigned long)&(($arg0 *)0)->$arg1
    end
end
document lx_offsetof
    Calculate offsetof a member in a structure.
    Syntax: lx_offsetof <type> <member>
    Example: lx_offsetof "struct task_struct" comm
end

define lx_typeof
    if $argc == 0
        printf "Usage: lx_typeof <expression>\n"
    else
        whatis $arg0
    end
end
document lx_typeof
    Print type of expression (alias for whatis).
    Syntax: lx_typeof <expression>
end

define lx_symbol
    if $argc == 0
        printf "Usage: lx_symbol <address>\n"
    else
        info symbol $arg0
    end
end
document lx_symbol
    Find symbol name for address.
    Syntax: lx_symbol <address>
end

define lx_addr
    if $argc == 0
        printf "Usage: lx_addr <symbol>\n"
    else
        printf "%s is at %p\n", "$arg0", &$arg0
    end
end
document lx_addr
    Get address of symbol.
    Syntax: lx_addr <symbol_name>
end

#------------------------------------------------------------------------------
# Kernel Initialization / Debugging Scenario Helpers
#------------------------------------------------------------------------------

define lx_dmesg_manual
    printf "=== Kernel Log Buffer ===\n"
    printf "For full dmesg, use 'lx-dmesg' (requires kernel GDB scripts)\n"
    printf "Or examine log_buf manually:\n"
    printf "  p log_buf\n"
    printf "  x/1000s log_buf\n"
end
document lx_dmesg_manual
    Instructions for viewing kernel log buffer.
    Usage: lx_dmesg_manual
    Note: Use 'lx-dmesg' if kernel GDB scripts are loaded.
end

define lx_panic_info
    printf "=== Panic Information ===\n"
    printf "Check these for panic context:\n"
    printf "  p panic_cpu\n"
    printf "  p panic_notifiers\n"
    printf "  bt (for panic backtrace)\n"
    printf "  lx_dmesg_manual (for kernel log)\n"
end
document lx_panic_info
    Print hints for examining kernel panic.
    Usage: lx_panic_info
end

define lx_oops_info
    printf "=== Oops Information ===\n"
    printf "For oops analysis:\n"
    printf "  1. Check backtrace: bt\n"
    printf "  2. Check faulting address in registers\n"
    printf "  3. lx_task_info on current task\n"
    printf "  4. Check dmesg for oops message\n"
end
document lx_oops_info
    Print hints for examining kernel oops.
    Usage: lx_oops_info
end

#------------------------------------------------------------------------------
# Kernel Quick Reference
#------------------------------------------------------------------------------

define lx_help
    printf "=== Linux Kernel GDB Commands ===\n\n"
    printf "Data Structures:\n"
    printf "  lx_list_head, lx_list_for_each, lx_list_count\n"
    printf "  lx_hlist_for_each\n"
    printf "  lx_rb_first, lx_rb_next, lx_rb_for_each\n"
    printf "  lx_container_of, lx_offsetof\n\n"
    printf "Tasks/Processes:\n"
    printf "  lx_task_info, lx_task_stack, lx_current\n\n"
    printf "Synchronization:\n"
    printf "  lx_spinlock, lx_mutex, lx_rwlock, lx_semaphore, lx_rcu\n"
    printf "  lx_waitqueue\n\n"
    printf "Work/Timers:\n"
    printf "  lx_work_struct, lx_delayed_work\n"
    printf "  lx_timer, lx_hrtimer\n\n"
    printf "Memory:\n"
    printf "  lx_page, lx_vma, lx_mm, lx_slab_cache\n"
    printf "  lx_per_cpu\n\n"
    printf "Devices:\n"
    printf "  lx_device, lx_pci_dev, lx_platform_device\n\n"
    printf "Network:\n"
    printf "  lx_sk_buff, lx_net_device, lx_sock\n\n"
    printf "Filesystem:\n"
    printf "  lx_inode, lx_dentry, lx_file, lx_super_block\n\n"
    printf "Other:\n"
    printf "  lx_irq_desc, lx_module\n"
    printf "  lx_symbol, lx_addr\n"
    printf "  lx_panic_info, lx_oops_info\n\n"
    printf "Note: For full kernel support, load kernel GDB scripts:\n"
    printf "  source /path/to/linux/scripts/gdb/vmlinux-gdb.py\n"
    printf "Then use 'apropos lx-' to see all kernel commands.\n"
end
document lx_help
    Show Linux kernel debugging commands quick reference.
    Usage: lx_help
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
    printf "Linux Kernel (type 'lx_help' for full list):\n"
    printf "  lx_list_for_each, lx_rb_for_each, lx_hlist_for_each\n"
    printf "  lx_task_info, lx_spinlock, lx_mutex, lx_waitqueue\n"
    printf "  lx_page, lx_vma, lx_mm, lx_sk_buff, lx_net_device\n"
    printf "  lx_inode, lx_dentry, lx_file, lx_device, lx_pci_dev\n\n"
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
printf "╔════════════════════════════════════════════════════════════════════╗\n"
printf "║   Custom .gdbinit loaded - C/C++/Python/GStreamer/CUDA/Kernel      ║\n"
printf "║            Type 'gdb_help' for command reference                   ║\n"
printf "║            Type 'lx_help' for kernel commands                      ║\n"
printf "╚════════════════════════════════════════════════════════════════════╝\n"
printf "\n"