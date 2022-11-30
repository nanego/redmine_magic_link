require_dependency 'function'

class Function

  has_and_belongs_to_many :magic_link_rules, :join_table => "functions_magic_link_rules", :foreign_key => "function_id"

end