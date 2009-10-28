# Put the amazon keys in config/app_config_local.yml. You can also
# specify an arbitrary prefix to seperate your file from other stuff,
# just make sure it doesn't conflict with any other possible folder
# names because production doesn't use a prefix
module AmazonHelper
  class << self
    # Anytime you pass a key into an S3 method, call this method first to put
    # the prefix on it if needed
    def key(value)
      prefix.blank? ?
        value : "#{prefix}/#{value}"
    end

    def prefix
      ENV['AMAZON_PREFIX']
    end

    def bucket_name
      ENV['AMAZON_BUCKET']
    end

    def bucket
      @bucket ||= s3.bucket(bucket_name)
    end

    def public_url(short_key)
      "http://#{bucket}.s3.amazonaws.com/#{key(short_key)}"
    end

    def access_key
      ENV['AMAZON_ACCESS_KEY_ID']
    end

    def secret_key
      ENV['AMAZON_SECRET_ACCESS_KEY']
    end

    def signed_fetch(key)
      s3.interface.get_link(bucket_name, key)
    end

    def list(prefix)
      keys = key(prefix)
      bucket.keys(:prefix => keys)
    end

    def exists?(in_key)
      bucket.exists?(key(in_key))
    end

    # Be aware, this method expects that the oldkey comes
    # from interacting with S3 and already has any prefix applied,
    # the newkey though will have the prefix applied.
    def move_public(oldkey, newkey)
      s3.interface.move(bucket, oldkey.to_s,
                        bucket, AmazonHelper.key(newkey),
                        :copy, 'x-amz-acl' => 'public-read')
    end

    # A helper for downloading files from s3 to the local server
    # to access them on the file system. It streams them to disk
    # so you can safely download large files without consuming memory.
    def download(partial_key, dir=Dir.tempdir)
      full_key = key(partial_key)
      AmazonHelper.bucket.key(full_key)
      path = "#{dir}/" + File.basename(full_key)

      file = File.new(path, File::CREAT|File::RDWR)
      headers = s3.interface.get(bucket_name, full_key) do |chunk|
        file.write(chunk)
      end

      return [ path, headers ]
    ensure
      file.close unless file.nil?
    end

    def upload_policy(component, opts={})
      key = AmazonHelper.key("uploads/#{component}/#{Time.new.to_i}/#{rand(1000)}")

      {
        :prefix => key,
        :action => "https://#{AmazonHelper.bucket_name}.s3.amazonaws.com/",
        :params => AmazonHelper.upload_params(key, opts)
      }
    end

    # Generates the parameters for authenticated browser uploads to S3. The upload
    # doesn't get stored at the key passed in, it gets stored at (prefix + filename)
    # so you'll need to enumerate the keys with this prefix to find the uploaded
    # file(s). Nothing stops the user from uploading many files into this space. You
    # can chose whether this fits your code. You can pick the first key in the list,
    # and delete the rest if you just want a single upload.
    #
    # By default the files uploaded are not publicly accessible. IE, the user can upload
    # them, but they can't actually fetch them back. Pass :public => true if you want
    # the file to be publicly available. If :public => false or is missing, you can
    # change the acl in post processing.
    #
    # http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1434
    #
    def upload_params(prefix, opts={})
      return if prefix.blank?

      expires = (opts[:expires] || 30.minutes).from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
      bucket = AmazonHelper.bucket
      acl = (opts[:public] == true) ? 'public-read' : 'private'
      max_filesize =  opts[:max_filesize] || 200.megabyte

      policy = Base64.encode64(
        "{'expiration': '#{expires}',
          'conditions': [
            {'bucket': '#{bucket}'},
            ['starts-with', '$key', '#{prefix}'],
            {'acl': '#{acl}'},
            {'success_action_status': '201'},
            ['content-length-range', 0, #{max_filesize}]
          ]
        }").gsub(/\n|\r/, '')

      signature = Base64.encode64(
                    OpenSSL::HMAC.digest(
                      OpenSSL::Digest::Digest.new('sha1'),
                      secret_key,
                      policy)
                  ).gsub("\n","")

      {
        :key => "#{prefix}/${filename}",
        :acl => acl,
        :policy => policy,
        :signature => signature,
        :AWSAccessKeyId =>  access_key,
        :success_action_status => 201
      }
    end

    def send_sqs(queue_name, msg)
      msg_body = msg.to_json
      q = queue(queue_name)
      q.send_message(msg_body)
    end

    def queue(name)
      prefix = ENV['AMAZON_SQS_PREFIX'] || ''
      sqs.queue(prefix.to_s + name.to_s)
    end

    def sqs
      @sqs_object ||= RightAws::SqsGen2.new(access_key, secret_key)
    end

    protected

    def s3
      @s3_object ||= RightAws::S3.new(access_key, secret_key)
    end
  end
end
