require "mongoid_audit/version"
require File.join(File.dirname(__FILE__), 'mongoid_audit/audit')
#require File.expand_path(File.dirname(__FILE__) + '/mongoid_audit/audit')

module MongoidAudit
  extend ActiveSupport::Concern
 
  included do
    mattr_accessor :auditable_attributes
    mattr_accessor :unauditable_attributes
#    if defined? ::Kaminari
#      ::Mongoid::Criteria.send :include, Kaminari::MongoidExtension::Criteria
#      ::Mongoid::Document.send :include, Kaminari::MongoidExtension::Document
#    end
  end

  module ClassMethods
    # Can type auditable_fields :field1, :field2 inside of a Mongoid model class
    # A white list of auditable fields
    def auditable_fields(*fields)
      all_fields = false
      fields.each do |field|
        if field == :all
          all_fields = true
        elsif field.is_a?(Hash) && field[:except]
          field[:except].each do |field|
            self.unauditable_attributes ||= []
            self.unauditable_attributes << field.to_s
          end
        else
          self.auditable_attributes ||= []
          self.auditable_attributes << field.to_s
        end
      end
      # Makes sure that all fields are set. Fixes bug e.g. auditable_fields :all, :another_field
      self.auditable_attributes = nil if all_fields
      self.set_audit_callbacks
    end
    
    # Sets the callbacks for documents in the collection
    def set_audit_callbacks
      self.set_callback(:save, :before) do |record|
        if record.changed? && record.valid?
          audit = Audit.new
          audit.save_changes_from(record)
          audit.save if audit.changed_keys.count > 0
        end
      end
      
      self.set_callback(:destroy, :after) do |record|
        audit = Audit.new
        audit.save_all_fields_from_record(record)
        audit.log_type = "deleted"
        audit.save
      end
    end
  end
  
  # Convenience methods to get audits for instances of Monogid documents
  def audits
    document_type = self.class.name.underscore
    document_id = self.id
    # For some reason self.base does not work! So we go through relations manually
    self.relations.each_value do |relation|
      if relation.macro == :embedded_in
        document_type = relation.key
        document_id = self.send(relation.key.to_sym).id
      end
    end
    Audit.where(:base_document_type => document_type, :base_document_id => document_id).desc(:created_at)
  end
end

# This adds the OPTION to audit to all Mongoid Collections
module Mongoid::Document
  include MongoidAudit
end
