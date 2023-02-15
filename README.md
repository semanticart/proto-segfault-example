# Protobuf Ruby Segfault example

For some versions of ruby, the current official release of the `google-protobuf` gem (3.21.12) will segfault when iterating over proto objects in threads.

I haven't tested every version of ruby, but it at least impacts these versions

- ruby 2.7.7p221 (2022-11-24 revision 168ec2b1e5) [arm64-darwin22]
- ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [arm64-darwin22]
- ruby 3.2.0 (2022-12-25 revision a528908271) [arm64-darwin22]
- ruby 3.1.3p185 (2022-11-24 revision 1a6b16756e) [arm64-darwin22]

You can see this behavior with

```
BUNDLE_GEMFILE=Gemfile bundle install
BUNDLE_GEMFILE=Gemfile bundle exec ruby thread_example.rb
```

Note that you might need to run the last command a few times to see the segfault but it happens nearly every time in my experience.

This seems to be fixed in the pre-release gem (4.0.0.rc.1). You can confirm the fix with

```
BUNDLE_GEMFILE=GemfilePre bundle install
BUNDLE_GEMFILE=GemfilePre bundle exec ruby thread_example.rb 
```

---

Example crash output for v3.21.12:

```
-- Control frame information -----------------------------------------------
c:0007 p:---- s:0026 e:000025 CFUNC  :each
c:0006 p:0007 s:0022 e:000021 BLOCK  thread_example.rb:42 [FINISH]
c:0005 p:---- s:0018 e:000017 CFUNC  :each
c:0004 p:0008 s:0014 e:000013 BLOCK  thread_example.rb:41 [FINISH]
c:0003 p:---- s:0010 e:000009 CFUNC  :each
c:0002 p:0009 s:0006 e:000005 BLOCK  thread_example.rb:40 [FINISH]
c:0001 p:---- s:0003 e:000002 (none) [FINISH]

-- Ruby level backtrace information ----------------------------------------
thread_example.rb:40:in `block (2 levels) in <main>'
thread_example.rb:40:in `each'
thread_example.rb:41:in `block (3 levels) in <main>'
thread_example.rb:41:in `each'
thread_example.rb:42:in `block (4 levels) in <main>'
thread_example.rb:42:in `each'
```

Example content from ~/Library/Logs/DiagnosticReports

```
-------------------------------------
Translated Report (Full Report Below)
-------------------------------------

Process:               ruby [90659]
Path:                  /Users/USER/*/ruby
Identifier:            ruby
Version:               ???
Code Type:             ARM-64 (Native)
Parent Process:        fish [12064]
User ID:               501

Date/Time:             2023-02-15 15:32:09.6486 -0500
OS Version:            macOS 13.1 (22C65)
Report Version:        12
Anonymous UUID:        86A9AA47-CD12-13F2-C078-E4784197ABEF

Sleep/Wake UUID:       3E3C60C0-79AC-47D0-8E8B-27EE980939EC

Time Awake Since Boot: 780000 seconds
Time Since Wake:       26946 seconds

System Integrity Protection: enabled

Crashed Thread:        221  thread_example.rb:39

Exception Type:        EXC_BAD_ACCESS (SIGABRT)
Exception Codes:       KERN_INVALID_ADDRESS at 0x0000000000000008
Exception Codes:       0x0000000000000001, 0x0000000000000008

VM Region Info: 0x8 is not in any region.  Bytes before following region: 105553518919672
      REGION TYPE                    START - END         [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      MALLOC_NANO (reserved)   600018000000-600020000000 [128.0M] rw-/rwx SM=NUL  ...(unallocated)

Application Specific Information:
abort() called


Thread 0::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	       0x19cfae2c0 poll + 8
1   libruby.3.1.dylib             	       0x10525060c rb_sigwait_sleep + 916
2   libruby.3.1.dylib             	       0x105251c0c native_sleep + 476
3   libruby.3.1.dylib             	       0x10525c168 thread_join_sleep + 392
4   libruby.3.1.dylib             	       0x1050f34fc rb_ensure + 344
5   libruby.3.1.dylib             	       0x10525bf10 thread_join + 156
6   libruby.3.1.dylib             	       0x1052589bc thread_join_m + 220
7   libruby.3.1.dylib             	       0x105297e98 vm_call0_body + 928
8   libruby.3.1.dylib             	       0x1052b02f8 rb_call0 + 812
9   libruby.3.1.dylib             	       0x10529a560 rb_yield + 180
10  libruby.3.1.dylib             	       0x10505e764 rb_ary_collect + 276
11  libruby.3.1.dylib             	       0x1052aac38 vm_call_cfunc_with_frame + 232
12  libruby.3.1.dylib             	       0x1052acf7c vm_sendish + 320
13  libruby.3.1.dylib             	       0x10528d7d0 vm_exec_core + 9752
14  libruby.3.1.dylib             	       0x1052a1dbc rb_vm_exec + 2596
15  libruby.3.1.dylib             	       0x1050f253c rb_ec_exec_node + 300
16  libruby.3.1.dylib             	       0x1050f23b4 ruby_run_node + 96
17  ruby                          	       0x104babf38 main + 92
18  dyld                          	       0x19ccbbe50 start + 2544

Thread 1:
0   libsystem_kernel.dylib        	       0x19cfae2c0 poll + 8
1   libruby.3.1.dylib             	       0x10525c40c timer_pthread_fn + 168
2   libsystem_pthread.dylib       	       0x19cfe506c _pthread_start + 148
3   libsystem_pthread.dylib       	       0x19cfdfe2c thread_start + 8

Thread 2:: thread_example.rb:39
0   libsystem_kernel.dylib        	       0x19cfa9564 __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x19cfe5638 _pthread_cond_wait + 1232
2   libruby.3.1.dylib             	       0x10525a9cc native_cond_sleep + 568
3   libruby.3.1.dylib             	       0x105251ac0 native_sleep + 144
4   libruby.3.1.dylib             	       0x105250bf8 do_mutex_lock + 412
5   libruby.3.1.dylib             	       0x10525140c rb_mutex_synchronize + 36
6   libruby.3.1.dylib             	       0x105139f80 io_fwritev + 952
7   libruby.3.1.dylib             	       0x105139b0c io_writev + 304
8   libruby.3.1.dylib             	       0x105297e98 vm_call0_body + 928
9   libruby.3.1.dylib             	       0x10529598c rb_funcallv + 460
10  libruby.3.1.dylib             	       0x10512a1fc rb_io_puts + 108
11  libruby.3.1.dylib             	       0x105297e98 vm_call0_body + 928
12  libruby.3.1.dylib             	       0x1052b02f8 rb_call0 + 812
13  libruby.3.1.dylib             	       0x1052aac38 vm_call_cfunc_with_frame + 232
14  libruby.3.1.dylib             	       0x1052acf7c vm_sendish + 320
15  libruby.3.1.dylib             	       0x10528d820 vm_exec_core + 9832
16  libruby.3.1.dylib             	       0x1052a1dbc rb_vm_exec + 2596
17  libruby.3.1.dylib             	       0x1052b1600 invoke_block_from_c_bh + 932
18  libruby.3.1.dylib             	       0x10529a560 rb_yield + 180
19  libruby.3.1.dylib             	       0x1051d7f38 range_each + 356
20  libruby.3.1.dylib             	       0x1052aac38 vm_call_cfunc_with_frame + 232
21  libruby.3.1.dylib             	       0x1052acf7c vm_sendish + 320
22  libruby.3.1.dylib             	       0x10528d7d0 vm_exec_core + 9752
23  libruby.3.1.dylib             	       0x1052a1dbc rb_vm_exec + 2596
24  libruby.3.1.dylib             	       0x10529fa7c rb_vm_invoke_proc + 1204
25  libruby.3.1.dylib             	       0x10525ba30 thread_do_start_proc + 688
26  libruby.3.1.dylib             	       0x10525b210 thread_start_func_2 + 1184
27  libruby.3.1.dylib             	       0x10525abfc thread_start_func_1 + 264
28  libsystem_pthread.dylib       	       0x19cfe506c _pthread_start + 148
29  libsystem_pthread.dylib       	       0x19cfdfe2c thread_start + 8

...
```
