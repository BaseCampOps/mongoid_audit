[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/BaseCampOps/mongoid_audit)

# MongoidAudit

Easily add auditing to your app. Just include which fields you want auditable and it will track creates, updates and deletes for those fields


## Usage

How to use this model to log changes

Example - Put this in the models you want to audit

      auditable_fields :all # Tracks all fields
      auditable_fields :email, :name # Tracks just these fields
      auditable_fields :all, :except => [:password, :password_confirmation] #Tracks all fields, except the listed

The callbacks are automatically added for before update and after destroy


for every auditable model you can call 'audits' on a record to view that records audits
Example: 
      Deal.first.audits # Returns an array of audits for that deal
      
## Fields in the audit records

      #Used to store what the change was made to 
      field :document_type, type:String
      field :base_document_type, type:String
      field :document_id, type:Moped::BSON::ObjectId
      field :base_document_id, type:Moped::BSON::ObjectId
      # The fields that you will use most often
      field :changed_keys, type:Array
      field :old_values, type:Hash
      field :new_values, type:Hash
      field :log_type, type:String, default:"changed"
      
      # User information. Only available if you have a method in a user model called current_user 
      # hat return the current user
      field :user_id, type:Moped::BSON::ObjectId
      field :user_ip, type:String
      field :user_fullname, type:String
      
## Gotchas

When a document is destroyed it will create an audit entry for that document and will also keep all other audit entries
for that document. If you don't want the old audit entries you must manually destroy them.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
