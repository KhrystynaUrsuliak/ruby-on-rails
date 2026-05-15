require_relative 'task_manager'

class App
  YAML_FILE = 'tasks.yaml'
  JSON_FILE = 'tasks.json'

  def initialize
    @manager = TaskManager.new
  end

  def run
    load_data_on_start

    begin
      loop do
        show_menu
        choice = gets.chomp

        case choice
        when '1'
          add_task_menu
        when '2'
          edit_task_menu
        when '3'
          delete_task_menu
        when '4'
          @manager.list_tasks
        when '5'
          find_by_title_menu
        when '6'
          filter_by_category_menu
        when '7'
          filter_by_priority_menu
        when '8'
          save_json_menu
        when '9'
          load_json_menu
        when '10'
          save_yaml_menu
        when '11'
          load_yaml_menu
        when '0'
          puts "Вихід з програми..."
          break
        else
          puts "Помилка: неправильний пункт меню."
        end
      end
    ensure
      @manager.save_to_yaml(YAML_FILE)
      puts "Автозбереження виконано."
    end
  end

  private

  def load_data_on_start
    if File.exist?(YAML_FILE)
      @manager.load_from_yaml(YAML_FILE)
    elsif File.exist?(JSON_FILE)
      @manager.load_from_json(JSON_FILE)
    else
      puts "Файли збереження не знайдено. Створено порожній список завдань."
    end
  end

  def show_menu
    puts
    puts "========== Менеджер завдань =========="
    puts "1. Додати завдання"
    puts "2. Редагувати завдання"
    puts "3. Видалити завдання"
    puts "4. Показати всі завдання"
    puts "5. Пошук за назвою"
    puts "6. Фільтр за категорією"
    puts "7. Фільтр за пріоритетом"
    puts "8. Зберегти у JSON"
    puts "9. Завантажити з JSON"
    puts "10. Зберегти у YAML"
    puts "11. Завантажити з YAML"
    puts "0. Вийти"
    print "Оберіть пункт меню: "
  end

  def add_task_menu
    print "Введіть назву завдання: "
    title = gets.chomp

    print "Введіть категорії через кому: "
    categories = gets.chomp.split(',').map(&:strip)

    print "Введіть пріоритет Високий/Середній/Низький: "
    priority = gets.chomp

    print "Введіть дату виконання YYYY-MM-DD: "
    due_date = gets.chomp

    print "Введіть орієнтовний час у годинах: "
    estimated_hours = gets.chomp.to_i

    @manager.add_task(title, categories, priority, due_date, estimated_hours)
  end

  # Меню редагування завдання
  def edit_task_menu
    print "Введіть id завдання для редагування: "
    id = gets.chomp.to_i

    puts "Що редагувати?"
    puts "1. Назва"
    puts "2. Категорії"
    puts "3. Пріоритет"
    puts "4. Дата виконання"
    puts "5. Орієнтовний час"
    puts "6. Статус виконання"
    print "Оберіть поле: "

    choice = gets.chomp
    new_data = {}

    case choice
    when '1'
      print "Нова назва: "
      new_data[:title] = gets.chomp
    when '2'
      print "Нові категорії через кому: "
      new_data[:categories] = gets.chomp.split(',').map(&:strip)
    when '3'
      print "Новий пріоритет: "
      new_data[:priority] = gets.chomp
    when '4'
      print "Нова дата виконання YYYY-MM-DD: "
      new_data[:due_date] = gets.chomp
    when '5'
      print "Новий орієнтовний час: "
      new_data[:estimated_hours] = gets.chomp.to_i
    when '6'
      print "Завдання виконано? true/false: "
      new_data[:completed] = gets.chomp.downcase == 'true'
    else
      puts "Помилка: неправильний вибір поля."
      return
    end

    @manager.edit_task(id, new_data)
  end

  def delete_task_menu
    print "Введіть id завдання для видалення: "
    id = gets.chomp.to_i

    @manager.delete_task(id)
  end

  def find_by_title_menu
    print "Введіть частину назви для пошуку: "
    query = gets.chomp

    @manager.find_by_title(query)
  end

  def filter_by_category_menu
    print "Введіть категорію: "
    category = gets.chomp

    @manager.filter_by_category(category)
  end

  def filter_by_priority_menu
    print "Введіть пріоритет Високий/Середній/Низький: "
    priority = gets.chomp

    @manager.filter_by_priority(priority)
  end

  def save_json_menu
    @manager.save_to_json(JSON_FILE)
  end

  def load_json_menu
    @manager.load_from_json(JSON_FILE)
  end

  def save_yaml_menu
    @manager.save_to_yaml(YAML_FILE)
  end

  def load_yaml_menu
    @manager.load_from_yaml(YAML_FILE)
  end
end

app = App.new
app.run