require 'test_helper'
require 'net/pop'
require 'mocha'

class ReceivePop3MessageJobTest < ActiveSupport::TestCase
  include Mocha::API

  should "perform no ssl" do
    app = Application.create(:name => 'app', :password => 'pass')
    chan = Channel.create(:application_id => app.id, :name => 'chan', :protocol => 'protocol', :kind => 'pop3', 
      :configuration => {:host => 'the_host', :port => 123, :user => 'the_user', :password => 'the_password', :use_ssl => '0'})
      
    mail = mock('Net::POPMail')
    mail.stubs(
      :pop =>
<<-END_OF_MESSAGE
From: from@mail.com
To: to@mail.com
Subject: some subject
Date: Thu, 5 Nov 2009 14:52:54 +0100
Message-ID: <47404c5326d9c_2ad4fbb80161@baci.local.tmail>

Hello!
END_OF_MESSAGE
    )
      
    pop = mock('Net::Pop3')
    Net::POP3.expects(:new).with('the_host', 123).returns(pop)
    pop.expects(:start).with('the_user', 'the_password')
    pop.expects(:each_mail).yields(mail)
    mail.expects(:delete)
    pop.expects(:finish)
      
    job = ReceivePop3MessageJob.new(app.id, chan.id)
    job.perform
    
    msgs = ATMessage.all
    assert_equal 1, msgs.length
    
    msg = msgs[0]
    assert_equal app.id, msg.application_id
    assert_equal 'mailto://from@mail.com', msg.from
    assert_equal 'mailto://to@mail.com', msg.to
    assert_equal 'some subject', msg.subject
    assert_equal "Hello!\n", msg.body
    assert_equal "<47404c5326d9c_2ad4fbb80161@baci.local.tmail>", msg.guid
    assert_equal Time.parse('Thu, 5 Nov 2009 14:52:54 +0100'), msg.timestamp
  end
  
  should "perform ssl" do
    app = Application.create(:name => 'app', :password => 'pass')
    chan = Channel.create(:application_id => app.id, :name => 'chan', :protocol => 'protocol', :kind => 'pop3', 
      :configuration => {:host => 'the_host', :port => 123, :user => 'the_user', :password => 'the_password', :use_ssl => '1'})
      
    mail = mock('Net::POPMail')
    mail.stubs(
      :pop =>
<<-END_OF_MESSAGE
From: from@mail.com
To: to@mail.com
Subject: some subject
Date: Thu, 5 Nov 2009 14:52:54 +0100
Message-ID: <47404c5326d9c_2ad4fbb80161@baci.local.tmail>

Hello!
END_OF_MESSAGE
    )
      
    pop = mock('Net::Pop3')
    Net::POP3.expects(:new).with('the_host', 123).returns(pop)
    pop.expects(:enable_ssl).with(OpenSSL::SSL::VERIFY_NONE)
    pop.expects(:start).with('the_user', 'the_password')
    pop.expects(:each_mail).yields(mail)
    mail.expects(:delete)
    pop.expects(:finish)
      
    job = ReceivePop3MessageJob.new(app.id, chan.id)
    job.perform
    
    msgs = ATMessage.all
    assert_equal 1, msgs.length
    
    msg = msgs[0]
    assert_equal app.id, msg.application_id
    assert_equal 'mailto://from@mail.com', msg.from
    assert_equal 'mailto://to@mail.com', msg.to
    assert_equal 'some subject', msg.subject
    assert_equal "Hello!\n", msg.body
    assert_equal "<47404c5326d9c_2ad4fbb80161@baci.local.tmail>", msg.guid
    assert_equal Time.parse('Thu, 5 Nov 2009 14:52:54 +0100'), msg.timestamp
  end
  
  should "perform no message id" do
    app = Application.create(:name => 'app', :password => 'pass')
    chan = Channel.create(:application_id => app.id, :name => 'chan', :protocol => 'protocol', :kind => 'pop3', 
      :configuration => {:host => 'the_host', :port => 123, :user => 'the_user', :password => 'the_password', :use_ssl => '0'})
      
    mail = mock('Net::POPMail')
    mail.stubs(
      :pop =>
<<-END_OF_MESSAGE
From: from@mail.com
To: to@mail.com
Subject: some subject
Date: Thu, 5 Nov 2009 14:52:54 +0100

Hello!
END_OF_MESSAGE
    )
      
    pop = mock('Net::Pop3')
    Net::POP3.expects(:new).with('the_host', 123).returns(pop)
    pop.expects(:start).with('the_user', 'the_password')
    pop.expects(:each_mail).yields(mail)
    mail.expects(:delete)
    pop.expects(:finish)
      
    job = ReceivePop3MessageJob.new(app.id, chan.id)
    job.perform
    
    msgs = ATMessage.all
    assert_equal 1, msgs.length
    
    msg = msgs[0]
    assert_equal app.id, msg.application_id
    assert_equal 'mailto://from@mail.com', msg.from
    assert_equal 'mailto://to@mail.com', msg.to
    assert_equal 'some subject', msg.subject
    assert_equal "Hello!\n", msg.body
    assert !msg.guid.nil?
    assert_equal Time.parse('Thu, 5 Nov 2009 14:52:54 +0100'), msg.timestamp
  end
end