require 'json'
require 'yaml'
require_relative 'task'

class TaskManager
  attr_accessor :collection

  def initialize
    @collection = {}
  end

  def add_task(title, categories, priority, due_date, estimated_hours)
    new_id = @collection.keys.max.to_i + 1

    @collection[new_id] = Task.new(
      title,
      categories,
      priority,
      due_date,
      estimated_hours
    )

    puts "Завдання успішно додано з id #{new_id}."
  end

  def edit_task(id, new_data)
    unless @collection.key?(id)
      puts "Помилка: завдання з id #{id} не знайдено."
      return
    end

    task = @collection[id]

    new_data.each do |field, value|
      if task.respond_to?("#{field}=")
        task.send("#{field}=", value)
      else
        puts "Попередження: поле #{field} не існує."
      end
    end

    puts "Завдання з id #{id} успішно оновлено."
  end

  def delete_task(id)
    unless @collection.key?(id)
      puts "Помилка: завдання з id #{id} не знайдено."
      return
    end

    @collection.delete(id)
    puts "Завдання з id #{id} успішно видалено."
  end

  def list_tasks
    if @collection.empty?
      puts "Список завдань порожній."
      return
    end

    @collection.each do |id, task|
      print_task(id, task)
    end
  end

  def find_by_title(query)
    result = @collection.select do |_id, task|
      task.title.downcase.include?(query.downcase)
    end

    if result.empty?
      puts "Завдання за запитом '#{query}' не знайдено."
    else
      result.each do |id, task|
        print_task(id, task)
      end
    end
  end

  def filter_by_category(category)
    result = @collection.select do |_id, task|
      task.categories.any? { |cat| cat.downcase == category.downcase }
    end

    if result.empty?
      puts "Завдань у категорії '#{category}' не знайдено."
    else
      result.each do |id, task|
        print_task(id, task)
      end
    end
  end

  def filter_by_priority(priority)
    result = @collection.select do |_id, task|
      task.priority.downcase == priority.downcase
    end

    if result.empty?
      puts "Завдань з пріоритетом '#{priority}' не знайдено."
    else
      result.each do |id, task|
        print_task(id, task)
      end
    end
  end

  def save_to_json(filename)
    data = {}

    @collection.each do |id, task|
      data[id] = task.to_h
    end

    File.open(filename, 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end

    puts "Дані успішно збережено у JSON-файл #{filename}."
  end

  def load_from_json(filename)
    begin
      data = JSON.parse(File.read(filename))

      @collection = {}

      data.each do |id, task_hash|
        @collection[id.to_i] = Task.from_h(task_hash)
      end

      puts "Дані успішно завантажено з JSON-файлу #{filename}."
    rescue Errno::ENOENT
      puts "Помилка: JSON-файл #{filename} не знайдено."
    rescue JSON::ParserError
      puts "Помилка: неправильний формат JSON-файлу."
    end
  end

  def save_to_yaml(filename)
    File.open(filename, 'w') do |file|
      file.write(YAML.dump(@collection))
    end

    puts "Дані успішно збережено у YAML-файл #{filename}."
  end

  def load_from_yaml(filename)
    begin
      @collection = YAML.load_file(
        filename,
        permitted_classes: [Task, Symbol],
        aliases: true
      ) || {}

      puts "Дані успішно завантажено з YAML-файлу #{filename}."
    rescue Errno::ENOENT
      puts "Помилка: YAML-файл #{filename} не знайдено."
    rescue Psych::SyntaxError
      puts "Помилка: неправильний формат YAML-файлу."
    end
  end

  private

  def print_task(id, task)
    puts "ID: #{id}"
    puts "Назва: #{task.title}"
    puts "Категорії: #{task.categories.join(', ')}"
    puts "Пріоритет: #{task.priority}"
    puts "Дата виконання: #{task.due_date}"
    puts "Орієнтовний час: #{task.estimated_hours} год."
    puts "Виконано: #{task.completed ? 'Так' : 'Ні'}"
    puts "-" * 40
  end
end