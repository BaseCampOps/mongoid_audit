class Deal
  include Mongoid::Document
  

  field :status, type: String
  field :description, type: String
  field :secret_field, type: String

  belongs_to :user
  
  #Do not track changes to these fields
  auditable_fields :all, :except => [:secret_field, :user_id]
  
end
