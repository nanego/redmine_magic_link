require_dependency 'role'

class Role

  has_and_belongs_to_many :magic_link_rules, :join_table => "magic_link_rules_roles", :foreign_key => "role_id"

end