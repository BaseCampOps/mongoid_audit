class User
  include Mongoid::Document
  

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  field :admin, :type => Boolean, :default => false         

  ## User profile fields
  field :first_name, :type => String
  field :last_name, :type => String
  field :cc_number, :type => String
  
  #relations
  has_one :deal
  
  ## Auditing
  auditable_fields :email, :admin, :first_name

end
