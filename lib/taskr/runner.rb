module Taskr
  class Runner
    def self.execute

      tl = TaskList.new

      optparse = OptionParser.new do |opts|

        opts.banner =<<EOS
Usage: taskr [options]
  Two of the most used options are -l and -a,
  and you can use these options without the switches.

  e.g.
    $ taskr awesome task here hurray for no switches
      #adds the task to the list and is equivalent to taskr -a awes..
    $ taskr
      #lists all the tasks and is equivalent to 'taskr -l'

Options:
EOS

        opts.on('-n', '--new task description', :NONE, 'Adds new task to the list') do
          tl.append(ARGV.join(' '))
          exit
        end
        opts.on('-f', '--find :tag1 :tag2 ..', Array, 'Find all the tasks with specified tag') do |tags|
          tl.find_tags(tags)
          exit
        end
        opts.on('-a','--all' ,'List all the tasks' ) do
          tl.list_all
          exit
        end
        opts.on('-d','--delete id1,id2,..', Array,'Delete tasks(s)' ) do |ids|
          tl.delete(ids)
          exit
        end
        opts.on('-o','--hide id1,id2,..', Array,'Hide tasks(s)' ) do |ids|
          tl.untag(ids, [:hidden])
          tl.tag(ids, [:hidden])
          tl.output(ids)
          exit
        end
        opts.on('-O','--unhide id1,id2,..', Array,'Unhide tasks(s)' ) do |ids|
          tl.untag(ids, [:hidden])
          tl.output(ids)
          exit
        end
        opts.on('-i','--tray id1,id2,..', Array,'Adds tasks(s) to tray' ) do |ids|
          tl.untag(ids, [:tray])
          tl.tag(ids, [:tray])
          tl.output(ids)
          exit
        end
        opts.on('-I','--untray id1,id2,..', Array,'Removes tasks(s) from tray' ) do |ids|
          tl.untag(ids, [:tray])
          tl.output(ids)
          exit
        end
        opts.on('-s','--search REGEX' ,'Search all the tasks' ) do |q|
          tl.search(q)
          exit
        end
        opts.on('-e','--edit' ,'Open the tasks file in vi' ) do
          #TODO: should check the $EDITOR var and use it
          system("vi #{Filepath}")
          exit
        end
        opts.on('-t','--tag id1,id2,.. :tag1 :tag2 ..', Array, 'Tag task(s)') do |ids|
          tl.tag(ids, ARGV)
          tl.output(ids)
          exit
        end
        opts.on('-u','--untag id1,id2,.. :tag1 :tag2 ..', Array, 'Untag task(s)') do |ids|
          tl.untag(ids, ARGV)
          tl.output(ids)
          exit
        end

        opts.on('-c','--today id1,id2,.. :tag1 :tag2 ..', Array, 'Marks task(s) due today') do |ids|
          today_tag = Task::TagTransforms.find{|k,v| v == ':today'}.first
          tag = Task::TagTransforms.find{|k,v| v == ':tomorrow'}.first
          tl.untag(ids, [tag])
          tl.untag(ids, [today_tag])
          tl.tag(ids, [today_tag])
          tl.output(ids)
          exit
        end

        opts.on('-p','--postpone id1,id2,..', Array, 'Postpone task(s) to tomorrow') do |ids|
          #TODO:cleanup this implementation
          today_tag = Task::TagTransforms.find{|k,v| v == ':today'}.first
          tag = Task::TagTransforms.find{|k,v| v == ':tomorrow'}.first
          tl.untag(ids, [today_tag])
          tl.untag(ids, [tag])
          tl.tag(ids, [tag])
          tl.output(ids)
          exit
        end
        #opts.on('today','today','today') do
        #tag = Task::TagTransforms.find{|k,v| v == ':today'}.first
        #tl.tag(ARGV[1], tag)
        #exit
        #end
        #opts.on('-tray','tray','tray') do
        #tl.tag(ARGV[1], ':tray')
        #exit
        #end
        #opts.on('show','show','show') do
        #tl.show(ARGV[1])
        #exit
        #end
        opts.on('-x','--xmobar','Text to be shown in xmobar') do
          tl.xmobar
          exit
        end
        opts.on( '-v', '--version', 'Display version of taskr' ) do
          puts Taskr::VERSION
          exit
        end
        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end

      begin
        optparse.parse!
      rescue OptionParser::MissingArgument => e
        puts e.message
        puts optparse.inspect
      end

      #if it reaches this line, it means no swtiches/options were passed
      if ARGV.empty?
        tl.list
      else
        tl.append(ARGV.join(' '))
      end

    end
  end
end
