json.extract! course, :id, :department_id, :code, :title, :description, :created_at, :updated_at
json.url course_url(course, format: :json)
