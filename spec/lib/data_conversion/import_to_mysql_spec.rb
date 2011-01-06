# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'
Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

describe DataConversion::ImportToMysql do
  def copy_fixture_for(table_name)
    FileUtils.cp("#{Rails.root}/spec/fixtures/data_conversion/#{table_name}.csv",
                 "#{@migrator.full_path}/#{table_name}.csv")
  end

  before do
    @migrator = DataConversion::ImportToMysql.new
    @migrator.full_path = "/tmp/data_conversion"
    system("rm -rf #{@migrator.full_path}")
    FileUtils.mkdir_p(@migrator.full_path)
  end

  describe "#import_raw" do
    describe "aspects" do
      before do
        copy_fixture_for("aspects")
      end

      it "imports data into the mongo_aspects table" do
        Mongo::Aspect.count.should == 0
        @migrator.import_raw_aspects
        Mongo::Aspect.count.should == 4
      end

      it "imports all the columns" do
        @migrator.import_raw_aspects
        aspect = Mongo::Aspect.first
        aspect.name.should == "generic"
        aspect.mongo_id.should == "4d26212bcc8cb44df2000006"
        aspect.user_mongo_id.should == "4d26212acc8cb44df2000005"
      end
    end

    describe "aspect_memberships" do
      before do
        copy_fixture_for("aspect_memberships")
      end

      it "imports data into the mongo_aspect_memberships table" do
        Mongo::AspectMembership.count.should == 0
        @migrator.import_raw_aspect_memberships
        Mongo::AspectMembership.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_aspect_memberships
        aspectm = Mongo::AspectMembership.first
        aspectm.contact_mongo_id.should == "4d26212bcc8cb44df200000d"
        aspectm.aspect_mongo_id.should == "4d26212bcc8cb44df2000006"
      end
    end

    describe "comments" do
      before do
        copy_fixture_for("comments")
      end

      it "imports data into the mongo_comments table" do
        Mongo::Comment.count.should == 0
        @migrator.import_raw_comments
        Mongo::Comment.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_comments
        comment = Mongo::Comment.first
        comment.mongo_id.should == "4d262132cc8cb44df2000027"
        comment.text.should == "Hey me!"
        comment.person_mongo_id.should == "4d26212bcc8cb44df2000014"
        comment.post_mongo_id.should == "4d262132cc8cb44df2000025"
        comment.youtube_titles.should == ""
      end
    end
    describe "contacts" do
      before do
        copy_fixture_for("contacts")
      end

      it "imports data into the mongo_contacts table" do
        Mongo::Contact.count.should == 0
        @migrator.import_raw_contacts
        Mongo::Contact.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_contacts
        contact = Mongo::Contact.first
        contact.mongo_id.should == "4d26212bcc8cb44df200000d"
        contact.user_mongo_id.should =="4d26212acc8cb44df2000005"
        contact.person_mongo_id.should == "4d26212bcc8cb44df200000c"
        contact.pending.should be_false
        contact.created_at.should be_nil
      end
    end
    describe "invitations" do
      before do
        copy_fixture_for("invitations")
      end

      it "imports data into the mongo_invitations table" do
        Mongo::Invitation.count.should == 0
        @migrator.import_raw_invitations
        Mongo::Invitation.count.should == 1
      end

      it "imports all the columns" do
        @migrator.import_raw_invitations
        invitation = Mongo::Invitation.first
        invitation.mongo_id.should == "4d262131cc8cb44df2000022"
        invitation.recipient_mongo_id.should =="4d26212fcc8cb44df2000021"
        invitation.sender_mongo_id.should == "4d26212acc8cb44df2000005"
        invitation.aspect_mongo_id.should == '4d26212bcc8cb44df2000006'
        invitation.message.should == "Hello!"
      end
    end



    describe "people" do
      before do
        copy_fixture_for("people")
      end

      it "imports data into the mongo_people table" do
        Mongo::Person.count.should == 0
        @migrator.import_raw_people
        Mongo::Person.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_people
        person = Mongo::Person.first
        pp person
        person.owner_mongo_id.should be_nil
        person.mongo_id.should == "4d26212bcc8cb44df200000d"
        person.created_at.should be_nil
      end
    end
    describe "post_visibilities" do
      before do
        copy_fixture_for("post_visibilities")
      end

      it "imports data into the mongo_post_visibilities table" do
        Mongo::PostVisibility.count.should == 0
        @migrator.import_raw_post_visibilities
        Mongo::PostVisibility.count.should == 8
      end

      it "imports all the columns" do
        @migrator.import_raw_post_visibilities
        pv = Mongo::PostVisibility.first
        pv.post_mongo_id.should == "4d262132cc8cb44df2000023"
        pv.aspect_mongo_id.should =="4d26212bcc8cb44df2000006"
      end
    end

    describe "requests" do
      before do
        copy_fixture_for("requests")
      end

      it "imports data into the mongo_requests table" do
        Mongo::Request.count.should == 0
        @migrator.import_raw_requests
        Mongo::Request.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_requests
        request = Mongo::Request.first
        request.mongo_id.should == "4d26212ccc8cb44df200001b"
        request.recipient_mongo_id.should =="4d26212bcc8cb44df2000018"
        request.sender_mongo_id.should == "4d26212bcc8cb44df2000014"
        request.aspect_mongo_id.should == ''
      end
    end

    describe "users" do
      before do
        copy_fixture_for("users")
      end
      it "imports data into the mongo_users table" do
        Mongo::User.count.should == 0
        @migrator.import_raw_users
        Mongo::User.count.should == 6
      end
      it "imports all the columns" do
        @migrator.import_raw_users
        bob = Mongo::User.first
        bob.mongo_id.should == "4d26212acc8cb44df2000005"
        bob.username.should == "bob178fa79"
        bob.serialized_private_key.should_not be_nil
        bob.encrypted_password.should_not be_nil
        bob.invites.should == 4
        bob.invitation_token.should == ""
        bob.invitation_sent_at.should be_nil
        bob.getting_started.should be_false
        bob.disable_mail.should be_false
        bob.language.should == 'en'
        bob.last_sign_in_ip.should == ''
        bob.last_sign_in_at.to_i.should_not be_nil
        bob.reset_password_token.should == ""
        bob.password_salt.should_not be_nil
      end
    end
  end
end