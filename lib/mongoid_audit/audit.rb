class Audit
  include Mongoid::Document
  include Mongoid::Timestamps
  
  
  # How to use this model to log changes
  # Example - Put this in the models you want to audit
  #  auditable_fields :all # Tracks all fields
  #  auditable_fields :email, :name # Tracks just these fields
  #  auditable_fields :all, :except => [:password, :password_confirmation] #Tracks all fields, except the listed
  
  # The callbacks are automatically added for before_update and after destroy
  
  # for every auditable model you can call 'audits' on an record to view that records audits
  # Example: Deal.first.audits # Returns an array of audits for that deal
  
  # Also there is a file 'mongoid_audit' in config/initializers that adds functionality. 
  # Should be made into a gem instead at some point
  
  #Fields
  #Used to store what the change was made to 
  field :document_type, type:String
  field :base_document_type, type:String
  field :document_id, type:Moped::BSON::ObjectId
  field :base_document_id, type:Moped::BSON::ObjectId
  field :changed_keys, type:Array
  field :old_values, type:Hash
  field :new_values, type:Hash
  field :log_type, type:String, default:"changed"
  
  # User information
  field :user_id, type:Moped::BSON::ObjectId
  field :user_ip, type:String
  field :user_fullname, type:String
  
  validates_inclusion_of :log_type, in:["created", "deleted", "changed"]
  
  before_save :set_current_user
  
  # Pass in a Mongoid record and it saves just the changed attributes to the Audit record
  def extract_changes_from(record)
    self.changed_keys ||= record.changed
    self.filter_attributes(record)
    self.old_values ||= Hash.new
    self.new_values ||= Hash.new
    record.changed.each do |key|
      self.old_values[key] = record.changes[key].first
      self.new_values[key] = record.changes[key].last
    end
    self.changed_keys
  end
  
  # Extracts changes and document id and type and saves those changes to an audit record
  # Usually used in before_save or before_update callbacks
  def save_changes_from(record)
    self.save_base_attributes(record)
    if record.new_record?
      self.log_type = "created"
    end
    self.extract_changes_from(record)
  end
  
  # Normally used on destroy. Saves ALL field and their values, regardless of whether they were changed or not.
  # GOTCHA: Does not save fields in :unauditable_fields
  def save_all_fields_from_record(record)
    self.save_base_attributes(record)
    self.changed_keys = record.attributes.keys
    self.old_values ||= Hash.new
    self.new_values ||= Hash.new
    record.attributes.keys.each do |key|
      self.old_values[key] = record.attributes[key]
      self.new_values[key] = nil
    end
    self.filter_attributes(record)
  end
  
  
  
  # This goes through and saves the attributes for the base document type and id
  # Used so that child documents have the document_type and id set to the parent
  # TODO: Make it check to make sure we are at the top parent. Right now goes one level up, nothng more
  def save_base_attributes(record)
    self.document_type = record.class.name.underscore
    self.document_id = record.id
    if record.embedded_one?
      base_record = {}
      record.relations.each_value do |relation|
        if relation.macro == :embedded_in
          base_class_name = relation.key
          base_record = record.send base_class_name.to_sym
        end
      end
      self.base_document_type = base_record.class.name.underscore
      self.base_document_id = base_record.id
    end
    # Sets base document_id if this record is the base/parent document
      self.base_document_type ||= self.document_type
      self.base_document_id ||= self.document_id
  end
  
  
  # Goes through the black/white list of attributes
  # Will check the records :auditable_attributes or :unauditable_attributes instance methods
  # The only thing the record is used for is to pull out the auditable_attributes/unauditable_attributes
  def filter_attributes(record)
    self.changed_keys ||= []
    if !record.auditable_attributes.nil?
      self.changed_keys &= record.auditable_attributes
    end
    if !record.unauditable_attributes.nil?
      self.changed_keys -= record.unauditable_attributes
    end
    self.changed_keys -= %w{updated_at created_at _id}
    self.changed_keys
  end
  
  
  # callbacks
  
  def set_current_user
    begin
      if Rails.env == 'development' || Rails.env == 'production'
        user = User.current
        if user
          self.user_id = user[:id]
          self.user_ip = user[:ip]
          self.user_fullname = "#{user[:first_name]} #{user[:last_name]}"
        end
      end
    rescue
      logger.info "Not in Rails or we don't have a User model"
    end
  end
  
  
  # Used to output the correct url
  def url
    # NOTE: May be suedful to get the class for the base_document_type and see if it respond_to base.
    # If so call that to make sure we really are at the top parent!
    controller = self.base_document_type.pluralize
    suffix = ''
    if controller == 'deals'
      suffix = '/collect_data'
    end
    controller + '/' + self.base_document_id.to_s + suffix
  end
  
  # Some finders
  
  # Audit.find_for_document('deal', deal_id)
  def self.find_for_document(document_type, id)
    self.where(:base_document_type => 'deal', :base_document_id => id).desc(:created_at)
  end
  
end
