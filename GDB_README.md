# Comprehensive GDB Configuration

A feature-rich `.gdbinit` configuration for debugging C, C++, and Python applications, with specialized support for GStreamer pipelines, NVIDIA DeepStream, and CUDA.

## Features

- **STL Container Inspection** - Pretty-print vectors, lists, maps, sets, queues, and more
- **C++11/14/17 Support** - Smart pointers, `std::optional`, `std::string_view`
- **C Debugging Helpers** - Array printing, linked list traversal, hexdump, memory inspection
- **Python Integration** - Mixed C/Python debugging with `py-bt`, `py-locals`, GIL inspection
- **Thread Debugging** - Deadlock detection, mutex inspection, multi-thread backtraces
- **GStreamer Support** - Inspect elements, pads, buffers, caps, messages, and events
- **DeepStream/CUDA** - Batch metadata, frame metadata, object metadata, CUDA error checking
- **Linux Kernel Debugging** - list_head, rb_tree, task_struct, memory management, device/driver inspection
- **Productivity Shortcuts** - Breakpoint management, session saving, logging, quick examine commands

## Installation

```bash
# Clone or download
curl -o ~/.gdbinit https://raw.githubusercontent.com/blgnksy/extremeC/refs/heads/master/.gdbinit

# Or copy directly
cp .gdbinit ~/.gdbinit
```

## Requirements

### Base Requirements
- GDB 8.0+ (tested with GDB 10.x, 11.x, 12.x)
- GCC/G++ with debug symbols (`-g` flag)

### For Python Debugging
```bash
# Ubuntu/Debian
sudo apt install python3-dbg

# Fedora/RHEL
sudo dnf install python3-debug

# Arch Linux
yay -S python-debug  # AUR
```

### For GStreamer Debugging
```bash
# Ubuntu/Debian
sudo apt install libgstreamer1.0-dev libgstreamer1.0-0-dbg

# Debug symbols
sudo apt install gstreamer1.0-plugins-base-dbg gstreamer1.0-plugins-good-dbg
```

### For NVIDIA/DeepStream
- CUDA Toolkit with debug symbols
- DeepStream SDK

### For Linux Kernel Debugging
```bash
# Kernel with debug info (CONFIG_DEBUG_INFO=y)
# For QEMU debugging, also enable CONFIG_GDB_SCRIPTS=y

# The kernel source contains GDB Python scripts at:
# linux/scripts/gdb/vmlinux-gdb.py

# To load kernel scripts in GDB:
(gdb) add-auto-load-safe-path /path/to/linux
(gdb) source /path/to/linux/scripts/gdb/vmlinux-gdb.py

# Or add to ~/.gdbinit:
# add-auto-load-safe-path /path/to/linux
# set auto-load safe-path /

# Kernel scripts provide commands like:
# lx-dmesg, lx-lsmod, lx-ps, lx-symbols, lx-version
# Type 'apropos lx-' after loading to see all
```

## Quick Start

```bash
# Start GDB - config loads automatically
gdb ./my_program

# Inside GDB
(gdb) gdb_help          # Show all custom commands
(gdb) help user-defined # List all user-defined commands
```

## Command Reference

### STL Containers

| Command | Description | Example |
|---------|-------------|---------|
| `pvector` | Print std::vector contents | `pvector my_vec` |
| `pvector v idx` | Print single element | `pvector my_vec 5` |
| `pvector v start end` | Print range | `pvector my_vec 0 10` |
| `plist` | Print std::list | `plist my_list int` |
| `pmap` | Print std::map | `pmap my_map int string` |
| `pset` | Print std::set | `pset my_set int` |
| `pdequeue` | Print std::deque | `pdequeue my_deq` |
| `pstack` | Print std::stack | `pstack my_stack` |
| `pqueue` | Print std::queue | `pqueue my_queue` |
| `ppqueue` | Print std::priority_queue | `ppqueue my_pq` |
| `pbitset` | Print std::bitset | `pbitset my_bits` |
| `pstring` | Print std::string (pre-C++11) | `pstring my_str` |
| `pstring11` | Print std::string (C++11 SSO) | `pstring11 my_str` |

### Smart Pointers (C++11/14/17)

| Command | Description | Example |
|---------|-------------|---------|
| `pshared` | Print shared_ptr with ref counts | `pshared my_shared` |
| `punique` | Print unique_ptr | `punique my_unique` |
| `pweak` | Print weak_ptr | `pweak my_weak` |
| `poptional` | Print std::optional | `poptional my_opt int` |
| `pstring_view` | Print std::string_view | `pstring_view my_sv` |

### C Debugging

| Command | Description | Example |
|---------|-------------|---------|
| `parray` | Print C array | `parray arr 10` |
| `parray ptr cnt start` | Print with offset | `parray arr 5 10` |
| `clist` | Traverse linked list | `clist head next` |
| `hexdump` | Hex dump memory | `hexdump buffer 64` |
| `hexdump_ascii` | Hex dump with ASCII | `hexdump_ascii buf 128` |
| `ascii` | Print as string | `ascii str_ptr` |
| `offsets` | Show struct offsets | `offsets "struct foo"` |
| `vmmap` | Show memory mappings | `vmmap` |
| `malloc_info` | Print malloc stats | `malloc_info` |
| `heap_info` | Print heap stats | `heap_info` |

### Thread Debugging

| Command | Description | Example |
|---------|-------------|---------|
| `btall` | Backtrace all threads | `btall` |
| `threads_info` | Thread summary + brief bt | `threads_info` |
| `threads_full` | Full bt with locals | `threads_full` |
| `tswitch` | Switch thread + show context | `tswitch 2` |
| `find_deadlock` | Find blocked threads | `find_deadlock` |
| `mutex_info` | Inspect pthread_mutex_t | `mutex_info &my_mutex` |

### Python Debugging

| Command | Description | Example |
|---------|-------------|---------|
| `pybt` | Python backtrace | `pybt` |
| `pylist` | Python source listing | `pylist` |
| `pylocals` | Python local variables | `pylocals` |
| `pyup` / `pydown` | Navigate Python frames | `pyup` |
| `pyprint` | Print PyObject* | `pyprint obj` |
| `pytype` | Get Python type name | `pytype obj` |
| `pyrefcnt` | Get reference count | `pyrefcnt obj` |
| `pygil` | Check GIL state | `pygil` |

### GStreamer

| Command | Description | Example |
|---------|-------------|---------|
| `gst_element` | Print GstElement details | `gst_element elem` |
| `gst_pad` | Print GstPad details | `gst_pad pad` |
| `gst_buffer` | Print GstBuffer (PTS, DTS, etc.) | `gst_buffer buf` |
| `gst_caps` | Print GstCaps as string | `gst_caps caps` |
| `gst_message` | Print GstMessage details | `gst_message msg` |
| `gst_event` | Print GstEvent details | `gst_event event` |

### DeepStream / CUDA

| Command | Description | Example |
|---------|-------------|---------|
| `cuda_error` | Check last CUDA error | `cuda_error` |
| `cuda_sync` | Sync device + check errors | `cuda_sync` |
| `nvds_batch_meta` | Print NvDsBatchMeta | `nvds_batch_meta batch` |
| `nvds_frame_meta` | Print NvDsFrameMeta | `nvds_frame_meta frame` |
| `nvds_obj_meta` | Print NvDsObjectMeta | `nvds_obj_meta obj` |

### Linux Kernel - Data Structures

| Command | Description | Example |
|---------|-------------|---------|
| `lx_list_head` | Print list_head info | `lx_list_head &my_list` |
| `lx_list_for_each` | Iterate list_head | `lx_list_for_each &head "struct foo" list` |
| `lx_list_count` | Count list entries | `lx_list_count &my_list` |
| `lx_hlist_for_each` | Iterate hlist | `lx_hlist_for_each &head "struct foo" hnode` |
| `lx_rb_first` | Find first rb_tree node | `lx_rb_first &my_tree` |
| `lx_rb_for_each` | Iterate rb_tree | `lx_rb_for_each &root "struct foo" rb` |
| `lx_container_of` | Get container from member | `lx_container_of ptr "struct foo" member` |
| `lx_offsetof` | Get member offset | `lx_offsetof "struct task_struct" comm` |

### Linux Kernel - Tasks & Synchronization

| Command | Description | Example |
|---------|-------------|---------|
| `lx_task_info` | Print task_struct details | `lx_task_info $task` |
| `lx_task_stack` | Print task stack info | `lx_task_stack $task` |
| `lx_spinlock` | Print spinlock state | `lx_spinlock &lock` |
| `lx_mutex` | Print mutex state | `lx_mutex &mutex` |
| `lx_rwlock` | Print rwlock state | `lx_rwlock &rwlock` |
| `lx_semaphore` | Print semaphore state | `lx_semaphore &sem` |
| `lx_waitqueue` | Print wait queue + waiters | `lx_waitqueue &wq` |
| `lx_rcu` | Print RCU state | `lx_rcu` |

### Linux Kernel - Work & Timers

| Command | Description | Example |
|---------|-------------|---------|
| `lx_work_struct` | Print work_struct | `lx_work_struct &work` |
| `lx_delayed_work` | Print delayed_work | `lx_delayed_work &dwork` |
| `lx_timer` | Print timer_list | `lx_timer &timer` |
| `lx_hrtimer` | Print hrtimer | `lx_hrtimer &hrt` |

### Linux Kernel - Memory Management

| Command | Description | Example |
|---------|-------------|---------|
| `lx_page` | Print struct page | `lx_page $page` |
| `lx_vma` | Print vm_area_struct | `lx_vma $vma` |
| `lx_mm` | Print mm_struct | `lx_mm $mm` |
| `lx_slab_cache` | Print kmem_cache | `lx_slab_cache $cache` |
| `lx_per_cpu` | Access per-CPU variable | `lx_per_cpu runqueues 0` |

### Linux Kernel - Devices & Drivers

| Command | Description | Example |
|---------|-------------|---------|
| `lx_device` | Print struct device | `lx_device $dev` |
| `lx_pci_dev` | Print pci_dev | `lx_pci_dev $pdev` |
| `lx_platform_device` | Print platform_device | `lx_platform_device $pdev` |
| `lx_module` | Print struct module | `lx_module $mod` |
| `lx_irq_desc` | Print IRQ descriptor | `lx_irq_desc 42` |

### Linux Kernel - Network

| Command | Description | Example |
|---------|-------------|---------|
| `lx_sk_buff` | Print sk_buff | `lx_sk_buff $skb` |
| `lx_net_device` | Print net_device | `lx_net_device $netdev` |
| `lx_sock` | Print struct sock | `lx_sock $sk` |

### Linux Kernel - Filesystem

| Command | Description | Example |
|---------|-------------|---------|
| `lx_inode` | Print struct inode | `lx_inode $inode` |
| `lx_dentry` | Print struct dentry | `lx_dentry $dentry` |
| `lx_file` | Print struct file | `lx_file $file` |
| `lx_super_block` | Print super_block | `lx_super_block $sb` |

### Linux Kernel - Utilities

| Command | Description | Example |
|---------|-------------|---------|
| `lx_symbol` | Find symbol for address | `lx_symbol 0xffffffff81234567` |
| `lx_addr` | Get address of symbol | `lx_addr init_task` |
| `lx_panic_info` | Hints for panic analysis | `lx_panic_info` |
| `lx_oops_info` | Hints for oops analysis | `lx_oops_info` |
| `lx_help` | Kernel commands reference | `lx_help` |

### Breakpoints

| Command | Description | Example |
|---------|-------------|---------|
| `bp` | Set or list breakpoints | `bp main` |
| `bpc` | Conditional breakpoint | `bpc func 'x>100'` |
| `bpt` | Temporary breakpoint | `bpt main` |
| `bpregex` | Break on regex pattern | `bpregex process_.*` |
| `bp_save` | Save breakpoints to file | `bp_save` |
| `bp_load` | Load breakpoints from file | `bp_load` |
| `bpe` / `bpd` | Enable/disable breakpoints | `bpd 3` |

### Watchpoints

| Command | Description | Example |
|---------|-------------|---------|
| `ww` | Watch for writes | `ww my_var` |
| `wr` | Watch for reads | `wr my_var` |
| `wa` | Watch for any access | `wa my_var` |

### Memory Examination Shortcuts

| Command | Description | Example |
|---------|-------------|---------|
| `xw` | Examine as 32-bit words | `xw &var 8` |
| `xg` | Examine as 64-bit words | `xg &var 4` |
| `xb` | Examine as bytes | `xb buffer 64` |
| `xs` | Examine as string | `xs str_ptr` |
| `xi` | Examine as instructions | `xi main 20` |

### Context & Stack

| Command | Description | Example |
|---------|-------------|---------|
| `ctx` | Show full context | `ctx` |
| `btf` | Backtrace with locals | `btf` |
| `args` | Show function arguments | `args` |
| `locals` | Show local variables | `locals` |
| `up_n` / `down_n` | Move N frames | `up_n 3` |
| `regs` | Show registers | `regs` |
| `dis` | Disassemble function | `dis main` |
| `disn` | Disassemble N instructions | `disn 20` |

### Session Management

| Command | Description | Example |
|---------|-------------|---------|
| `log_start` | Start logging to file | `log_start debug.log` |
| `log_append` | Append to log file | `log_append debug.log` |
| `log_stop` | Stop logging | `log_stop` |
| `session_save` | Save breakpoints | `session_save mysession` |
| `session_load` | Load breakpoints | `session_load mysession` |

### Signal Handling

| Command | Description | Example |
|---------|-------------|---------|
| `signals_multimedia` | Configure for GStreamer | `signals_multimedia` |
| `signals_default` | Reset to defaults | `signals_default` |
| `signals_show` | Show signal config | `signals_show` |

### Exception Debugging (C++)

| Command | Description | Example |
|---------|-------------|---------|
| `check_exception` | Inspect throw (x86-64) | `check_exception 0` |
| `check_exception_arm64` | Inspect throw (ARM64) | `check_exception_arm64 0` |

## Usage Examples

### Debugging a Segfault
```gdb
(gdb) run
Program received signal SIGSEGV...
(gdb) bt                    # Where did it crash?
(gdb) ctx                   # Full context
(gdb) pvector my_data       # Inspect STL containers
(gdb) hexdump ptr 64        # Raw memory inspection
```

### Debugging Deadlocks
```gdb
(gdb) run &
# Program hangs...
(gdb) interrupt
(gdb) threads_info          # See all threads
(gdb) find_deadlock         # Find blocked threads
(gdb) tswitch 3             # Switch to suspicious thread
(gdb) mutex_info &the_mutex # Check mutex state
```

### Mixed Python/C++ Debugging
```gdb
$ gdb -ex run --args python3 my_app.py
(gdb) # Crash or breakpoint hit
(gdb) bt                    # C/C++ backtrace
(gdb) pybt                  # Python backtrace
(gdb) pylocals              # Python variables
(gdb) pygil                 # Is GIL held?
```

### GStreamer Pipeline Debugging
```gdb
(gdb) signals_multimedia    # Don't stop on SIGPIPE etc.
(gdb) break my_probe_callback
(gdb) run
(gdb) gst_buffer buf        # Inspect buffer at probe
(gdb) gst_element element   # Check element state
```

### DeepStream Debugging
```gdb
(gdb) break process_frame
(gdb) run
(gdb) nvds_batch_meta batch_meta
(gdb) nvds_frame_meta frame_meta
(gdb) nvds_obj_meta obj_meta
(gdb) cuda_error            # Check for CUDA errors
```

### Linux Kernel Debugging (QEMU/KGDB)
```gdb
# Connect to QEMU with kernel debug
$ gdb vmlinux
(gdb) target remote :1234

# Load kernel GDB scripts (optional but recommended)
(gdb) source /path/to/linux/scripts/gdb/vmlinux-gdb.py

# Basic inspection
(gdb) lx_help               # Show all kernel commands
(gdb) lx_task_info init_task
(gdb) lx_list_for_each &modules "struct module" list

# Examine a specific task
(gdb) p init_task
(gdb) lx_mm init_task->mm

# Traverse data structures
(gdb) lx_list_for_each &my_driver->device_list "struct my_device" list 20
(gdb) lx_rb_for_each &my_tree "struct my_node" rb_node
```

### Kernel Module Debugging
```gdb
# Debug a loaded module
(gdb) lx_module my_module_ptr
(gdb) lx_device &my_module->dev

# Examine PCI device
(gdb) lx_pci_dev pci_dev_ptr
```

### Kernel Crash Dump Analysis (crash/gdb)
```gdb
# Analyze with vmcore
$ gdb vmlinux vmcore

# Quick analysis
(gdb) bt                    # Backtrace at crash
(gdb) lx_panic_info         # Hints for panic analysis
(gdb) lx_task_info current  # Crashing task

# Memory analysis  
(gdb) lx_page page_ptr
(gdb) lx_vma vma_ptr

# Traverse wait queues for hung tasks
(gdb) lx_waitqueue &completion->wait
```

## Customization

### Disable Catch on Throw
Comment out these lines if you don't want to break on every C++ exception:
```gdb
# catch throw
# catch catch
```

### Add Project-Specific Commands
Create a `.gdbinit` in your project directory:
```gdb
# Project-specific settings
set args --config my_config.json
break my_important_function

# Custom command for this project
define my_debug
    print important_global
    pvector data_queue
end
```

### Change Default Settings
Modify the settings section at the top of the file:
```gdb
set pagination on           # Enable pagination
set print elements 100      # Limit array printing
set history size 5000       # Reduce history
```

## License

This configuration is released under the GPL license, based on original STL views by Dan Marinescu with extensions for modern C++, Python, GStreamer, and NVIDIA tooling.

The Linux kernel debugging commands are inspired by and complement the official kernel GDB scripts found in `linux/scripts/gdb/`