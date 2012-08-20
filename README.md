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
      
      
## Gotchas

When a document is destroyed it will create an audit entry for that document and will also keep all other audit entries
for that document. If you don't want the old audit entries you must manually destroy them.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
