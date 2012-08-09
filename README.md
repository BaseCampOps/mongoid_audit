# MongoidAudit

TODO: Write a gem description


## Usage

How to use this model to log changes
Example - Put this in the models you want to audit
      auditable_fields :all # Tracks all fields
      auditable_fields :email, :name # Tracks just these fields
      auditable_fields :all, :except => [:password, :password_confirmation] #Tracks all fields, except the listed

The callbacks are automatically added for before_update and after destroy


for every auditable model you can call 'audits' on a record to view that records audits
Example: 
      Deal.first.audits # Returns an array of audits for that deal


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
