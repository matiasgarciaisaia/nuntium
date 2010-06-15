require 'test_helper'

class QstChannelHandlerTest < ActiveSupport::TestCase
  test "should not save if password is blank" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst_server', :protocol => 'sms')
    chan.configuration = {}
    assert !chan.save
  end
  
  test "should not save if password confirmation is wrong" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst_server', :protocol => 'sms')
    chan.configuration = {:password => 'foo', :password_confirmation => 'foo2'}
    assert !chan.save
  end
  
  test "should save" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst_server', :protocol => 'sms')
    chan.configuration = {:password => 'foo', :password_confirmation => 'foo'}
    assert chan.save
  end
  
  test "should save if name is taken by another app" do
    app = Application.create!(:name => 'app', :password => 'foo')
    app2 = Application.create!(:name => 'app2', :password => 'foo')
    chan = Channel.new(:application_id => app2.id, :name => 'chan', :kind => 'qst_server')
    chan.configuration = {:password => 'foo', :password_confirmation => 'foo2'}
    chan.save
    
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst_server', :protocol => 'sms')
    chan.configuration = {:password => 'foo', :password_confirmation => 'foo'}
    chan.save!
  end
  
  test "should authenticate" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst_server', :protocol => 'sms')
    chan.configuration = {:password => 'foo', :password_confirmation => 'foo'}
    chan.save
    
    assert chan.handler.authenticate('foo')
    assert !chan.handler.authenticate('foo2')
  end
end