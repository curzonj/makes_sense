require 'openssl'
require 'base64'

module Encryption
  class << self
    def encrypt(value)
      Base64.encode64(public_key.public_encrypt(value))  
    end

    def decrypt(value)
      private_key.private_decrypt(Base64.decode64(value))
    end

    private
    def public_key
      path = [ RAILS_ROOT, ENV['PUBLIC_KEY_PATH'] ].join('/')

      @public_key ||= OpenSSL::PKey::RSA.new(File.read(path))
    end

    def private_key
      path = [ RAILS_ROOT, ENV['PRIVATE_KEY_PATH'] ].join('/')

      @private_key ||= OpenSSL::PKey::RSA.new(File.read(path),
                                              ENV['PRIVATE_KEY_PASSPHRASE'])
    end
  end
end
