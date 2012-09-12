require 'mongoid'
require 'mongoid_audit'
require 'test/unit'

Dir['./test/models/*.rb'].each { |f| require f }

class TestMongoidAudit < Test::Unit::TestCase
  def setup
    Mongoid.connect_to("mongoid_audit")
    @user = User.new(
      :email => 'test@example.com',
      :first_name => 'Test',
      :last_name => 'User',
      :ccnumber => '4111111111111111',
      :admin => true
    )
    @deal = Deal.new(
      :status => 'Something',
      :description => 'A great deal!',
      :secret_field => 'This is so secret!'
    )
    @user.deal = @deal
    @user.save
  end
  
  def teardown
    User.destroy_all
    Deal.destroy_all
    Audit.destroy_all
  end
  
  # Should only return keys that are in the white list
  def test_whitelist
    audit = Audit.new
    audit.changed_keys = ["first_name", "ccnumber"]
    assert_equal ["first_name"], audit.filter_attributes(@user)
  end
  
  def test_blacklist
    audit = Audit.new
    audit.changed_keys = ["status", "description", "secret_field", "user_id"]
    assert_equal ["status", "description"], audit.filter_attributes(@deal)
  end
  
  def test_saves_all_changed_fields
    audit = Audit.new
    @user.first_name = "Paul"
    assert_equal ["email", "first_name", "admin"], audit.save_all_fields_from_record(@user)
  end
  
  def test_saves_just_changed_fields
    audit = Audit.new
    @user.first_name = "Paul"
    assert_equal ["first_name"], audit.save_changes_from(@user)
  end
  
  def test_audits_convenience_method_gets_base_documents_audits
    assert_equal 1, @user.audits.count
  end
  
end