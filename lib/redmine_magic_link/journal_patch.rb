require_dependency 'journal'

class Journal < ActiveRecord::Base

  after_create_commit :send_magic_links

  def send_magic_links
    if self.journalized.is_a?(Issue) && !self.private_notes
      updated_issue = self.journalized.reload
      MagicLinkRule.active.each do |magic_link_rule|
        contact_custom_field = magic_link_rule.contact_custom_field
        if updated_issue.available_custom_fields.include?(contact_custom_field)
          recipient = updated_issue.custom_value_for(contact_custom_field).value
          if recipient.present?
            Mailer.deliver_issue_edit_with_magic_link(updated_issue, self, recipient, magic_link_rule)
          end
        end
      end
    end
  end

end
