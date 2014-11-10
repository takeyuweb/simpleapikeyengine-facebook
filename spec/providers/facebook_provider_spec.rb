require 'spec_helper'

describe SimpleApiKeyEngine::Providers::FacebookProvider do
  let(:params) do
    {
        provider: 'facebook',
        signed_request: 'SIGNED_REQUEST'
    }
  end
  let(:auth_hash) do
    {
        provider: 'facebook',
        uid: '1234567',
        info: {
            email: 'joe@bloggs.com',
            name: 'Joe Bloggs',
        },
        credentials: {
            token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
            expires_at: 60.days.from_now.to_i, # when the access token expires (it always will)
            expires: true # this will always be true
        },
        extra: {
            raw_info: {
                'id'=>'1234567',
                'email'=> 'joe@bloggs.com',
                'first_name'=>'Joe',
                'gender'=>'male',
                'last_name'=>'Bloggs',
                'link'=>'https://www.facebook.com/app_scoped_user_id/1234567/',
                'locale'=>'ja_JP',
                'name'=> 'Joe Bloggs',
                'timezone'=>9,
                'updated_time'=>'2014-09-23T06:18:23+0000',
                'verified'=>true
            }
        }
    }
  end
  describe '#auth' do
    let(:authentication_provider) { SimpleApiKeyEngine::Providers::FacebookProvider.new(params) }
    subject(:auth) do
      authentication_provider.auth do |auth_hash|
        user = auth_user
        user[:name] = auth_hash[:info][:name]
        user[:email] = auth_hash[:info][:email]
        user
      end
    end
    let(:auth_user) do
      user = Hash.new
      def user.name; self[:name]; end
      def user.email; self[:email]; end
      user
    end
    before do
      allow(authentication_provider).to receive_messages(get_auth_hash!: auth_hash)
    end
    context '新しい認証情報のとき' do
      it '認証情報を返すこと' do
        expect(auth).to be_instance_of(SimpleApiKeyEngine::Authentication)
      end
      it '認証情報にOAuth2アクセストークンを記録すること' do
        expect(auth.token).to eq(auth_hash[:credentials][:token])
      end
      it 'ユーザーに名前を設定すること' do
        expect { auth }.to change(auth_user, :name).from(nil).to(auth_hash[:info][:name])
      end
      it 'ユーザーにメールアドレスを設定すること' do
        expect { auth }.to change(auth_user, :email).from(nil).to(auth_hash[:info][:email])
      end
    end
    context '既知（providerとuidの組が存在する）の認証情報のとき' do
      let(:auth_user) do
        user = Hash.new
        def user.name; self[:name]; end
        def user.email; self[:email]; end
        user
      end
      let(:authentication) { stub_model(SimpleApiKeyEngine::Authentication, user: auth_user) }
      before do
        allow(SimpleApiKeyEngine::Authentication).to receive_messages(find_by_provider_and_uid: authentication)
      end
      it '認証情報を返すこと' do
        expect(auth).to be_instance_of(SimpleApiKeyEngine::Authentication)
      end
      it '認証情報にOAuth2アクセストークンを記録すること' do
        expect(auth.token).to eq(auth_hash[:credentials][:token])
      end
      it 'ユーザーの名前を更新しないこと' do
        expect { auth }.to_not change(auth_user, :name)
      end
      it 'ユーザーのメールアドレスを更新しないこと' do
        expect { auth }.to_not change(auth_user, :email)
      end
    end
  end

  describe '#client' do
    let(:authentication_provider) { SimpleApiKeyEngine::Providers::FacebookProvider.new(params) }
    subject(:client) { authentication_provider.client }
    it 'Returns a OAuth2 client.' do
      expect(client).to be_instance_of(Koala::Facebook::OAuth)
    end
    it 'Sets a Facebook application ID' do
      expect(client.app_id).to eq(ENV['FACEBOOK_APP_ID'])
    end
    it 'Sets a Facebook application secret' do
      expect(client.app_secret).to eq(ENV['FACEBOOK_APP_SECRET'])
    end
  end

  describe '#get_auth_hash!' do
    let(:authentication_provider) { SimpleApiKeyEngine::Providers::FacebookProvider.new(params) }
    let(:client) { double(Koala::Facebook::OAuth) }
    let(:graph_client) { double(Koala::Facebook::API.new) }
    let(:oauth_res) do
      {
          'code' => 'CODE'
      }
    end
    let(:short_token) { 'OAUTH2_SHORT_TOKEN' }
    let(:long_token) { auth_hash[:credentials][:token] }
    let(:long_token_info) do
      {
          'access_token' => long_token,
          'expires' => 60.days
      }
    end
    subject(:get_auth_hash!) { authentication_provider.get_auth_hash! }
    before do
      allow(authentication_provider).to receive_messages(client: client)
      allow(client).to receive_messages(parse_signed_request: oauth_res,
                                        get_access_token: short_token,
                                        exchange_access_token_info: long_token_info)
      allow(Koala::Facebook::API).to receive_messages(new: graph_client)
      allow(graph_client).to receive_messages(get_object: auth_hash[:extra][:raw_info])
    end
    it '認証情報を取得' do
      expect(get_auth_hash!).to eq(auth_hash)
    end
  end

end
