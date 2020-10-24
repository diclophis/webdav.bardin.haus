# webdav server

# gems
require 'rubygems'

Bundler.require

#require 'rack_dav'
#run RackDAV::Handler.new(:root => '/home/app/public')

require 'dav4rack'
require 'dav4rack/file_resource_lock'
require 'dav4rack/resources/file_resource'

require 'bespoked'

require 'bespoked/rack_handler'

use Rack::CommonLogger

class MyResource < DAV4Rack::FileResource
  def unlock(token)
    token = token.slice(1, token.length - 2)
    if(token.nil? || token.empty?)
      DAV4Rack::HTTPStatus::BadRequest
    else
      lock = DAV4Rack::FileResourceLock.find_by_token(token, "/home/app/public/incoming")
      if(lock.nil? || lock.user_id != @user.id)
        DAV4Rack::HTTPStatus::Forbidden
      elsif(lock.path !~ /^#{Regexp.escape(@path)}.*$/)
        Conflict
      else
        lock.destroy
        DAV4Rack::HTTPStatus::NoContent
      end
    end
  end
end

#TODO: figure this out
module Rack
  class Lint
    def call(env = nil)
      @app.call(env)
    end
  end
end

run DAV4Rack::Handler.new(:resource_class => MyResource, :root => '/home/app/public/incoming') #, :root_uri_path => '/')
#run DAV4Rack::Handler.new(:root => '/home/app/public/incoming', :root_uri_path => '/incoming')
