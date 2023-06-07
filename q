[1mdiff --git a/rubuild.rb b/rubuild.rb[m
[1mindex 6965b7c..153c855 100644[m
[1m--- a/rubuild.rb[m
[1m+++ b/rubuild.rb[m
[36m@@ -82,19 +82,39 @@[m [mmodule Rubuild[m
 [m
     def output_dot_file(root_target, output_path)[m
         jobstack = create_job_stack(root_target)[m
[32m+[m[32m        syslibs = Array.new[m
[32m+[m
[32m+[m[32m        jobstack.each do |target|[m
[32m+[m[32m            if target.respond_to? :system_libs[m
[32m+[m[32m                target.system_libs.each do |lib|[m
[32m+[m[32m                    syslibs.delete lib[m
[32m+[m[32m                    syslibs.push lib[m
[32m+[m[32m                end[m
[32m+[m[32m            end[m
[32m+[m[32m        end[m
 [m
         File.open(output_path, "w:UTF-8") { |file| [m
[31m-            str = "graph DependencyTree {\n"[m
[32m+[m
[32m+[m[32m            str = "digraph DependencyTree {\n"[m
 [m
             jobstack.each do |target|[m
                 str += "    \"#{target.output}\"[]\n"[m
             end[m
 [m
[32m+[m[32m            syslibs.each do |lib|[m
[32m+[m[32m                str += "    \"#{lib}\"\n"[m
[32m+[m[32m            end[m
[32m+[m
             str += "\n"[m
 [m
             jobstack.each do |target|[m
                 target.dependencies.each do |dep|[m
[31m-                    str += "    \"#{target.output}\" -- \"#{dep.output}\"[]\n"[m
[32m+[m[32m                    str += "    \"#{dep.output}\" -> \"#{target.output}\"[]\n"[m
[32m+[m[32m                end[m
[32m+[m[32m                if target.respond_to? :system_libs[m
[32m+[m[32m                    target.system_libs.each do |lib|[m
[32m+[m[32m                        str += "    \"#{lib}\" -> \"#{target.output}\"\n"[m
[32m+[m[32m                    end[m
                 end[m
             end[m
             str += "}"[m
[36m@@ -114,6 +134,7 @@[m [mmodule Rubuild[m
         attr_reader :output[m
         attr_accessor :dependencies[m
         attr_reader :name[m
[32m+[m[32m        attr_reader :system_libs[m
 [m
         def initialize[m
             @dependencies = Array.new[m
