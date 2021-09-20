class IssueMagicLinkRule < ActiveRecord::Base

  belongs_to :magic_link_rule
  belongs_to :issue

  validates_presence_of :magic_link_hash
  validates_uniqueness_of :magic_link_hash

end
