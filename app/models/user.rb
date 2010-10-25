# == Schema Information
# Schema version: 20101024152530
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#

class User < ActiveRecord::Base
  attr_accessor :password
   attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /^([\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+\.)*[\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+@((((([a-z0-9]{1}[a-z0-9\-]{0,62}[a-z0-9]{1})|[a-z])\.)+[a-z]{2,6})|(\d{1,3}\.){3}\d{1,3}(\:\d{1,5})?)$/i
  
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :email, :presence   => true,
            :format     => { :with => email_regex },
            :uniqueness => { :case_sensitive => false }
  
  # Automatically create the virtual attribute 'password_confirmation'.
   validates :password, :presence     => true,
                        :confirmation => true,
                        :length       => { :within => 6..40 }
  
  before_save :encrypt_password

    def has_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)
    end

    def self.authenticate(email, submitted_password)
        user = find_by_email(email)
        (user && user.has_password?(submitted_password)) ? user : nil
      end

      def self.authenticate_with_salt(id, cookie_salt)
        user = find_by_id(id)
        (user && user.salt == cookie_salt) ? user : nil
      end
    
     private

      def encrypt_password
        unless password.nil?
          self.salt = make_salt
          self.encrypted_password = encrypt(password)
        end
      end

      def encrypt(string)
            secure_hash("#{salt}--#{string}")
          end

          def make_salt
            secure_hash("#{Time.now.utc}--#{password}")
          end

          def secure_hash(string)
            Digest::SHA2.hexdigest(string)
          end
    end
