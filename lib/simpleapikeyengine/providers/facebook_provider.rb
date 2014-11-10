require 'simpleapikeyengine/providers/abstract_provider'
require 'koala'

module SimpleApiKeyEngine::Providers
  class FacebookProvider < AbstractProvider
    priority 5
    def self.acceptable?(auth_hash)
      auth_hash[:provider] == 'facebook'
    end

    def client
      @oauth ||= Koala::Facebook::OAuth.new(SimpleApiKeyEngine.configuration.facebook_app_id,
                                            SimpleApiKeyEngine.configuration.facebook_app_secret)
    end

    def get_auth_hash!
      res = client.parse_signed_request(@params[:signed_request])
      short_token = client.get_access_token(res['code'])
      graph = Koala::Facebook::API.new(short_token)
      user_info = graph.get_object('me')
      new_token = client.exchange_access_token_info(short_token)

      if new_token['expires'].to_i > 0
        expires_at = (Time.now.to_i + new_token['expires'].to_i).to_i
        expires = true
      else
        expires_at = nil
        expires = false
      end
      {
          provider: @params[:provider],
          uid: user_info['id'],
          credentials: {
              token: new_token['access_token'],
              expires_at: expires_at,
              expires: expires
          },
          info: {
              email: user_info['email'],
              name: user_info['name']
          },
          extra: {
              raw_info: user_info.to_h
          }
      }
    end
  end
end
