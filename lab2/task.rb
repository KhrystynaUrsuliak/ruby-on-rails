# Клас Task представляє одне завдання
class Task
  attr_accessor :title, :categories, :priority, :due_date, :estimated_hours, :completed

  def initialize(title, categories, priority, due_date, estimated_hours, completed = false)
    @title = title
    @categories = categories
    @priority = priority
    @due_date = due_date
    @estimated_hours = estimated_hours
    @completed = completed
  end

  def to_h
    {
      title: @title,
      categories: @categories,
      priority: @priority,
      due_date: @due_date,
      estimated_hours: @estimated_hours,
      completed: @completed
    }
  end

  def self.from_h(hash)
    Task.new(
      hash["title"] || hash[:title],
      hash["categories"] || hash[:categories],
      hash["priority"] || hash[:priority],
      hash["due_date"] || hash[:due_date],
      hash["estimated_hours"] || hash[:estimated_hours],
      hash["completed"] || hash[:completed] || false
    )
  end
end