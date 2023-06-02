#! /usr/bin/ruby

$LOAD_PATH << '../.'

require 'rubuild'

main = Rubuild::create_executable('main', 'build').add_sources(['src/main.c', 'src/other.c'], 'int')
lib = Rubuild::create_static_library('lib', 'build').add_sources(['lib/lib.c'], 'int')

main.add_include_dir('lib')
main.add_dependency(lib)

Rubuild::build_target(main)