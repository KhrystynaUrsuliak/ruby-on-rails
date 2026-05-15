require 'json'
require 'yaml'

def add_task(collection, title, categories, priority, due_date, estimated_hours, completed = false)
  new_id = collection.keys.max.to_i + 1

  collection[new_id] = {
    title: title,
    categories: categories,
    priority: priority,
    due_date: due_date,
    estimated_hours: estimated_hours,
    completed: completed
  }

  puts "Завдання додано з id #{new_id}"
  new_id
end

def edit_task(collection, id, new_data)
  unless collection.key?(id)
    puts "Помилка: завдання з id #{id} не знайдено"
    return false
  end

  new_data.each do |key, value|
    if collection[id].key?(key)
      collection[id][key] = value
    else
      puts "Попередження: поле #{key} не існує"
    end
  end

  puts "Завдання з id #{id} оновлено"
  true
end

def delete_task(collection, id)
  unless collection.key?(id)
    puts "Помилка: завдання з id #{id} не знайдено"
    return false
  end

  collection.delete(id)
  puts "Завдання з id #{id} видалено"
  true
end

def list_tasks(collection)
  if collection.empty?
    puts "Список завдань порожній"
    return
  end

  collection.each do |id, task|
    puts "ID: #{id}"
    puts "Назва: #{task[:title]}"
    puts "Категорії: #{task[:categories].join(', ')}"
    puts "Пріоритет: #{task[:priority]}"
    puts "Дата виконання: #{task[:due_date]}"
    puts "Орієнтовний час: #{task[:estimated_hours]} год."
    puts "Виконано: #{task[:completed] ? 'Так' : 'Ні'}"
    puts "-" * 40
  end
end

def find_by_title(collection, query)
  result = collection.select do |_id, task|
    task[:title].downcase.include?(query.downcase)
  end

  if result.empty?
    puts "Завдання за запитом '#{query}' не знайдено"
  else
    list_tasks(result)
  end

  result
end

def filter_by_category(collection, category)
  result = collection.select do |_id, task|
    task[:categories].any? { |cat| cat.downcase == category.downcase }
  end

  if result.empty?
    puts "Завдань у категорії '#{category}' не знайдено"
  else
    list_tasks(result)
  end

  result
end

def filter_by_priority(collection, priority)
  result = collection.select do |_id, task|
    task[:priority].downcase == priority.downcase
  end

  if result.empty?
    puts "Завдань з пріоритетом '#{priority}' не знайдено"
  else
    list_tasks(result)
  end

  result
end

def save_to_json(collection, filename)
  File.open(filename, 'w') do |file|
    file.write(JSON.pretty_generate(collection))
  end

  puts "Дані збережено у JSON-файл #{filename}"
end

def load_from_json(filename)
  begin
    data = JSON.parse(File.read(filename))

    data.transform_keys(&:to_i).transform_values do |task|
      task.transform_keys(&:to_sym)
    end
  rescue Errno::ENOENT
    puts "Помилка: файл #{filename} не існує"
    {}
  rescue JSON::ParserError
    puts "Помилка: файл #{filename} має неправильний JSON-формат"
    {}
  end
end

def save_to_yaml(collection, filename)
  File.open(filename, 'w') do |file|
    file.write(collection.to_yaml)
  end

  puts "Дані збережено у YAML-файл #{filename}"
end

def load_from_yaml(filename)
  begin
    data = YAML.load_file(filename)

    data || {}
  rescue Errno::ENOENT
    puts "Помилка: файл #{filename} не існує"
    {}
  end
end


tasks = {
  1 => {
    title: "Купити продукти",
    categories: ["Покупки", "Особисті"],
    priority: "Високий",
    due_date: "2024-02-28",
    estimated_hours: 2,
    completed: false
  },
  2 => {
    title: "Завершити звіт",
    categories: ["Робота", "Документи"],
    priority: "Середній",
    due_date: "2024-03-01",
    estimated_hours: 5,
    completed: false
  }
}

puts "Усі завдання:"
list_tasks(tasks)

puts "\nДодавання нового завдання:"
add_task(
  tasks,
  "Підготувати презентацію",
  ["Навчання", "Документи"],
  "Високий",
  "2024-03-05",
  3,
  false
)

puts "\nРедагування завдання:"
edit_task(tasks, 1, { completed: true, estimated_hours: 1 })

puts "\nПошук за назвою:"
find_by_title(tasks, "звіт")

puts "\nФільтр за категорією:"
filter_by_category(tasks, "Документи")

puts "\nФільтр за пріоритетом:"
filter_by_priority(tasks, "Високий")

puts "\nЗбереження у файли:"
save_to_json(tasks, "tasks.json")
save_to_yaml(tasks, "tasks.yaml")

puts "\nЗавантаження з JSON:"
loaded_json_tasks = load_from_json("tasks.json")
list_tasks(loaded_json_tasks)

puts "\nЗавантаження з YAML:"
loaded_yaml_tasks = load_from_yaml("tasks.yaml")
list_tasks(loaded_yaml_tasks)

puts "\nВидалення завдання:"
delete_task(tasks, 2)

puts "\nСписок після видалення:"
list_tasks(tasks)