require_dependency 'custom_field'

class CustomField < ActiveRecord::Base
	has_many :magic_link_rules, :foreign_key => 'contact_custom_field_id', :dependent => :nullify
end