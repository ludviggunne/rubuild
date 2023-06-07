
module Rubuild

    def strip(path)

        i1 = path.rindex('/') || -1
        i2 = path.rindex('.')
        return path[i1 + 1..i2 - 1]
    end

    def create_job_stack(target)

        # Post order traversal
        job_stack = Array.new
        traversal_stack = Array.new

        traversal_stack.push(target)
        while !traversal_stack.empty?

            t = traversal_stack.pop

            # Remove duplicates
            job_stack.delete(t)
            job_stack.push(t)

            traversal_stack += t.dependencies
        end

        return job_stack
    end

    def build_target(target)
        job_stack = create_job_stack(target)

        while !job_stack.empty?

            job = job_stack.pop
            build = false
    
            if job.is_a? TranslationUnit
                build = true
            elsif !File.exists? job.output

                # Rebuild if output file doesn't exist
                build = true
            else
                job_time = File.mtime(job.output).to_r
                job.dependencies.each do |dep|

                    if !File.exists? dep.output
                        
                        # Rebuild if dependency output doesn't exists
                        # Let gcc handle error
                        build = true
                        break
                    end

                    if File.mtime(dep.output).to_r > job_time

                        # Rebuild if output is older than any dependency
                        build = true
                        break
                    end
                end
            end

            if build
                job.build!()
            end
        end
    end

    def create_executable(name, output = '.')
        exe = Executable.new(name, output)
        return exe
    end

    def create_static_library(name, output = '.')
        lib = StaticLib.new(name, output)
        return lib
    end

    module_function :build_target
    module_function :strip
    module_function :create_job_stack
    module_function :create_executable
    module_function :create_static_library

    # Common functionality for targets
    class Target
        attr_reader :output
        attr_accessor :dependencies

        def initialize
            @dependencies = Array.new
            @system_libs = Array.new
            @include_dirs = Array.new
        end

        def add_dependency(dependency)
            @dependencies.push(dependency)
        end

        def add_sources(sources, output = '.')
            sources.each do |src|
                tu = TranslationUnit.new(src, output)
                @include_dirs.each do |dir|
                    tu.add_include_dir(dir)
                end
                @dependencies.push(tu)
            end
            return self
        end

        def add_include_dir(dir)
            @include_dirs.push(dir)
            @dependencies.each do |dep|
                if dep.is_a? TranslationUnit
                    dep.add_include_dir(dir)
                end
            end
            return self
        end

        def link_system_lib(lib)
            @system_libs.push(lib)
            return self
        end

        def clean
            `rm -f #{@output}`
            @dependencies.each do |dep|
                dep.clean
            end
        end
    end

    class TranslationUnit < Target

        def initialize(source, output = '.')
            super()
            @source = source
            @output = "#{output}/#{Rubuild::strip(source)}.o"
            discard_err = `mkdir #{output} 2>&1`
        end

        def build!()

            if !File.exists? @output or !File.exists? @source

                # Rebuild if either file is missing
                # (if source is missing, let gcc deal with errors)
                rebuild = true
            else

                # Rebuild if target is older than source
                rebuild =
                    File.mtime(@source).to_r >
                    File.mtime(@output).to_r
            end

            if rebuild

                puts "Compiling #{@output}"
                incs = @include_dirs.map { |dir| "-I#{dir}" }
                `gcc -c #{@source} #{incs.join(' ')} -o #{@output}`
            end
        end
    end

    class Executable < Target

        def initialize(name, output = '.')
            super()
            @name = name
            @output = "#{output}/#{name}"
            discard_err = `mkdir #{output} 2>&1`
        end

        def build!()

            puts "Linking #{@output}"

            bins = @dependencies.map { |dep| dep.output }
            syslibs = @system_libs.map { |lib| "-l#{lib}" }
            `gcc #{bins.join(' ')} #{syslibs.join(' ')} -o #{@output}`
        end
    end

    class StaticLib < Target

        def initialize(name, output = '.')
            super()
            @name = name
            @output = "#{output}/#{name}.so"
            discard_err = `mkdir #{output} 2>&1`
        end

        def build!()

            puts "Linking #{@output}"

            bins = @dependencies.map { |dep| dep.output }
            `ar rcs #{@output} #{bins.join(' ')}`
        end
    end
end