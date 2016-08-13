get '/' do
  erb :index
end

post '/fetch' do

  if params[:handle] == "" 
    redirect '/'
  else 
    if User.find_by(handle: params[:handle]) == nil
      return 'A'
    elsif Tweets.updated?(params[:handle], User.find_by(handle: params[:handle]).id)
      @display = Tweets.all
      @user = User.find_by(handle: params[:handle])
      erb :tweets , :layout => false
    else 
      return 'B'
    end
  end

end

get '/:handle' do

  @handle = params[:handle]
  @user = User.find_by(handle: @handle)
  if @user == nil
    @user = User.new(handle: @handle)
    if @user.save
       @twitter_user = CLIENT.user_search(@user.handle)[0]
    end
  else
    @twitter_user = CLIENT.user_search(@user.handle)[0]
  end 

  @t = Tweets.find_by(user_id: @user.id)
  if @t == nil
    @tweets = CLIENT.user_timeline(@user.handle,  options = {:count => 10})
    @tweets.each { |x| Tweets.create(user_id: @user.id, tweet: x.full_text) }
    @display = Tweets.all
  end 

  if Tweets.updated?(@user.handle, @user.id)
    @display = Tweets.all 
  else
    @roberto = Tweets.where(user_id: @user.id)
    Tweets.destroy(@roberto.to_a)
    @tweets = CLIENT.user_timeline(@user.handle,  options = {:count => 10})
    @tweets.each { |x| Tweets.create(user_id: @user.id, tweet: x.full_text) }
    @display = Tweets.all
  end
  erb :tweets

end

post '/tweet' do
  if params[:tweet_text] == "" 
    redirect '/'
  else 
    @tweet = params[:tweet_text]
    CLIENT.update(@tweet)
    erb :index , :layout => false
  end
    # Recibe el input del usuario

    # Crea el tweet utilizando la API de Twitter

    # Regresa al usuario el tweet o un mensaje de EXITO o ERROR
end

get '/sign_in' do
  # El método `request_token` es uno de los helpers
  # Esto lleva al usuario a una página de twitter donde sera atentificado con sus credenciales
  redirect request_token.authorize_url(:oauth_callback => "http://#{host_and_port}/auth")
  # Cuando el usuario otorga sus credenciales es redirigido a la callback_url 
  # Dentro de params twitter regresa un 'request_token' llamado 'oauth_verifier'
end

get '/auth' do
  # Volvemos a mandar a twitter el 'request_token' a cambio de un 'acces_token' 
  # Este 'acces_token' lo utilizaremos para futuras comunicaciones.   
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # Despues de utilizar el 'request token' ya podemos borrarlo, porque no vuelve a servir. 
  session.delete(:request_token)

  # Aquí es donde deberás crear la cuenta del usuario y guardar usando el 'acces_token' lo siguiente:
  # nombre, oauth_token y oauth_token_secret
  # No olvides crear su sesión 
end

  # Para el signout no olvides borrar el hash de session
