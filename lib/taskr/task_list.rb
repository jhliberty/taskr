class TaskList

  def initialize
    @lines = File.readlines(Filepath).map{|x| x.chomp.strip}.reject{|x| x.empty?}
    @tasks = @lines.map{|x| Task.parse(x)}.sort_by{|x| [x.priority, x.raw_time]}
  end

  def list()
      print @tasks.find_all(&:visible?)
  end

  def list_all()
    print @tasks
  end

  def search(q)
    print @tasks.select{|x| x.raw =~ /#{q}/i}
  end

  def print(tasks)
    #TODO: should say listing (5/25) tasks
    puts "(#{tasks.count.to_s.colorize(:red)}) tasks"
    puts '---------------------'.colorize(:blue)
    tasks.each do |t|
      puts t
    end
  end

  def output(ids)
    #TODO: should say listing (5/25) tasks
    tasks = find(ids)
    puts "(#{tasks.count.to_s.colorize(:red)}) tasks"
    puts '---------------------'.colorize(:blue)
    tasks.each do |t|
      puts t
    end
  end

  def append(task)
    #TODO: decipher special tags like :today, :tomorrow
    task = task.strip
    File.open(Filepath, 'a') {|f| f.puts "#{Time.now.strftime "%Y%m%d%H%M%S"} #{task}"} unless task.empty?
  end

  def hide(ids)
    tasks = find(ids)
    tag = tagify([:hidden])
    tasks.each {|task| task.tags += tag }
    save
  end

  def tag(ids, tags)
    tasks = find(ids)
    tags = tagify(tags)

    tasks.each {|task| task.tags += tags }
    save
  end

  def untag(ids, tags)
    tasks = find(ids)
    tags = tagify(tags)

    tasks.each {|task| task.tags -= tags }

    save
  end

  def delete(ids)
    tasks = find(ids)
    tasks.each{|x| @tasks.delete(x)}
    save

    File.open(Filepath+".done", 'a') do |f|
      tasks.each{|task| f.puts "#{Time.now.strftime "%Y%m%d%H%M%S"} #{task.serialize}" }
    end
    puts tasks
  end

  def save
    task_data = @tasks.map{|x| x.serialize }.join("\n")
    File.open(Filepath, 'w') {|f| f.puts task_data}
  end

  def xmobar
    puts "(#{@tasks.find_all(&:visible?).count}/#{@tasks.count}) #{@tasks.find_all{|x| x.tags.include?(':tray') && x.visible? }.map{|x| x.text[0..20] + '.. '}.join(':')}"
  end

  def tasks
    @tasks
  end

  def find(ids)
    tasks = @tasks.find_all{|x| ids.include?(x.id)}
    return tasks if tasks && !tasks.empty?
    puts 'task(s) not found'.colorize(:red)
    exit
  end

  def find_tags(tags)
    # TODO search by multiple tags
    # TODO search by today tomorrow yesterday
    tasks = @tasks.find_all{|x| x.tags.include?("#{tags[0]}")}
    if tasks && !tasks.empty?
      print tasks
      exit
    else
      puts 'No tasks with that tag found'.colorize(:red)
    end
  end

  def show(id)
    print find(id)
  end

  def tagify(tags)
    tags.map do |tag|
      tag =~ /^:.+/ ? tag : ":#{tag}"
    end
  end

end
